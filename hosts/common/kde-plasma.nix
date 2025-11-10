{
  # Enable X11 windowing system.
  services.xserver.enable = true;

  # Enable KDE Plasma Desktop Environment
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
}
