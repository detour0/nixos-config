{
  pkgs,
  config,
  lib,
  ...
}:
lib.mkIf (config.machine.type == "client") {
  fonts = {
    packages =
      with pkgs;
      [
        material-design-icons
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        jetbrains-mono
      ]
      ++ builtins.filter lib.isDerivation (builtins.attrValues pkgs.nerd-fonts);

    # Only the fonts listed here
    enableDefaultPackages = false;

    # Noto Color Emoji everywhere, so DejaVu's black-and-white emojis never win
    fontconfig.defaultFonts = {
      serif = [
        "Noto Serif"
        "Noto Color Emoji"
      ];
      sansSerif = [
        "Noto Sans"
        "Noto Color Emoji"
      ];
      monospace = [
        "JetBrainsMono Nerd Font"
        "Noto Color Emoji"
      ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
