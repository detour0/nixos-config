{
  config,
  lib,
  ...
}:
let
  cfg = config.features.networking;
  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  options.features.networking = {
    enable = mkEnableOption "networking";
    firewall.enable = mkEnableOption "firewall";
  };

  config = mkIf cfg.enable {
    # Enable networking
    networking = {
      networkmanager.enable = true;
      firewall = {
        inherit (cfg.firewall) enable;
        allowedTCPPorts = [ ]; # 80 HTTP/ 443 HTTPS
        allowedUDPPorts = [ ];
      };
    };
  };
}
