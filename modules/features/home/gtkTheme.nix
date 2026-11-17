{ pkgs, ... }:
let
  cursor = {
    name = "Catppuccin-Mocha-Dark-Cursors";
    package = pkgs.catppuccin-cursors.mochaDark;
  };
in
{
  # Also sets XCURSOR_THEME and XCURSOR_SIZE
  home.pointerCursor = cursor // {
    gtk.enable = true;
    size = 20;
  };

  gtk = {
    enable = true;
    cursorTheme = cursor;
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };

  # Dark mode for apps and websites
  dconf.enable = true;
  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    cursor-theme = cursor.name;
  };
}
