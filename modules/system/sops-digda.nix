{
  inputs,
  ...
}:
let
  secretsDir = inputs.nix-secrets.outPath;
in
{
  sops = {
    defaultSopsFile = "${secretsDir}/digda.yaml";
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets = {
      keeper_password = {
        neededForUsers = true;
      };
      # Key for reading Github secrets repo
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
