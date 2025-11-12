{ config, lib, pkgs, ... }:
{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
  };
  xdg.configFile."wezterm/wezterm.lua".source = 
    config.lib.file.mkOutOfStoreSymlink 
    "${config.home.homeDirectory}/workspace/nixos-config/dotfiles/wezterm.lua";
}

# { pkgs, ... }:
# {
#   programs.wezterm = {
#     enable = true;
#     enableZshIntegration = true;
#     extraConfig = ''
#       -- H-M only adds 'local wezterm = require "wezterm"' :/
#       local config = wezterm.config_builder()
#
#       config.color_scheme = "catppuccin-mocha"
#       config.window_decorations = 'RESIZE'
#       config.hide_tab_bar_if_only_one_tab = true
#       config.use_fancy_tab_bar = false
#
#       return config
#     '';
#   };
# }
