{
  config,
  lib,
  pkgs,
  ...
}:
let
  workrooms-repo = pkgs.fetchFromGitHub {
    owner = "detour0";
    repo = "sway-workrooms";
    rev = "c1af25956a06efcea6cdd297324460e4cf3c9592";
    sha256 = "sha256-+iRfi/BaEMTWgv40wSAGWs8l6w0OM5swH9IEHV40fVA="; # Nix will complain about this and provide the correct hash
  };
  workrooms-pkg = pkgs.rustPlatform.buildRustPackage {
    pname = "workrooms";
    version = "0.1.0";
    src = workrooms-repo;
    cargoLock.lockFile = "${workrooms-repo}/Cargo.lock";
  };
in
{
  imports = [
    ./waybar.nix
    ./swaylock.nix
    ./rofi.nix
    ./kanshi.nix
    ../wallpapers.nix
    ../nemo.nix
    ../gtkTheme.nix
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

  ];

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # Fixes common issues with GTK 3 apps
  };

  services.cliphist.enable = true;

  dconf.enable = true;
  dconf.settings = {
    "org/nemo/desktop" = {
      show-desktop-icons = false;
    };
  };

  # Enables using the workrooms script from the nix-store without an environment var
  xdg.configFile."sway/script-vars.conf".text = ''
    set $workrooms_bin ${workrooms-pkg}/bin/sway-workrooms
    set $wallpaper ${config.wallpaper}
  '';

  # This creates the link from your home directory to your dotfiles
  xdg.configFile."sway/config".source = lib.mkForce (
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/workspace/nixos-config/dotfiles/sway/config"
  );
  # Temporary solution for checking functionality in a vm (symlink outside vm does not work)
  # xdg.configFile."sway/config".source = lib.mkForce ../../../../dotfiles/sway/config;
}
