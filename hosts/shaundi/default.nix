{
  config,
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
    (import ../../modules/system/sops-admin.nix dt.name)
    ../../modules/profiles/dev.nix
    ../../modules/profiles/desktop.nix
    ../../modules/profiles/core.nix
    ../../modules/profiles/media.nix
    ../../modules/profiles/game.nix
    ../../modules/profiles/peripherals.nix
    ../../modules/features/netbird.nix
  ];

  myUsers.dt.enable = true;

  netbird-wt0 = {
    enable = true;
    ui.enable = true;
    setupKeyFile = config.sops.secrets.nb_admin_setup_key.path;
  };

  profile = {
    core = {
      enable = true;
      users = [ dt.name ];
      ssh = {
        state = "client";
      };
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

  networking.hostName = "shaundi";

  # Do not change from 25-05!
  system.stateVersion = "25.05";
}
