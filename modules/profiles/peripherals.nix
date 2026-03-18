{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.profile.peripherals;
in
{
  imports = [
    ../features/pipewire.nix
    ../features/bluetooth.nix
    ../features/mullvad.nix
    ../features/printing.nix
  ];

  options.profile.peripherals = mkProfileOptions "peripherals profile" {
    bluetooth = mkEnableOption "bluetooth support";
    audio = mkEnableOption "pipewire audio support";
    printing = mkEnableOption "CUPS printing support";
  };

  config = mkIf cfg.enable (mkMerge [
    # --- System-wide Feature Toggles ---
    {
      features = {

        # Conditionally enable based on options
        bluetooth.enable = cfg.bluetooth;
        pipewire.enable = cfg.audio;
        printing.enable = cfg.printing;
      };
    }

  ]);
}
