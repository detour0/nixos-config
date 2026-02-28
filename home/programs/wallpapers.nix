# modules/wallpaper.nix
{ config, lib, ... }:

let
  wallpaper = ../../assets/wallpapers/pexels-pixabay-531321.jpg;
in
{
  # Define custom option under 'options' (no 'home.' prefix needed here)
  options.wallpaper = lib.mkOption {
    type = lib.types.path;
    default = wallpaper;
    description = "Path to the wallpaper image";
  };
}
