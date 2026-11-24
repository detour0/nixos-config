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
    # Papirus (~300k icons) cost every new GTK4 process ~0.7 s of indexing; breeze-dark ~0.25 s
    iconTheme = {
      name = "breeze-dark";
      package = pkgs.kdePackages.breeze-icons;
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
