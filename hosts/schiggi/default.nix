{
  config,
  ...
}:
with config.myUsers;
{
  imports = [
    ./hardware-configuration.nix
    ../../lib/user-manager.nix
    ../../users/dt.nix
    ../../modules/system
    ../../modules/roles/dev.nix
    ../../modules/roles/core.nix
    ../../modules/roles/peripherals.nix
    ../../modules/features/netbird.nix
  ];

  netbird-wt0 = {
    enable = true;
    setupKeyFile = "/etc/netbird-wt0/setup-key";
  };

  role = {
    core = {
      enable = true;
      users = [ dt.name ];
      ssh.enable = true;
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
      vpn = {
        enable = true;
        vendor = "mullvad";
      };
    };
  };

  networking.hostName = "schiggi";

  # Do not change!
  system.stateVersion = "25.11";
}
