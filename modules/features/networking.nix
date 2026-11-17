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
    networking = {
      networkmanager.enable = true;
      nameservers = [
        "1.1.1.1" # Cloudflare
        "9.9.9.9" # Quad9
      ];
      firewall = {
        enable = lib.mkDefault true;
        logRefusedPackets = true;
      };
    };

    services.resolved = {
      enable = true;
      settings.Resolve = {
        LLMNR = false;
        MulticastDNS = false;
      };
    };
  };
}
