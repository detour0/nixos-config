{
  config,
  lib,
  ...
}:
with lib;

let
  cfg = config.profile.agents;
in
{
  imports = [
    ../features/hermes.nix
  ];
  options.profile.agents = mkProfileOptions "AI agents" {
    hermes.enable = mkEnableOption "Hermes Agent";
  };
  config = mkMerge [
    {
      features.hermes.enable = true;
    }
    {
      users.users = genAttrs cfg.users (user: {
        extraGroups = optional cfg.hermes.enable "hermes";
      });
    }
  ];
}
