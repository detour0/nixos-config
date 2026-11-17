{ config, lib, ... }:
let
  cfg = config.features.steam;
in
{
  options.features.steam.enable = lib.mkEnableOption "steam game launcher";

  # Remote play, dedicated servers and local game transfers keep their firewall ports closed (the default)
  config = lib.mkIf cfg.enable {
    programs.steam.enable = true;
  };
}
