{
  config,
  lib,
  ...
}:
let
  cfg = config.features.networking;
in
{
  options.features.networking.enable = lib.mkEnableOption "networking";

  config = lib.mkIf cfg.enable {
    # Enable networking
    networking = {
      networkmanager.enable = true;
      firewall = {
        allowedTCPPorts = [ ]; # 80 HTTP/ 443 HTTPS
        enable = true;
      };
    };
  };
}
