{ inputs, ... }:
let
  user = "dt";
  key = name: {
    path = "/home/${user}/.ssh/id_ed25519_${name}";
    mode = "0600";
    owner = user;
  };
in
{
  sops = {
    defaultSopsFile = "${inputs.nix-secrets}/admin.yaml";

    secrets = {
      dt_password.neededForUsers = true;
      nb_admin_setup_key = { };
      ssh_github = key "github";
      ssh_deploy = key "deploy";
      ssh_dt = key "dt";
    };
  };

  systemd.tmpfiles.rules = [ "d /home/${user}/.ssh 0700 ${user} users - -" ];
}
