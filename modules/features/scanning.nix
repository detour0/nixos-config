{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.features.scanning;
  printer = inputs.nix-secrets.printers.home.multifunc;
in
{
  options.features.scanning.enable = lib.mkEnableOption "SANE scanning support";

  config = lib.mkIf cfg.enable {
    hardware.sane = {
      enable = true;
      brscan4 = {
        enable = true;
        netDevices.home = {
          model = printer.modelName;
          inherit (printer) ip;
        };
      };
    };

    environment.systemPackages = [ pkgs.simple-scan ];
  };
}
