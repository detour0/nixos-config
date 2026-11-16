{ config, ... }:
{
  programs.rofi = {
    enable = true;
    # One theme for everything rofi draws: launcher, window picker, power confirm, dunst menu.
    # Scripts pass -theme-str for sizes only.
    theme = ../../../../dotfiles/rofi/everforest.rasi;
    extraConfig = {
      show-icons = true;
      # Same icon set as GTK apps (gtkTheme.nix)
      icon-theme = config.gtk.iconTheme.name;
    };
  };
}
