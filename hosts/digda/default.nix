{ config, inputs, ... }:
let
  inherit (config.myUsers) keeper;
in
{
  imports = [
    inputs.disko.nixosModules.disko
    ./hardware-configuration.nix
    ./disk-config.nix
    ../../modules/system
    ../../modules/system/sops-digda.nix
    ../../modules/system/crowdsec-firewall-bouncer.nix
    ../../modules/profiles
    ../../users/keeper.nix
  ];

  networking.hostName = "digda";

  machine = {
    type = "headless";
    bootloader.type = "vServer";
  };

  services.journald.storage = "persistent";

  # Pangolin with Newt
  networking.firewall = {
    allowedTCPPorts = [
      80
      443
    ];
    allowedUDPPorts = [
      21820
      51820
    ];
  };

  features.netbird.enable = true;

  profile = {
    core = {
      enable = true;
      users = [ keeper.name ];
      ssh = {
        state = "server";
        rootKeyPub = inputs.nix-secrets.server.deployPub;
        userKeyPub = inputs.nix-secrets.users.dt.sshPub;
      };
    };

    dev = {
      enable = true;
      users = [ keeper.name ];
      containers = {
        enable = true;
        runtime = "docker";
        dockerRootless = false;
      };
    };
  };

  # Do not change from 26.05!
  system.stateVersion = "26.05";
}
