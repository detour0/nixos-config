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
    ../../lib/user-manager.nix
    ../../users/dt.nix
    ../../modules/system
    ../../modules/system/sops-server.nix
    ../../modules/profiles/dev.nix
    ../../modules/profiles/core.nix
    ../../modules/profiles/peripherals.nix
    ../../modules/features/netbird.nix
    ../../modules/profiles/desktop.nix

    ../../modules/profiles/monitor.nix
    ../../modules/server/postgres.nix
  ];

  myUsers.dt.enable = true;

  netbird-wt0 = {
    enable = true;
    setupKeyFile = config.sops.secrets.nb_server_setup_key.path;
  };

  profile = {
    monitor = {
      enable = true;
      localhost = true;
      listenAddress = inputs.nix-secrets.networking.schiggi.netbirdIp;
    };

    core = {
      enable = true;
      users = [ dt.name ];
      # firewall.disable = true;
      ssh = {
        state = "server";
        rootKey = inputs.nix-secrets.server.deployPub;
        userKey = inputs.nix-secrets.users.dt.sshPub;
      };
    };

    dev = {
      enable = true;
      users = [ dt.name ];
      dockerRootless = false;
    };

    peripherals = {
      enable = true;
      users = [ dt.name ];
      printing = true;
    };
  };

  networking.hostName = "schiggi";

  # Do not change!
  system.stateVersion = "25.11";
}
