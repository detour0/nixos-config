{
  config,
  lib,
  ...
}:
let
  cfg = config.features.bluetooth;
in
{
  options.features.bluetooth.enable = lib.mkEnableOption "bluetooth";

  config = lib.mkIf cfg.enable {
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
  };
}
