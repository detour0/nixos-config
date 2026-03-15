{ config, lib, ... }:
let
  cfg = config.features.steam;
in
{
  options.features.steam.enable = lib.mkEnableOption "steam game launcher";

  config = lib.mkIf cfg.enable {

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };
  };
}
