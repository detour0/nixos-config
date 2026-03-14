{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.role.desktop;
in
{
  imports = [ ../features/sway.nix ];

  options.role.desktop = mkRoleOptions "desktop role" {
    environment = mkOption {
      type = types.enum [
        "sway"
        "none"
      ];
      default = "sway";
    };
  };

  config = mkIf cfg.enable {
    # Just turn on the feature.
    # This triggers the OS settings AND the HM settings automatically.
    features.sway.enable = mkIf (cfg.environment == "sway") true;
  };
}
