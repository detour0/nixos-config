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
    ../../modules/roles/desktop.nix
    ../../modules/roles/core.nix
    ../../modules/roles/media.nix
    ../../modules/roles/game.nix
    ../../modules/roles/peripherals.nix
  ];

  role = {
    core = {
      enable = true;
      users = [ dt.name ];
    };

    dev = {
      enable = true;
      users = [ dt.name ];
      vm = true;
    };

    media = {
      enable = true;
      users = [ dt.name ];
    };

    game = {
      enable = true;
      users = [ dt.name ];
    };

    desktop = {
      enable = true;
      users = [ dt.name ];
      environment = "sway";
    };

    peripherals = {
      enable = true;
      users = [ dt.name ];
      bluetooth = true;
      audio = true;
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
