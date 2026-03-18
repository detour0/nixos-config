{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.profile.core;
in
{
  imports = [ ../features/networking.nix ];
  options.profile.core = mkProfileHome "core profile" {
    shell = mkOption {
      type = types.enum [
        "bash"
        "zsh"
      ];
      default = "zsh";
    };
    ssh.enable = mkEnableOption "openssh daemon";
    vpn = {
      enable = mkEnableOption "VPN support";
      vendor = mkOption {
        type = types.enum [ "mullvad" ];
        default = "mullvad";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      features.networking.enable = true;
      # login/default shell can only be set system wide
      programs = {
        zsh.enable = mkIf (cfg.shell == "zsh") true;
      };

      # GDM only shows users with their default shell in /etc/shells
      environment.shells = optional (cfg.shell == "zsh") pkgs.zsh;
      users.defaultUserShell = pkgs.${cfg.shell};

      services.openssh.enable = mkIf cfg.ssh.enable true;

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
    # --- Specific Logic for VPN ---
    (mkIf (cfg.vpn.enable && cfg.vpn.vendor == "mullvad") {
      features.mullvad.enable = true;
    })

    (mkProfileHome config "core" (user: {
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
