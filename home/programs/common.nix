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
      vdhcoapp
      yt-dlp
    ])
    ++ (with pkgsUnstable; [
      devenv
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
