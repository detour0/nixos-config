{ lib, ... }:
{
  programs.starship = {
    enable = true;
    settings = {
      format = lib.concatStrings [
        "$all"
        "$line_break"
        "$shell"
        "$character"
      ];
      fill = {
        symbol = ".";
      };
      right_format = "$cmd_duration";
      directory = {
        truncation_symbol = "../";
      };
      cmd_duration = {
        min_time = 1;
        show_milliseconds = true;
      };
    };
  };
}
