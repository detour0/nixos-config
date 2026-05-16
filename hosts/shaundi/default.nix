{
  config,
  ...
}:
with config.myUsers;

let
  netbirdIp = "100.74.131.159";
in
{
  imports = [
    ./hardware-configuration.nix
    ../../lib/user-manager.nix
    ../../users/dt.nix
    ../../modules/system
    ../../modules/profiles/dev.nix
    ../../modules/profiles/desktop.nix
    ../../modules/profiles/core.nix
    ../../modules/profiles/media.nix
    ../../modules/profiles/game.nix
    ../../modules/profiles/peripherals.nix
    ../../modules/features/netbird.nix
  ];

  netbird-wt0 = {
    enable = true;
    ui.enable = true;
    setupKeyFile = "/etc/netbird-wt0/setup-key";
  };

  profile = {
    core = {
      enable = true;
      users = [ dt.name ];
      firewall.disable = false;
      ssh = "client";
      vpn = {
        enable = true;
        vendor = "mullvad";
      };
    };

    dev = {
      enable = true;
      users = [ dt.name ];
      vm.enable = true;
      deploy.enable = true;
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
      browsers = [
        "firefox"
        "librewolf" # TODO: implement
        "brave"
      ];
      office = true;
    };

    peripherals = {
      enable = true;
      users = [ dt.name ];
      bluetooth = true;
      audio = true;
      printing = true;
    };
  };

  networking.hostName = "shaundy";

  # Do not change from 25-05!
  system.stateVersion = "25.05";
}
