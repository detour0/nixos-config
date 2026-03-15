{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.role.game;
in
{
  imports = [ ../features/steam.nix ];
  options.role.game = mkRoleOptions "game role" { };

  config = mkIf cfg.enable (mkMerge [
    {
      features.steam.enable = true;
    }
  ]);
}
