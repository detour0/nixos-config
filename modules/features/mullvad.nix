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
      mullvad-vpn.package = pkgs.mullvad-vpn;
      resolved.enable = true;
    };
  };
}
