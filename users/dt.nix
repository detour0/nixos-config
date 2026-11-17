{
  config,
  inputs,
  pkgs,
  ...
}:
{
  myUsers.dt = {
    shell = pkgs.zsh;
    hashedPasswordFile = config.sops.secrets.dt_password.path;
    description = "detour0";
    extraGroups = [
      "wheel"
      "networkmanager"
      "netbird-wt0"
    ];
    inherit (inputs.nix-secrets.users.dt.github) gitName gitEmail;
  };
}
