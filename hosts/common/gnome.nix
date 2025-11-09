{ pkgs, ... }:
{
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.excludePackages = with pkgs; [
    xterm
  ];

  environment.gnome.excludePackages = (
    with pkgs;
    [
      atomix # puzzle game
      cheese # webcam tool
      epiphany # web browser
      evince # document viewer
      geary # email reader
      gedit # text editor
      gnome-characters
      gnome-music
      gnome-photos
      gnome-terminal
      gnome-tour
      gnome-text-editor
      gnome-console
      gnome-contacts
      gnome-maps
      yelp
      simple-scan
      snapshot
      hitori # sudoku game
      iagno # go game
      tali # poker game
      totem # video player
      xterm # standard gnome-terminal
    ]
  );
  environment.systemPackages =
    (with pkgs.gnomeExtensions; [
      blur-my-shell
      freon
      open-bar
      net-speed-simplified
      rounded-window-corners-reborn
      appindicator
      caffeine
      unblank
    ])
    ++ [
      pkgs.dconf-editor
    ];
}
