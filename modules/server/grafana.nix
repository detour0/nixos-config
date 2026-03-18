{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.grafana;
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    ;
  promCfg = config.services.prometheus;
  lokiCfg = config.services.loki;
in
{
  options.services.grafana = {
    enable = mkEnableOption "Grafana visualization server";

    listenAddress = mkOption {
      type = types.str;
      default = "127.0.0.1";
    };

    port = mkOption {
      type = types.port;
      default = 3000;
    };
  };

  config = mkIf cfg.enable {
    services.grafana = {
      enable = true;

      settings = {
        server = {
          http_addr = cfg.listenAddress;
          http_port = cfg.port;
        };

        # Disable login form for homelab simplicity, or keep enabled
        "auth.basic".enabled = false;
        "auth.anonymous" = {
          enabled = true;
          org_role = "Admin"; # Adjust for enterprise security practice
        };
      };

      # Declarative datasource provisioning
      provision = {
        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            access = "proxy";
            url = "http://${promCfg.listenAddress}:${toString promCfg.port}";
            isDefault = true;
          }
          {
            name = "Loki";
            type = "loki";
            access = "proxy";
            url = "http://${lokiCfg.listenAddress}:${toString lokiCfg.port}";
          }
        ];
      };
    };
  };
}
