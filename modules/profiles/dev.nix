{
  inputs,
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}:

let
  inherit (lib)
    genAttrs
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    mkProfileHome
    mkProfileOptions
    optional
    optionals
    types
    ;
  cfg = config.profile.dev;
in
{
  imports = [
    ../features/container.nix
    ../features/vm.nix
  ];

  options.profile.dev = mkProfileOptions config "dev profile" {
    editor = mkOption {
      type = types.enum [ "nvim" ];
      default = "nvim";
    };
    vm.enable = mkEnableOption "virtualisation packges/service";
    deploy.enable = mkEnableOption "Deploy software locally/remotely";
    containers = {
      enable = mkEnableOption "Install container runtime";
      runtime = mkOption {
        type = types.enum [
          "docker"
          "podman"
          "both"
        ];
        default = "docker";
        description = "Container runtime to enable";
      };
      dockerRootless = mkEnableOption "Rootful/Rootless Docker daemon";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      features.container = {
        inherit (cfg.containers) enable runtime;
        rootless = cfg.containers.dockerRootless;
      };
      features.vm.enable = cfg.vm.enable;
      environment.variables.EDITOR = cfg.editor;

      users.users = genAttrs cfg.users (_: {
        extraGroups = optional cfg.vm.enable "kvm" ++ optional (!cfg.containers.dockerRootless) "docker";
      });
    }

    (mkProfileHome cfg {
      # git keeps using the SSH key; gh only talks to the API
      programs.gh = {
        enable = true;
        gitCredentialHelper.enable = false;
        settings.git_protocol = "ssh";
      };

      # Hands the agent token to Claude Code sessions only, not to every shell
      programs.zsh.initContent = mkIf (config.sops.secrets ? agent_token_github) (
        let
          token = config.sops.secrets.agent_token_github.path;
        in
        ''
          claude() {
            if [[ -r ${token} ]]; then
              GH_TOKEN="$(<${token})" command claude "$@"
            else
              command claude "$@"
            fi
          }
        ''
      );

      imports = [
        ../features/home/tmux.nix
        ../features/home/direnv.nix
      ]
      ++ optional (cfg.editor == "nvim") ../features/home/nvim;

      home.packages = [
        pkgs.git-filter-repo
        pkgs.openssl
        pkgsUnstable.devenv
      ]
      ++ optionals cfg.deploy.enable [
        inputs.deploy-rs.packages.${pkgs.stdenv.hostPlatform.system}.default
        pkgs.sops
        pkgs.age
        # Claude Code sandbox (filesystem and network isolation for shell commands)
        pkgs.bubblewrap
        pkgs.socat
      ];
    })
  ]);
}
