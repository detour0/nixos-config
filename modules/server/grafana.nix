{
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.grafana;
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    optional
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

    sops.secrets = {
      grafana_key = {
        owner = "grafana";
        group = "grafana";
        mode = "0440";
      };
      grafana_oauth_client_secret = {
        owner = "grafana";
        group = "grafana";
        mode = "0440";
      };
    };

    services.grafana = {
      enable = true;

      settings = {
        security.secret_key = "$__file{${config.sops.secrets.grafana_key.path}}";
        server = {
          http_addr = cfg.listenAddress;
          http_port = cfg.port;
          protocol = "http"; # TLS termination belongs to Traefik
          domain = "grafana.${inputs.nix-secrets.domain}";
          root_url = "https://grafana.${inputs.nix-secrets.domain}";
        };

        # "auth.basic".enabled = true;
        # "auth.anonymous" = {
        #   enabled = true;
        #   org_role = "Admin";
        # };
        "auth" = {
          signout_redirect_url = "https://authentik.${inputs.nix-secrets.domain}/application/o/grafana/end-session/";
          oauth_auto_login = true;
        };
        "auth.generic_oauth" = {
          use_pkce = true;
          name = "authentik";
          enabled = true;
          client_id = inputs.nix-secrets.grafana.clientId;
          client_secret = "$__file{${config.sops.secrets.grafana_oauth_client_secret.path}}";
          scopes = "openid email profile entitlements";
          auth_url = "https://authentik.${inputs.nix-secrets.domain}/application/o/authorize/";
          token_url = "https://authentik.${inputs.nix-secrets.domain}/application/o/token/";
          api_url = "https://authentik.${inputs.nix-secrets.domain}/application/o/userinfo/";
          # # Optionally map user entitlements to Grafana roles
          # role_attribute_path = contains(entitlements[*], 'Grafana Admins') && 'Admin' || contains(entitlements[*], 'Grafana Editors') && 'Editor' || 'Viewer'
        };
      };

      # Declarative datasource provisioning
      provision = {
        datasources.settings.datasources =
          (optional promCfg.enable {
            name = "Prometheus";
            type = "prometheus";
            access = "proxy";
            url = "http://${promCfg.listenAddress}:${toString promCfg.port}";
            isDefault = true;
          })
          ++ (optional lokiCfg.enable {
            name = "Loki";
            type = "loki";
            access = "proxy";
            url = "http://${lokiCfg.listenAddress}:${toString lokiCfg.port}";
          });
      };
    };
  };
}
