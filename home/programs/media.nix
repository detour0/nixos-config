{
  pkgs,
  ...
}:
# media - control and enjoy audio/video
{
  # imports = [
  # ];

  home.packages = with pkgs; [
    vlc
  ];

  programs = {
    obs-studio.enable = true;
  };
}
