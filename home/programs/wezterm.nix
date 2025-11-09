{ pkgs, ... }:
{
  home.packages = [ pkgs.wezterm ];
  xdg.configFile."wezterm/wezterm.lua".source = ./dotfiles/wezterm.lua;
}
