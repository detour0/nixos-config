{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    kdePackages.kate
    megasync
    keepassxc
  ];

  services = {
    # syncthing.enable = true;

  };
}
