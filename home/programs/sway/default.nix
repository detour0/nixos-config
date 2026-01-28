{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    grim # screenshot functionality
    slurp # screenshot functionality, region selection
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    mako # notification system developed by swaywm maintainer
    # sway
  ];

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # Fixes common issues with GTK 3 apps
    # config = rec {
    #   modifier = "Mod4";
    #   # Set default terminal
    #   terminal = "wezTerm"; 
    #   startup = [
    #     # Launch Firefox on start
    #     # { command = "firefox"; }
    #   ];
    # };
    config = null;
  };
      # This creates the link from your home directory to your dotfiles
    xdg.configFile."sway/config".source = lib.mkForce 
      (config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/workspace/nixos-config/dotfiles/sway/config");
}
