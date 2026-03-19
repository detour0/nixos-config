{
  lib,
  config,
  ...
}:
let
  cfg = config.prometheus;
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    ;
in
{
  options.prometheus = {
    enable = mkEnableOption "Prometheus monitoring server";

    listenAddress = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Address to listen on.";
    };

    port = mkOption {
      type = types.port;
      default = 9090;
      description = "Port to listen on.";
    };

    retentionTime = mkOption {
      type = types.str;
      default = "60d";
      description = "How long to retain metrics.";
    };
  };

  config = mkIf cfg.enable {
    services.prometheus = {
      enable = true;

      extraFlags = [ "--web.enable-remote-write-receiver" ];

      inherit (cfg) retentionTime listenAddress port;

      # Basic scrape config for Prometheus to scrape itself (health check)
      scrapeConfigs = [
        {
          job_name = "prometheus";
          static_configs = [ { targets = [ "localhost:${toString cfg.port}" ]; } ];
        }
      ];
    };
  };
}
