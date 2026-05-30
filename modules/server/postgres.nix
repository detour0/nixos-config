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
