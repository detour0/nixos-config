{
  config,
  inputs,
  ...
}:
let
  inherit (config.myUsers) dt;
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system
    ../../modules/system/sops-server.nix
    ../../modules/profiles
    ../../modules/server/postgres.nix
    ../../users/dt.nix
  ];

  networking.hostName = "schiggi";

  machine = {
    type = "headless";
    bootloader.type = "dedicated";
  };

  features.netbird = {
    enable = true;
    setupKeyFile = config.sops.secrets.nb_server_setup_key.path;
  };

  server.postgres.user = dt.name;

  profile = {
    monitor = {
      enable = true;
      users = [ dt.name ];
      localhost = true;
      listenAddress = inputs.nix-secrets.networking.schiggi.netbirdIp;
    };

    core = {
      enable = true;
      users = [ dt.name ];
      ssh = {
        state = "server";
        rootKeyPub = inputs.nix-secrets.server.deployPub;
        userKeyPub = inputs.nix-secrets.users.dt.sshPub;
      };
    };

    dev = {
      enable = true;
      users = [ dt.name ];
      containers = {
        enable = true;
        runtime = "docker";
        dockerRootless = false;
      };
    };

    peripherals = {
      enable = true;
      users = [ dt.name ];
      printing = true;
    };
  };

  # Do not change from 25.11!
  system.stateVersion = "25.11";
}
