{ config, lib, pkgs, ... }:
{
  imports = [
  ./waybar.nix
  ./swaylock.nix
  ./rofi.nix
  ./kanshi.nix
  ];

  home.packages = with pkgs; [
    grim # screenshot functionality
    slurp # screenshot functionality, region selection
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    mako # notification system developed by swaywm maintainer
    wdisplays

    autotiling
    pavucontrol

    kdePackages.qtsvg
    kdePackages.dolphin
    # kdePackages.kio # needed since 25.11
    # kdePackages.kio-fuse #to mount remote filesystems via FUSE
    # kdePackages.kio-extras #extra protocols support (sftp, fish and more)
  ];

  wayland.windowManager.sway = {
    enable = true;
    systemd.enable = true;
    systemd.dbusImplementation = "dbus";
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
  };
    # This creates the link from your home directory to your dotfiles
    xdg.configFile."sway/config".source = lib.mkForce 
      (config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/workspace/nixos-config/dotfiles/sway/config");
    # Temporary solution for checking functionality in a vm (symlink outside vm does not work)
    # xdg.configFile."sway/config".source = lib.mkForce ../../../dotfiles/sway/config;
}
