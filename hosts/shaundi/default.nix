{
  config,
  inputs,
  pkgs,
  ...
}:
let
  inherit (config.myUsers) dt;
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system
    ../../modules/system/sops-admin.nix
    ../../modules/profiles
    ../../users/dt.nix
  ];

  networking.hostName = "shaundi";

  machine = {
    type = "client";
    bootloader.type = "dedicated";
  };

  # For pangolin setup
  networking.hosts.${inputs.nix-secrets.networking.digda.ip} = [
    "pangolin.${inputs.nix-secrets.domain}"
  ];

  environment = {
    systemPackages = [ pkgs.pangolin-cli ];
    localBinInPath = true;
  };
  programs.nix-ld.enable = true;

  features.netbird = {
    enable = true;
    setupKeyFile = config.sops.secrets.nb_admin_setup_key.path;
  };

  profile = {
    core = {
      enable = true;
      users = [ dt.name ];
      ssh.state = "client";
      vpn = {
        enable = true;
        vendor = "mullvad";
      };
    };

    android = {
      enable = true;
      users = [ dt.name ];
    };

    dev = {
      enable = true;
      users = [ dt.name ];
      vm.enable = true;
      deploy.enable = true;
      containers = {
        enable = true;
        runtime = "docker";
        dockerRootless = false;
      };
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
      agent = "hermes";
      office = true;
      dictation = true;
    };

    peripherals = {
      enable = true;
      users = [ dt.name ];
      bluetooth = true;
      audio = true;
      printing = true;
      scanning = true;
    };
  };

  # Do not change from 25.05!
  system.stateVersion = "25.05";
}
