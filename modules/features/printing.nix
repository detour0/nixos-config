{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.features.printing;
  printer = inputs.nix-secrets.printers.home.multifunc;
in
{
  options.features.printing.enable = lib.mkEnableOption "CUPS printing service";

  config = lib.mkIf cfg.enable {
    services.printing.enable = true;

    hardware.printers = {
      ensureDefaultPrinter = printer.modelName;
      ensurePrinters = [
        {
          name = printer.modelName;
          deviceUri = "ipp://${printer.ip}/ipp/print";
          model = "everywhere";
          ppdOptions = {
            PageSize = "A4";
            Duplex = "DuplexNoTumble";
          };
        }
      ];
    };

    environment.systemPackages = [ pkgs.system-config-printer ];
  };
}
