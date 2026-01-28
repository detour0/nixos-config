{ config, lib, pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    
    # 1. Import your JSON config
    # Use lib.importJSON to convert your external file into a Nix attribute set.
    # Note: The file must be valid JSON (no comments). 
    # settings = lib.importJSON ../../dotfiles/waybar/config.jsonc;

    # 2. Reference your CSS file
    # Passing a path literal (starts with ./) tells HM to use the file directly.
    # style = ../../dotfiles/waybar/style.css;

    # Optional: Systemd integration to start Waybar automatically on login
    systemd.enable = true;
  };

  # This creates the symlinks in ~/.config/waybar/
  xdg.configFile."waybar/config.jsonc".source = ../../dotfiles/waybar/config.jsonc;
  xdg.configFile."waybar/style.css".source = ../../dotfiles/waybar/style.css;
}
