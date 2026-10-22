{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (config.myUsers) dt;
in
{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix

    ../../lib/user-manager.nix
    ../../users/dt.nix
    ../../modules/system
    ../../modules/system/sops-server.nix

    ../../modules/profiles/dev.nix
    ../../modules/profiles/core.nix

    ../../modules/features/netbird.nix
  ];

  myUsers.dt.enable = true;
  bootloader.type = "vServer";

  # Pangolin with Newt
  networking.firewall = {
    allowedTCPPorts = [
      80
      443
    ];
    allowedUDPPorts = [
      21820
      51820
    ];
  };

  # Enable non-Netbird SSH access
  services.openssh.openFirewall = lib.mkForce true;

  netbird-wt0 = {
    enable = true;
    # setupKeyFile = config.sops.secrets.nb_server_setup_key.path;
  };

  profile = {
    core = {
      enable = true;
      users = [ dt.name ];
      # firewall.disable = true;
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
  };

  networking.hostName = "digda";

  # Do not change!
  system.stateVersion = "26.05";
}
