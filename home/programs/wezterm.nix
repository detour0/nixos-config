{ pkgs, ... }:
{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = ''
      -- H-M only adds 'local wezterm = require "wezterm"' :/
      local config = {}

      config.color_scheme = "catppuccin-mocha"

      return config
    '';
  };
}
