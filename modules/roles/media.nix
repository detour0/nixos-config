{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.role.media;
in
{
  options.role.media = mkRoleOptions "media role" { };

  config = mkIf cfg.enable (mkMerge [
    {
    }
    (mkRoleHome config "media" (user: {
      home.packages = with pkgs; [
        scrcpy
        obs-studio
        yt-dlp
        mpv
      ];
    }))
  ]);
}
