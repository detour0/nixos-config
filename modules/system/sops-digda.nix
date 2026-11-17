{ inputs, ... }:
{
  sops = {
    defaultSopsFile = "${inputs.nix-secrets}/digda.yaml";

    secrets = {
      keeper_password.neededForUsers = true;
      # Key for reading the GitHub secrets repo
      ssh_secrets_read = {
        path = "/var/lib/ssh_automation/id_ed25519_read";
        mode = "0600";
        owner = "root";
      };
    };
  };

  systemd.tmpfiles.rules = [ "d /root/.ssh 0700 root root - -" ];
}
