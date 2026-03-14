{ pkgs, ...}:
{
  xdg.desktopEntries.nemo = {
    name = "Nemo";
    exec = "${pkgs.nemo}/bin/nemo";
  };

  xdg.mimeApps = {
      enable = true;
      defaultApplications = {
          "inode/directory" = [ "nemo.desktop" ];
          "application/x-gnome-saved-search" = [ "nemo.desktop" ];
      };
  };

  dconf = {
      settings = {
          "org/cinnamon/desktop/applications/terminal" = {
              exec = "wezterm";
              exec-arg = "start --cwd";
          };
      };
  };
}
