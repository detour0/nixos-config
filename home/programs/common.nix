{ pkgs, ... }:
{
  home.packages = with pkgs; [
    kdePackages.kate
    megasync
    keepassxc
    obsidian

  ];
  services = {
    # syncthing.enable = true;

  };
}
