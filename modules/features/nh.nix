{ 
     # Finally less nix-command-mess
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/${username}/nixos-config"; # sets NH_OS_FLAKE variable for you
  };
}