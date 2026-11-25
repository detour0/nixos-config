{ pkgs, ... }:
let
  # Nemo's "Open in Terminal" runs only the `exec` key (it ignores exec-arg) with the
  # folder as working directory. A plain `wezterm` hands the window to the running
  # GUI instance without that cwd, so it opens in ~. Pass it explicitly.
  nemo-terminal = pkgs.writeShellScript "nemo-terminal" ''
    exec wezterm start --cwd "$PWD"
  '';
in
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

  dconf.settings = {
    "org/nemo/desktop".show-desktop-icons = false;
    "org/cinnamon/desktop/applications/terminal" = {
      exec = "${nemo-terminal}";
      exec-arg = "";
    };
  };
}
