{ config, pkgs, lib, ... }:
{
  services.kanshi = {
    enable = true;
    systemdTarget = "sway-session.target"; 
  };

  # Symlink the config file
  xdg.configFile."kanshi/config".source = config.lib.file.mkOutOfStoreSymlink 
    "${config.home.homeDirectory}/workspace/nixos-config/dotfiles/kanshi/config";
}
