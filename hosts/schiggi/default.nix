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
      enable = false;
      localhost = true;
      listenAddress = netbirdIp;
    };

    desktop = {
      enable = true;
      users = [ dt.name ];
      environment = "sway";
    };

    core = {
      enable = true;
      users = [ dt.name ];
      firewall.disable = false;
      ssh = "server";
    };

    dev = {
      enable = true;
      users = [ dt.name ];
      vm = true;
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
