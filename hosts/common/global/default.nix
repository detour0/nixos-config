{
  import = [
      ./locale.nix
      ./settings.nix
      ./fonts.nix
      ./nameserver.nix
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
  };
}