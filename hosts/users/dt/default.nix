{
  pkgs,
  lib,
  username,
  ...
}:
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    password = "";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  import ./home.nix { username }  
}