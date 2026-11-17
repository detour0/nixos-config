{ config, ... }:
let
  inherit (config.lib.dotfiles) link;
in
{
  # Started by the sway config. Its systemd unit stays off: both together load it twice.
  programs.waybar.enable = true;

  xdg.configFile = {
    "waybar/config.jsonc".source = link "waybar/config.jsonc";
    "waybar/style.css".source = link "waybar/style.css";
    # NixOS logo for the launcher button, loaded by style.css with a relative url
    "waybar/nixos.svg".source = link "waybar/nixos.svg";
  };
}
