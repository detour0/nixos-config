{ config, lib, pkgs, ... }:
{
  home.packages = [ pkgs.wezterm ];
  xdg.configFile."wezterm/wezterm.lua".source = 
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/workspace/nixos-config/dotfiles/wezterm.lua";
}
