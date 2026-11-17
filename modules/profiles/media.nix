{
  config,
  lib,
  pkgs,
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
      ];
    }
  );
}
