{ config, inputs, ... }:
{
  sops.secrets.crowdsecBouncerKey = {
    mode = "0600";
    owner = "root";
  };

  services.crowdsec-firewall-bouncer = {
    enable = true;
    secrets.apiKeyPath = config.sops.secrets.crowdsecBouncerKey.path;
    settings = {
      api_url = "http://127.0.0.1:8080/";
      mode = "iptables";
      iptables_chains = [
        "INPUT"
        "DOCKER-USER"
      ];
      # disable_ipv6 = true;   # only if Docker's ip6tables is off

      prometheus = {
        enabled = true;
        listen_addr = inputs.nix-secrets.networking.digda.netbirdIp;
        listen_port = 60601;
      };
    };
  };

  # DOCKER-USER only exists once dockerd is up
  systemd.services.crowdsec-firewall-bouncer = {
    after = [ "docker.service" ];
    wants = [ "docker.service" ];
    # The LAPI runs in the crowdsec container and is not up yet at boot; keep retrying
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "10s";
    };
  };
}
