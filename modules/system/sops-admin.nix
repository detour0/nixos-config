username: # 👈 This transforms the file into a parameterized module function
{
  inputs,
  ...
}:
let
  secretsDir = inputs.nix-secrets.outPath;
in
{
  sops = {
    defaultSopsFile = "${secretsDir}/admin.yaml";
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets = {
      dt_password = {
        neededForUsers = true;
      };
      nb_admin_setup_key = { };
      ssh_github = {
        path = "/home/${username}/.ssh/id_ed25519_github";
        mode = "0600";
        owner = username;
      };
      ssh_deploy = {
        path = "/home/${username}/.ssh/id_ed25519_deploy";
        mode = "0600";
        owner = username;
      };
      ssh_dt = {
        path = "/home/${username}/.ssh/id_ed25519_dt";
        mode = "0600";
        owner = username;
      };
    };
  };

  # Automatically establish the safe directory structure
  systemd.tmpfiles.rules = [
    "d /home/${username}/.ssh 0700 ${username} users - -"
  ];
}
