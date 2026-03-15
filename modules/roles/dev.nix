{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}:

with lib;

let
  cfg = config.role.dev;
in
{
  imports = [
    ../features/container.nix
    ../features/vm.nix
  ];

  options.role.dev = mkRoleOptions "dev role" {
    editor = mkOption {
      type = types.enum [ "nvim" ];
      default = "nvim";
    };
    vm = mkEnableOption "virtualisation packges/service";
  };

  config = mkIf cfg.enable (mkMerge [
    # 1. System-wide features
    {
      features.container = {
        enable = true;
        # runtime = "podman";
      };
      features.vm.enable = true;
      environment.variables.EDITOR = cfg.editor;

    }

    # 2. Home-manager features
    (mkRoleHome config "dev" (user: {
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
        ]);
    }))

    # 3. Assign additional user roles
    {
      users.users = genAttrs cfg.users (user: {
        extraGroups = optional cfg.vm "kvm";
      });
    }
  ]);
}
