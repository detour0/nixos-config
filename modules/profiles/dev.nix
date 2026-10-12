{
  inputs,
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}:

with lib;

let
  cfg = config.profile.dev;
in
{
  imports = [
    ../features/container.nix
    ../features/vm.nix
  ];

  options.profile.dev = mkProfileOptions "dev profile" {
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
        enable = cfg.containers.enable;
        runtime = cfg.containers.runtime;
        rootless = cfg.containers.dockerRootless;
      };
      features.vm.enable = cfg.vm.enable;
      environment.variables.EDITOR = cfg.editor;
    }

    (mkProfileHome config "dev" (user: {
      imports = [
        ../features/home/tmux.nix
        ../features/home/direnv.nix
      ]
      ++ (optional (cfg.editor == "nvim") ../features/home/nvim);

      home.packages =
        (with pkgs; [
          git-filter-repo
          openssl
        ])
        ++ (with pkgsUnstable; [
          devenv
        ])
        ++ (optionals cfg.deploy.enable [
          inputs.deploy-rs.packages.${pkgs.system}.default
          pkgs.sops
          pkgs.age
        ]);
    }))

    # 3. Assign additional user profiles
    {
      users.users = genAttrs cfg.users (user: {
        extraGroups =
          (optional cfg.vm.enable "kvm") ++ (optional (!cfg.containers.dockerRootless) "docker");
      });
    }
  ]);
}
