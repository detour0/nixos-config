{
  lib,
  config,
  ...
}:
let
  cfg = config.grafana;
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    optionals
    ;
  promCfg = config.prometheus;
  lokiCfg = config.loki;
in
{
  options.grafana = {
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
        "auth.basic".enabled = true;
        # "auth.anonymous" = {
        #   enabled = true;
        #   org_role = "Admin";
        # };
      };

      # Declarative datasource provisioning
      provision = {
        datasources.settings.datasources =
          (optionals promCfg.enable [
            {
              name = "Prometheus";
              type = "prometheus";
              access = "proxy";
              url = "http://${promCfg.listenAddress}:${toString promCfg.port}";
              isDefault = true;
            }
          ])
          ++ (optionals lokiCfg.enable [
            {
              name = "Loki";
              type = "loki";
              access = "proxy";
              url = "http://${lokiCfg.listenAddress}:${toString lokiCfg.port}";
            }
          ]);
      };
    };
  };
}
