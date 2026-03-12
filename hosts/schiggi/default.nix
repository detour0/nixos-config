{
  pkgs,
  inputs,
  mkUser,
  ...
}:

{
  imports = [
    ../../modules/features/container.nix
  ];

  networking.hostName = "schiggi";

  # Do not change from 25-05!
  system.stateVersion = "25.11";
}
