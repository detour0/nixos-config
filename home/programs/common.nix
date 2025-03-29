{ pkgs, pkgsUnstable, ... }:
{
  home.packages =
    (with pkgs; [
      kdePackages.kate
      kdePackages.kcalc
      megasync
      keepassxc
      obsidian
      scrcpy
      obs-studio
    ])
    ++ (with pkgsUnstable; [
      devenv
    ]);

  programs = {
    tmux = {
      enable = true;
    };
  };
  services = {
    # syncthing.enable = true;

  };
}
