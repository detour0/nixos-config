{ config, lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    mkProfileOptions
    types
    ;
  cfg = config.profile.monitor;
  localhost = "127.0.0.1";
in
{
  imports = [
    ../server/grafana.nix
    ../server/prometheus.nix
    ../server/loki.nix
  ];

  options.profile.monitor = mkProfileOptions config "Monitor stack graf/prom/loki" {
    localhost = mkEnableOption "Monitor stack on same host";
    listenAddress = mkOption {
      type = types.str;
      default = localhost;
    };
  };

  config = mkIf cfg.enable {
    server = {
      grafana = {
        enable = true;
        inherit (cfg) listenAddress;
      };
      prometheus = {
        enable = true;
        listenAddress = mkIf cfg.localhost localhost;
      };
      loki = {
        enable = false;
        listenAddress = mkIf cfg.localhost localhost;
      };
    };
  };
}
