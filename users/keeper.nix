{
  config,
  pkgs,
  inputs,
  ...
}:
{
  myUsers.keeper = {
    # enable = true;
    name = "keeper";
    shell = pkgs.zsh;
    hashedPasswordFile = config.sops.secrets.keeper_password.path;
    description = "The Gatekeeper";
    extraGroups = [
      "wheel"
      # "networkmanager"
      # "netbird-wt0"
    ];
    # Custom metadata for Home Manager
    inherit (inputs.nix-secrets.users.dt.github) gitName gitEmail;
  };
}
