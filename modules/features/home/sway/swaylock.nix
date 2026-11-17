{
  # All lock-screen styling; every swaylock call ($lock, swayidle, wlogout) passes no colours of its own
  programs.swaylock.enable = true;
  xdg.configFile."swaylock/config".source = ../../../../dotfiles/swaylock/everforest.conf;
}
