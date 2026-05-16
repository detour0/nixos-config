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
  };

  config = mkIf cfg.enable (mkMerge [
    # 1. System-wide features
    {
      features.container = {
        enable = true;
        # runtime = "podman";
      };
      features.vm.enable = cfg.vm.enable;
      environment.variables.EDITOR = cfg.editor;
    }

    # 2. Home-manager features
    (mkProfileHome config "dev" (user: {
      imports = [
        ../features/home/tmux.nix
        ../features/home/direnv.nix
      ]
      ++ (optional (cfg.editor == "nvim") ../features/home/nvim);

      home.packages =
        (with pkgs; [
          git-filter-repo
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
        extraGroups = optional cfg.vm.enable "kvm";
      });
    }
  ]);
}
