{
  config,
  ...
}:
with config.myUsers;

let
  netbirdIp = "100.74.11.59";
in
{
  imports = [
    ./hardware-configuration.nix
    ../../lib/user-manager.nix
    ../../users/dt.nix
    ../../modules/system
    ../../modules/profiles/dev.nix
    ../../modules/profiles/core.nix
    ../../modules/profiles/peripherals.nix
    ../../modules/features/netbird.nix
    ../../modules/profiles/desktop.nix

    ../../modules/profiles/monitor.nix
  ];

  netbird-wt0 = {
    enable = true;
    setupKeyFile = "/etc/netbird-wt0/setup-key";
  };

  profile = {
    monitor = {
      enable = true;
      localhost = true;
      listenAddress = netbirdIp;
    };

    core = {
      enable = true;
      users = [ dt.name ];
      ssh = "server";
    };

    dev = {
      enable = true;
      users = [ dt.name ];
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
