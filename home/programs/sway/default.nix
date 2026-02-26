{ config, lib, pkgs, ... }:
let
  workrooms-pkg = pkgs.rustPlatform.buildRustPackage {
    pname = "workrooms";
    version = "1.0.1";
    src = ./scripts/workrooms;
    cargoHash = lib.fakeHash;
  };
in
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
    speedcrunch
    # swaybg

    autotiling
    pavucontrol
    overskride

    kdePackages.qtsvg
    kdePackages.dolphin
    # kdePackages.kio # needed since 25.11
    # kdePackages.kio-fuse #to mount remote filesystems via FUSE
    # kdePackages.kio-extras #extra protocols support (sftp, fish and more)
  ];

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # Fixes common issues with GTK 3 apps
  };

  services.cliphist.enable = true;

  # Enables using the workrooms script from the nix-store without an environment var
  xdg.configFile."sway/workroom-vars.conf".text = ''
    set $workrooms-bin ${workrooms-pkg}/bin/workroom
  '';

  # This creates the link from your home directory to your dotfiles
  xdg.configFile."sway/config".source = lib.mkForce 
    (config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/workspace/nixos-config/dotfiles/sway/config");
  # Temporary solution for checking functionality in a vm (symlink outside vm does not work)
  # xdg.configFile."sway/config".source = lib.mkForce ../../../dotfiles/sway/config;
}
