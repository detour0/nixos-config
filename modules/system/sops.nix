{ config, inputs, ... }:
let
  secretsDir = inputs.nix-secrets.outPath;
in
{
  sops = {
    defaultSopsFile = "${secretsDir}/${config.networking.hostName}.yaml";

    secrets = {
      dt_password = {
        sopsFile = "${secretsDir}/global.yaml";
        neededForUsers = true;
      };

      # global_ssh_key = {
      #   sopsFile = "${secretsDir}/global.yaml";
      # };

      # By omission, any secret defined below will automatically look
      # inside your host-specific file (e.g., schiggi.yaml)
      # netbird_setup_key = { };
    };
  };
}
