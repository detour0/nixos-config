{
  config,
  lib,
  ...
}:
let
  cfg = config.features.printing;
in
{
  options.features.printing.enable = lib.mkEnableOption "cups printing service";

  config = lib.mkIf cfg.enable {
    # Enable CUPS to print documents
    services.printing.enable = true;
  };
}
