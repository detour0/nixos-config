{ pkgs, ... }:
{
  home.packages = with pkgs; [
    kdePackages.kate
    kdePackages.kcalc
    megasync
    keepassxc
    obsidian
    scrcpy
    obs-studio
  ];
  services = {
    # syncthing.enable = true;

  };
}
