{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.features.scanning;
in
{
  options.features.scanning.enable = lib.mkEnableOption "SANE scanning support";

  config = lib.mkIf cfg.enable {
    hardware.sane.enable = true;

    hardware.sane.brscan4 = {
      enable = true;
      netDevices.home = {
        model = inputs.nix-secrets.printers.home.multifunc.modelName;
        ip = "${inputs.nix-secrets.printers.home.multifunc.ip}";
      };
    };

    environment.systemPackages = [ pkgs.simple-scan ];
  };
}
