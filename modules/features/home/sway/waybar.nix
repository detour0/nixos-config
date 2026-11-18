{ config, ... }:
{
  # Started by the sway config. Its systemd unit stays off: both together load it twice.
  programs.waybar.enable = true;

  # The whole directory, so style.css finds nixos.svg (the launcher logo) by its relative url
  xdg.configFile."waybar".source = config.lib.dotfiles.source "waybar";
}
