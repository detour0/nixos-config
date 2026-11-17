{ config, ... }:
{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
  };
  xdg.configFile."wezterm/wezterm.lua".source = config.lib.dotfiles.link "wezterm.lua";
}
