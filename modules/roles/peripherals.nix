{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.role.peripherals;
in
{
  imports = [
    ../features/networking.nix
    ../features/pipewire.nix
    ../features/bluetooth.nix
    ../features/mullvad.nix
    ../features/printing.nix
  ];

  options.role.peripherals = mkRoleOptions "peripherals role" {
    bluetooth = mkEnableOption "bluetooth support";
    audio = mkEnableOption "pipewire audio support";
    printing = mkEnableOption "CUPS printing support";
    vpn = {
      enable = mkEnableOption "VPN support";
      vendor = mkOption {
        type = types.enum [ "mullvad" ];
        default = "mullvad";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # --- System-wide Feature Toggles ---
    {
      # Networking is always on if this role is enabled
      features = {
        networking.enable = true;

        # Conditionally enable based on options
        bluetooth.enable = cfg.bluetooth;
        pipewire.enable = cfg.audio;
        printing.enable = cfg.printing;
      };
    }

    # --- Specific Logic for VPN ---
    (mkIf (cfg.vpn.enable && cfg.vpn.vendor == "mullvad") {
      features.mullvad.enable = true;
    })
  ]);
}
