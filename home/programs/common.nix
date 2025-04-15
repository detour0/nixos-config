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
      plocate
    ])
    ++ (with pkgsUnstable; [
      devenv
    ]);

  programs = {
    tmux = {
      enable = true;
    };
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
