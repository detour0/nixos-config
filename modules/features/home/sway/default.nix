{
  config,
  lib,
  pkgs,
  ...
}:
let
  # A change to the tool goes to the upstream repo first, then gets a new rev and hash here
  # (set lib.fakeHash, build, copy the hash from the error)
  workrooms-repo = pkgs.fetchFromGitHub {
    owner = "detour0";
    repo = "sway-workrooms";
    rev = "c1af25956a06efcea6cdd297324460e4cf3c9592";
    hash = "sha256-+iRfi/BaEMTWgv40wSAGWs8l6w0OM5swH9IEHV40fVA=";
  };
  workrooms-pkg = pkgs.rustPlatform.buildRustPackage {
    pname = "workrooms";
    version = "0.1.0";
    src = workrooms-repo;
    cargoLock.lockFile = "${workrooms-repo}/Cargo.lock";
  };
  workrooms = "${workrooms-pkg}/bin/sway-workrooms";

  urgent-focus = pkgs.writeShellApplication {
    name = "sway-urgent-focus";
    runtimeInputs = with pkgs; [
      sway
      jq
    ];
    text = builtins.readFile ./scripts/urgent-focus.sh;
  };
  window-picker = pkgs.writeShellApplication {
    name = "sway-window-picker";
    runtimeInputs = with pkgs; [
      sway
      jq
      coreutils
    ];
    text = ''
      workrooms_bin=${workrooms}
    ''
    + builtins.readFile ./scripts/window-picker.sh;
  };
in
{
  imports = [
    ./waybar.nix
    ./swaylock.nix
    ./rofi.nix
    ./kanshi.nix
    ./dunst.nix
    ./wlogout.nix
    ../wallpapers.nix
    ../nemo.nix
    ../gtkTheme.nix
  ];

  home.packages = with pkgs; [
    grim # screenshots
    slurp # region selection for grim
    wdisplays
    speedcrunch
    wl-clipboard
    (zathura.override { useMupdf = false; })
    autotiling
    pavucontrol
    brightnessctl # laptop backlight, used by sway keys and the waybar backlight module
    playerctl # media keys in the sway config
    overskride
  ];

  # Only for the wrapper; the config it generates is replaced by the dotfile below.
  # Keybindings, window rules and autostart go in dotfiles/sway/config.
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # Fixes common issues with GTK 3 apps
  };

  # Only two rofi modes: apps and the window picker (script mode).
  # $mod+d opens drun, $mod+Tab opens windows; the switcher at the bottom toggles between them.
  programs.rofi.extraConfig = {
    modi = "drun,windows:${window-picker}/bin/sway-window-picker";
    matching = "fuzzy";
    sort = true;
  };

  # Clipboard history: one wl-paste watcher each for text and images, as user services
  services.cliphist.enable = true;

  xdg = {
    mimeApps = {
      enable = true;
      defaultApplications =
        lib.genAttrs [
          "image/jpeg"
          "image/png"
          "image/gif"
          "image/webp"
          "image/bmp"
          "image/tiff"
          "image/svg+xml"
          "image/vnd.adobe.photoshop"
          "image/x-xcf"
        ] (_: [ "qimgv.desktop" ])
        // {
          "application/pdf" = [ "org.pwmt.zathura.desktop" ];
        };
    };

    configFile = {
      # Everything the dotfile needs from the Nix store; its first line includes this file
      "sway/script-vars.conf".text = ''
        set $workrooms_bin ${workrooms}
        set $wallpaper ${config.wallpaper}
        set $urgent_focus_bin ${urgent-focus}/bin/sway-urgent-focus
      '';

      "sway/config".source = lib.mkForce (config.lib.dotfiles.source "sway/config");
    };
  };
}
