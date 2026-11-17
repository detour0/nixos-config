{
  config,
  lib,
  ...
}:

let
  inherit (lib) mkIf mkProfileOptions;
  cfg = config.profile.game;
in
{
  imports = [ ../features/steam.nix ];

  options.profile.game = mkProfileOptions config "game profile" { };

  config = mkIf cfg.enable {
    features.steam.enable = true;
  };
}
