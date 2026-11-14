{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.features.printing;
in
{
  options.features.printing.enable = lib.mkEnableOption "CUPS printing service";

  config = lib.mkIf cfg.enable {
    services.printing.enable = true;

    hardware.printers = {
      ensureDefaultPrinter = inputs.nix-secrets.printers.home.multifunc.modelName;
      ensurePrinters = [
        {
          name = inputs.nix-secrets.printers.home.multifunc.modelName; # "MFC-J5320DW";
          deviceUri = "ipp://${inputs.nix-secrets.printers.home.multifunc.ip}/ipp/print";
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
