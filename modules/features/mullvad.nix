{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.mullvad;
in
{
  options.features.mullvad.enable = lib.mkEnableOption "mullvad vpn";

  config = lib.mkIf cfg.enable {
    services = {
      mullvad-vpn.enable = true;
      # The default package is the CLI only; this one has the GUI
      mullvad-vpn.package = pkgs.mullvad-vpn;
      resolved.enable = true;
    };
  };
}
