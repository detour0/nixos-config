{ pkgs, pkgsUnstable, ... }:
{
  home.packages = ( with pkgs; [
    kdePackages.kate
    kdePackages.kcalc
    megasync
    keepassxc
    obsidian
    scrcpy
    obs-studio
  ]) ++ ( with pkgsUnstable; [
    devenv
  ]);

  services = {
    # syncthing.enable = true;

  };
}
