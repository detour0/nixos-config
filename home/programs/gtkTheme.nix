{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # materia-theme
    papirus-icon-theme
    catppuccin-cursors.mochaDark
  ];

# Set dark-mode as default for apps and websites
  dconf.enable = true;
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      cursor-theme = "Catppuccin-Mocha-Dark-Cursors";
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    name = "Catppuccin-Mocha-Dark-Cursors";
    package = pkgs.catppuccin-cursors.mochaDark;
    size = 16;
  };

  home.sessionVariables = {
  XCURSOR_THEME = "Catppuccin-Mocha-Dark-Cursors";
  XCURSOR_SIZE = "16";
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
    # theme = {
    #   name = "Materia-Dark";
    #   package = pkgs.materia-theme;
    # };
      cursorTheme = {
      name = "Catppuccin-Mocha-Dark-Cursors";
      package = pkgs.catppuccin-cursors.mochaDark;
    };
    gtk3 = {
      extraConfig.gtk-application-prefer-dark-theme = true;
    };
  };
}
