{
  inputs,
  ...
}:
let
  secretsDir = inputs.nix-secrets.outPath;
in
{
  sops = {
    defaultSopsFile = "${secretsDir}/server.yaml";
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets = {
      dt_password = {
        neededForUsers = true;
      };
      nb_server_setup_key = { };
      grafana_key = { };
      ssh_secrets_read = {
        path = "/var/lib/ssh_automation/id_ed25519_read";
        mode = "0600";
        owner = "root";
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /root/.ssh 0700 root root - -"
  ];
}
