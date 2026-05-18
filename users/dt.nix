{ config, inputs, ... }:
{
  myUsers.dt = {
    # enable = true;
    name = "dt";
    hashedPasswordFile = config.sops.secrets.dt_password.path;
    description = "detour0";
    extraGroups = [
      "wheel"
      "networkmanager"
      "netbird-wt0"
    ];

    # Custom metadata for Home Manager
    inherit (inputs.nix-secrets.users.dt.github) gitName gitEmail;
  };
}
