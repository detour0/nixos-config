{
  config,
  inputs,
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

    ssh = {
      state = mkOption {
        type = types.nullOr (
          types.enum [
            "client"
            "server"
          ]
        );
        default = null;
        description = "Enable ssh as client or server with port 22 open";
      };
      rootKey = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Pub key for root access";
      };
      userKey = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Pub key for user account access";
      };
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
      users = {
        defaultUserShell = if (cfg.shell == "zsh") then pkgs.zsh else pkgs.bash;
      };

      # ==========================================
      # SYSTEM SSH CONFIGURATION
      # ==========================================
      services.openssh = {
        enable = mkIf (cfg.ssh != null) true;
        openFirewall = false;
        settings = {
          PermitRootLogin = if (cfg.ssh.state == "server") then "prohibit-password" else "no";
          PasswordAuthentication = false;
        };
      };

      programs.ssh = mkIf (cfg.ssh.state == "server") {
        # This injects custom configuration text directly into /etc/ssh/ssh_config
        # or root's matching profile context.
        extraConfig = ''
          Host github.com
            IdentityFile /var/lib/ssh_automation/id_ed25519_read
            IdentitiesOnly yes
        '';
      };

      users.users = {
        root.openssh.authorizedKeys.keys = optional (cfg.ssh.state == "server") cfg.ssh.rootKey;
        # dt.openssh.authorizedKeys.keys = optional (cfg.ssh.state == "server") cfg.ssh.userKey;
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

    (mkIf (cfg.vpn.enable && cfg.vpn.vendor == "mullvad") {
      features.mullvad.enable = true;
    })

    # ==========================================
    # HOME MANAGER CONFIGURATION
    # ==========================================
    (mkProfileHome config "core" (
      user: hmConfig: {
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

          # ==========================================
          # USER SSH CONFIGURATION
          # ==========================================
          ssh = mkIf (cfg.ssh.state == "client") {
            enable = true;
            matchBlocks = {
              "github.com" = {
                identityFile = "${hmConfig.config.home.homeDirectory}/.ssh/id_ed25519_github";
                extraOptions = {
                  # addkeystoagent = "yes";
                };
              };

              "schiggi" = {
                host = inputs.nix-secrets.networking.schiggi.netbirdIp;
                user = "root";
                identityFile = "${hmConfig.config.home.homeDirectory}/.ssh/id_ed25519_deploy";
                extraOptions = {
                  # needed for deploy-rs, otherwise breaks on 2. password input
                  addkeystoagent = "yes";
                };
              };

              "schiggi.dt" = {
                host = inputs.nix-secrets.networking.schiggi.netbirdIp;
                user = "dt";
                identityFile = "${hmConfig.config.home.homeDirectory}/.ssh/id_ed25519_dt";
                extraOptions = {
                  # addkeystoagent = "yes";
                };
              };
            };
          };
        };

        # Server ssh setup
        home.file.".ssh/authorized_keys" = mkIf (cfg.ssh.state == "server" && cfg.ssh.userKey != null) {
          text = "${cfg.ssh.userKey}";
          onChange = ''
            cat ~/.ssh/authorized_keys > ~/.ssh/authorized_keys.tmp && mv ~/.ssh/authorized_keys.tmp ~/.ssh/authorized_keys
            chmod 600 ~/.ssh/authorized_keys
          '';
        };

        # Start ssh-agent to cache your passphrase-protected keys
        services.ssh-agent.enable = mkIf (cfg.ssh.state == "client") true;

      }
    ))
  ]);
}
