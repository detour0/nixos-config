{ lib, ... }:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = lib.concatStrings [
        "$all"
        "$line_break"
        "$user"
        "$shell"
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
    };
  };
}
