{ lib, ... }:
{
  # Shared by the sway background and the wlogout backdrop
  options.wallpaper = lib.mkOption {
    type = lib.types.path;
    default = ../../../assets/wallpapers/pexels-pixabay-531321.jpg;
    description = "Path to the wallpaper image";
  };
}
