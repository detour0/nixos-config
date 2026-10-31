{ config, ... }:
{
  sops.secrets.crowdsecBouncerKey = { };

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
        listen_addr = "100.74.101.103";
        listen_port = 60601;
      };
    };
  };

  # DOCKER-USER only exists once dockerd is up
  systemd.services.crowdsec-firewall-bouncer = {
    after = [ "docker.service" ];
    wants = [ "docker.service" ];
  };
}
