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
  options.profile.core = mkProfileOptions "core profile" {
    firewall.disable = mkEnableOption "Disable firewall for testing";
    shell = mkOption {
      type = types.enum [
        "bash"
        "zsh"
      ];
      default = "zsh";
    };
    ssh = mkOption {
      type = types.enum [
        "client"
        "server"
        null
      ];
      default = null;
      description = "Enable ssh as client or server with port 22 open";
    };
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
      features.networking = {
        enable = true;
        firewall.enable = mkIf (!cfg.firewall.disable) true;
      };
      # login/default shell can only be set system wide
      programs = {
        zsh.enable = mkIf (cfg.shell == "zsh") true;
      };

      # GDM only shows users with their default shell in /etc/shells
      environment.shells = optional (cfg.shell == "zsh") pkgs.zsh;
      users.defaultUserShell = pkgs.${cfg.shell};

      services.openssh = {
        enable = mkIf (cfg.ssh != null) true;
        openFirewall = if (cfg.ssh == "server") then true else false;
      };

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
