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
      yazi

      libreoffice-fresh
      hunspell
      hunspellDicts.de_DE
      hunspellDicts.en_US
      hunspellDicts.en_US
    ])
    ++ (with pkgsUnstable; [
      devenv
      nvchad
    ]);

  programs = {
    chromium = {
      enable = true;
      package = pkgs.brave;
      extensions = [
        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
      ];
      # commandLineArgs = [
      #   "--disable-features=WebRtcAllowInputVolumeAdjustment"
      # ];
    };
  };
  services = {
    # syncthing.enable = true;

  };
}
