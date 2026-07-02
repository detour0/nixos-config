{
  config,
  lib,
  ...
}:
{
  services = {
    postgresql = {
      enable = true;
      # ... database setups, databases for nextcloud, paperless, etc.
      ensureUsers = [
        {
          inherit (config.myUsers.dt) name;
          ensureClauses.createdb = true;
        }
        {
          name = "n8n";
          # This automatically makes the 'n8n' user the owner of the 'n8n' database
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [
        "n8n"
        "paperless"
      ];
      authentication = ''
        host paperless paperless 172.18.0.0/16 scram-sha-256
        host n8n n8n 172.18.0.0/16 scram-sha-256
      '';
      settings = {
        listen_addresses = lib.mkForce "*";
      };
    };

    # Dedicated PostgreSQL stats exporter
    prometheus.exporters.postgres = {
      enable = true;
      runAsLocalSuperUser = true; # Allows the exporter to read database metrics tables safely
      listenAddress = "127.0.0.1";
      port = 9187;
    };

    # Register itself to Prometheus dynamically
    prometheus.scrapeConfigs = lib.mkIf config.services.prometheus.enable [
      {
        job_name = "postgres-db";
        static_configs = [ { targets = [ "127.0.0.1:9187" ]; } ];
      }
    ];
  };
}
