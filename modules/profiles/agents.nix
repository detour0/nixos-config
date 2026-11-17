{
  config,
  lib,
  ...
}:

let
  inherit (lib)
    genAttrs
    mkEnableOption
    mkIf
    mkProfileOptions
    optional
    ;
  cfg = config.profile.agents;
in
{
  imports = [ ../features/hermes.nix ];

  options.profile.agents = mkProfileOptions config "AI agents" {
    hermes.enable = mkEnableOption "Hermes Agent";
  };

  config = mkIf cfg.enable {
    features.hermes.enable = cfg.hermes.enable;

    users.users = genAttrs cfg.users (_: {
      extraGroups = optional cfg.hermes.enable "hermes";
    });
  };
}
