{ config, lib, ... }:
let
  cfg = config.profile.monitor;

  inherit (lib)
    mkProfileOptions
    mkIf
    mkOption
    mkEnableOption
    types
    ;

  localhost = "127.0.0.1";
in
{
  imports = [
    ../server/grafana.nix
    ../server/prometheus.nix
    ../server/loki.nix
  ];

  options.profile.monitor = mkProfileOptions "Monitor stack graf/prom/loki" {
    localhost = mkEnableOption "Monitor stack on same host";
    listenAddress = mkOption {
      type = types.str;
      default = localhost;
    };

  };

  config = mkIf cfg.enable {
    grafana = {
      enable = true;
      inherit (cfg) listenAddress;
    };
    prometheus = {
      enable = true;
      listenAddress = mkIf cfg.localhost localhost;
    };
    loki = {
      enable = true;
      listenAddress = mkIf cfg.localhost localhost;
    };
  };
}
