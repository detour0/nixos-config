{
  config,
  inputs,
  ...
}:
let
  inherit (config.myUsers) keeper;
in
{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix

    ../../lib/user-manager.nix
    ../../users/keeper.nix
    ../../modules/system
    ../../modules/system/sops-digda.nix
    ../../modules/system/crowdsec-firewall-bouncer.nix

    ../../modules/profiles/dev.nix
    ../../modules/profiles/core.nix

    ../../modules/features/netbird.nix
  ];

  myUsers.keeper.enable = true;
  services.journald.storage = "persistent";
  machine = {
    type = "headless";
    bootloader.type = "vServer";
  };

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

  netbird-wt0 = {
    enable = true;
    # setupKeyFile = config.sops.secrets.nb_server_setup_key.path;
  };

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

  networking.hostName = "digda";

  # Do not change!
  system.stateVersion = "26.05";
}
