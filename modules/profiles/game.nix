{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.profile.game;
in
{
  imports = [ ../features/steam.nix ];
  options.profile.game = mkProfileOptions "game profile" { };

  config = mkIf cfg.enable (mkMerge [
    {
      features.steam.enable = true;
    }
  ]);
}
