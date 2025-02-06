{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    kdePackages.kate
    megasync
    keepassxc
    obsidian

  ];

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
        "$lua"
        "$nix_shell"
        "$nodejs"
        "$python"
        "$rust"
        "$sudo"
        "$docker_context"
        "$line_break"
        "$shell"
        "$character"
        ];
      fill = {
        symbol = " ";
      };
    };
  };

  services = {
    # syncthing.enable = true;

  };
}
