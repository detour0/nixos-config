{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.profile.media;
in
{
  options.profile.media = mkProfileOptions "media profile" { };

  config = mkIf cfg.enable (mkMerge [
    {
    }
    (mkProfileHome config "media" (user: {
      home.packages = with pkgs; [
        scrcpy
        obs-studio
        yt-dlp
        mpv
      ];
    }))
  ]);
}
