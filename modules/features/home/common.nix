# Nonfunctional; to be cleaned up later
{ pkgs, pkgsUnstable, ... }:
{
  home.packages =
    (with pkgs; [
      # kdePackages.kate
      # kdePackages.kcalc
      megasync
      keepassxc
      obsidian
      scrcpy
      obs-studio
      plocate
      yt-dlp
      git-filter-repo
      tree
      mpv
      # smplayer
      jq

      libreoffice-fresh
      hunspell
      hunspellDicts.de_DE
      hunspellDicts.en_US
      hunspellDicts.en_US
    ])
    ++ (with pkgsUnstable; [
      devenv
      # nvchad
    ]);

  services = {
    # syncthing.enable = true;

  };
}
