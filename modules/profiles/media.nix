{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}:

let
  inherit (lib) mkIf mkProfileHome mkProfileOptions;
  cfg = config.profile.media;
in
{
  options.profile.media = mkProfileOptions config "media profile" { };

  config = mkIf cfg.enable (
    mkProfileHome cfg {
      home.packages = with pkgs; [
        scrcpy
        obs-studio
        yt-dlp
        mpv
        # Jellyfin music client (unstable: 0.22, Wayland built in)
        pkgsUnstable.supersonic
        # keyboard-friendlier Jellyfin client, native (SDL)
        tauon
      ];
    }
  );
}
