{
  lib,
  config,
  ...
}:
let
  cfg = config.loki;
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    ;
in
{
  options.loki = {
    enable = mkEnableOption "Loki log aggregation server";

    listenAddress = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Address to listen on.";
    };

    port = mkOption {
      type = types.port;
      default = 3100;
      description = "Port to listen on.";
    };
  };

  config = mkIf cfg.enable {
    services.loki = {
      enable = true;

      configuration = {
        server = {
          http_listen_address = cfg.listenAddress;
          http_listen_port = cfg.port;
          grpc_listen_address = "127.0.0.1"; # Secure gRPC locally
          grpc_listen_port = 9096;
        };

        # Modern schema for better performance
        schema_config = {
          configs = [
            {
              from = "2024-01-01";
              store = "tsdb";
              object_store = "filesystem";
              schema = "v13";
              index = {
                prefix = "index_";
                period = "24h";
              };
            }
          ];
        };

        # Simple filesystem storage (easily migrate to S3 later)
        storage_config = {
          filesystem = {
            directory = "/var/lib/loki/chunks";
          };
        };

        limits_config = {
          reject_old_samples = true;
          reject_old_samples_max_age = "168h";
          retention_period = "1488"; # 62 days
        };

        compactor = {
          working_directory = "/var/lib/loki/compactor";
          delete_request_store = "filesystem";
          retention_enabled = true;
          retention_delete_delay = "2h";
        };
      };
    };
  };
}
