{
  # Removable drives: a tray icon in waybar's tray while one is plugged in, with a menu to mount,
  # unmount and eject. Needs services.udisks2 on the system side (modules/features/sway.nix).
  services.udiskie = {
    enable = true;
    tray = "auto"; # icon only while a drive is present
    automount = false; # mount from the menu
    notify = true; # dunst notification when a drive comes or goes
    # Devices straight in the top menu instead of under "Managed devices". That submenu is udiskie's
    # sway workaround: the menu is rebuilt on open, but sway sizes it from the previous build, so the
    # first open after plugging in or out can show a stale size. Opening it again fixes it.
    settings.program_options.menu_update_workaround = false;
  };

  # waybar's tray only speaks StatusNotifierItem; this adds --appindicator to udiskie
  xsession.preferStatusNotifierItems = true;

  # The SNI watcher is waybar's tray; an icon registered before waybar is up never shows
  systemd.user.services.udiskie.Unit.After = [ "waybar.service" ];
}
