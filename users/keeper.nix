{
  config,
  inputs,
  pkgs,
  ...
}:
{
  myUsers.keeper = {
    shell = pkgs.zsh;
    hashedPasswordFile = config.sops.secrets.keeper_password.path;
    description = "The Gatekeeper";
    extraGroups = [ "wheel" ];
    inherit (inputs.nix-secrets.users.dt.github) gitName gitEmail;
  };
}
