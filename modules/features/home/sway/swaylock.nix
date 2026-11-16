{
  programs.swaylock = {
    enable = true;
  };
  xdg.configFile."swaylock/config".source = ../../../../dotfiles/swaylock/everforest.conf;
}
