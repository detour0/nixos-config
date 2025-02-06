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
        "$line_break"
        "$shell"
        "$character"
        ];
      fill = {
        symbol = " ";
      };
      directory = {
        truncation_symbol = "../";
      };
    };
  };
}