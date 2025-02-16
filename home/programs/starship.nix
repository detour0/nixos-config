{ lib, ... }:
{
  programs.starship = {
    enable = true;
    settings = {
      format = lib.concatStrings [
        "$directory"
        "$git_branch"
        "$git_status"
        "$fill"
        "$deno"
        "$direnv"
        "$docker_context"
        "$hostname"
        "$lua"
        "$nix_shell"
        "$nodejs"
        "$python"
        "$rust"
        "$sudo"
        "$cmd_duration"
        "$jobs"
        "$line_break"
        "$shell"
        "$character"
        ];
      fill = {
        symbol = ".";
      };
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