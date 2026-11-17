{
  config,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf mkProfileOptions;
  cfg = config.profile.peripherals;
in
{
  imports = [
    ../features/pipewire.nix
    ../features/bluetooth.nix
    ../features/printing.nix
    ../features/scanning.nix
  ];

  options.profile.peripherals = mkProfileOptions config "peripherals profile" {
    bluetooth = mkEnableOption "bluetooth support";
    audio = mkEnableOption "pipewire audio support";
    printing = mkEnableOption "CUPS printing support";
    scanning = mkEnableOption "SANE scanning support";
  };

  config = mkIf cfg.enable {
    features = {
      bluetooth.enable = cfg.bluetooth;
      pipewire.enable = cfg.audio;
      printing.enable = cfg.printing;
      scanning.enable = cfg.scanning;
    };
  };
}
