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
  };

  config = mkIf cfg.enable {
    # Enable networking
    networking = {
      # nftables.enable = true;
      networkmanager.enable = true;

      firewall = {
        enable = lib.mkDefault true;
        allowedTCPPorts = [ ];
        allowedUDPPorts = [ ];
        logRefusedPackets = true;
      };
    };

    services.resolved.enable = true;
    services.resolved.settings.Resolve = {
      LLMNR = false;
      MulticastDNS = false;
    };
  };
}
