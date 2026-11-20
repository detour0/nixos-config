{ config, ... }:
{
  # A systemd user service (graphical-session.target, started by the sway config), not `exec waybar`:
  # home-manager's unit has Restart=on-failure, so waybar comes back when it crashes, e.g. when a
  # rebuild restarts pipewire-pulse under it. Don't add `exec waybar` back, or it loads twice.
  programs.waybar = {
    enable = true;
    systemd.enable = true;
  };

  # The whole directory, so style.css finds nixos.svg (the launcher logo) by its relative url
  xdg.configFile."waybar".source = config.lib.dotfiles.source "waybar";
}
