{
  config,
  pkgs,
  inputs,
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
  ];

  role.dev = {
    enable = true;
    users = [ dt.name ];
  };

  networking.hostName = "schiggi";

  # Do not change!
  system.stateVersion = "25.11";
}
