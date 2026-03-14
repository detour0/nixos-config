{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.role.dev;
in
{
  imports = [
    ../features/container.nix
  ];

  options.role.dev = mkRoleOptions "dev role" {
    editor = mkOption {
      type = types.str;
      default = "nvim";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # 1. System-wide features
    {
      features.container = {
        enable = true;
        # runtime = "podman";
      };
      environment.variables.EDITOR = cfg.editor;
    }

    # 2. Home-manager configs via mkRoleHome
    (mkRoleHome config "dev" (user: {
      home.packages = with pkgs; [
      ];

      home.shellAliases = {
        # docker = "podman";
        "docker-compose" = "dc";
      };
    }))

    # 3. System users
    {
      users.users = genAttrs cfg.users (user: {
        isNormalUser = true;
        extraGroups = [ "wheel" ]; # wheel for sudo
      });
    }
  ]);
}
