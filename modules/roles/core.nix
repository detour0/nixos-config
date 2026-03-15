{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.role.core;
in
{
  options.role.core = mkRoleOptions "core role" {
    shell = mkOption {
      type = types.enum [
        "bash"
        "zsh"
      ];
      default = "zsh";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      # login/default shell can only be set system wide
      programs = {
        zsh.enable = mkIf (cfg.shell == "zsh") true;
      };

      # GDM only shows users with their default shell in /etc/shells
      environment.shells = optional (cfg.shell == "zsh") pkgs.zsh;
      users.defaultUserShell = pkgs.${cfg.shell};

      environment.systemPackages = with pkgs; [
        wget
        curl
        fastfetch
        btop
        htop
        man-pages
        man-pages-posix

        # Archive
        zip
        unzip
        p7zip
      ];
    }

    (mkRoleHome config "core" (user: {
      imports = [
        ../features/home/starship.nix
        ../features/home/yazi.nix
      ]
      ++ optional (cfg.shell == "zsh") ../features/home/zsh.nix;

      home.packages = with pkgs; [
        jq
        tree
        plocate
      ];
      programs = {
        fzf = {
          enable = true;
          enableZshIntegration = mkIf (cfg.shell == "zsh") true;
          enableBashIntegration = mkIf (cfg.shell == "bash") true;
        };
      };

    }))
  ]);
}
