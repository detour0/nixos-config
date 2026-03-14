{ lib, ... }:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      palette = "catppuccin_mocha";
      add_newline = false;
      format = lib.concatStrings [
        "$all"
        "$line_break"
        "$username"
        "$character"
      ];
      fill = {
        symbol = ".";
      };
      # right_format = "$cmd_duration"; # Doesn't work with bash
      directory = {
        truncation_symbol = "../";
      };
      cmd_duration = {
        min_time = 1;
        show_milliseconds = true;
      };
      username = {
        style_user = "bright-white bold";
        style_root = "bright-red bold";
      };
      palettes = {
        catppuccin_mocha = {
          rosewater = "#f5e0dc";
          flamingo = "#f2cdcd";
          pink = "#f5c2e7";
          mauve = "#cba6f7";
          red = "#f38ba8";
          maroon = "#eba0ac";
          peach = "#fab387";
          yellow = "#f9e2af";
          green = "#a6e3a1";
          teal = "#94e2d5";
          sky = "#89dceb";
          sapphire = "#74c7ec";
          blue = "#89b4fa";
          lavender = "#b4befe";
          text = "#cdd6f4";
          subtext1 = "#bac2de";
          subtext0 = "#a6adc8";
          overlay2 = "#9399b2";
          overlay1 = "#7f849c";
          overlay0 = "#6c7086";
          surface2 = "#585b70";
          surface1 = "#45475a";
          surface0 = "#313244";
          base = "#1e1e2e";
          mantle = "#181825";
          crust = "#11111b";
        };
      };
    };
  };
}
