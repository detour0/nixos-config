{ config, lib, pkgs, ... }:
let
  workrooms-pkg = pkgs.rustPlatform.buildRustPackage {
    pname = "workrooms";
    version = "1.0.1";
    src = ./scripts/workrooms;
    cargo.lockFile = ./scripts/workrooms/Cargo.lock;
    # cargoHash = "sha256-GJnP9T8ds+++dkjVSFZNrVDzBdCEH16QDrQcKSN2gHE=";
  };
in
{
  imports = [
  ./waybar.nix
  ./swaylock.nix
  ./rofi.nix
  ./kanshi.nix
  ../wallpapers.nix
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

# Set dark-mode as default for apps and websites
  dconf.enable = true;
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  # Enables using the workrooms script from the nix-store without an environment var
  xdg.configFile."sway/script-vars.conf".text = ''
    set $workrooms_bin ${workrooms-pkg}/bin/workrooms
    set $wallpaper ${config.wallpaper}
  '';

  # This creates the link from your home directory to your dotfiles
  xdg.configFile."sway/config".source = lib.mkForce 
    (config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/workspace/nixos-config/dotfiles/sway/config");
  # Temporary solution for checking functionality in a vm (symlink outside vm does not work)
  # xdg.configFile."sway/config".source = lib.mkForce ../../../dotfiles/sway/config;
}
