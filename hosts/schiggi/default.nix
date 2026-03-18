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
    ../../modules/profiles/dev.nix
    ../../modules/profiles/core.nix
    ../../modules/profiles/peripherals.nix
    ../../modules/features/netbird.nix
  ];

  netbird-wt0 = {
    enable = true;
    setupKeyFile = "/etc/netbird-wt0/setup-key";
  };

  profile = {
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
    };
  };

  networking.hostName = "schiggi";

  # Do not change!
  system.stateVersion = "25.11";
}
