{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    genAttrs
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    mkProfileHome
    mkProfileOptions
    optional
    types
    ;
  cfg = config.profile.core;
  zsh = cfg.shell == "zsh";
  sshServer = cfg.ssh.state == "server";
  sshClient = cfg.ssh.state == "client";
in
{
  imports = [
    ../features/networking.nix
    ../features/mullvad.nix
    ../features/netbird.nix
  ];

  options.profile.core = mkProfileOptions config "core profile" {
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
        description = "client: ssh config and agent for the admin keys; server: authorized keys for root and the users";
      };
      rootKeyPub = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Pub key for root access";
      };
      userKeyPub = mkOption {
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
      features.networking.enable = true;
      features.mullvad.enable = cfg.vpn.enable && cfg.vpn.vendor == "mullvad";

      # The login shell can only be set system wide
      users.defaultUserShell = if zsh then pkgs.zsh else pkgs.bash;
      environment.shells = optional zsh pkgs.zsh;
      programs.zsh = mkIf zsh {
        enable = true;
        # Home-manager's zsh (oh-my-zsh) runs its own compinit, so the global one in
        # /etc/zshrc only doubles startup time. Keep it for users without a .zshrc (root).
        enableGlobalCompInit = false;
        interactiveShellInit = ''
          if [[ ! -f ''${ZDOTDIR:-$HOME}/.zshrc ]]; then
            autoload -U compinit && compinit
          fi
        '';
      };

      # On for every host: sshd also creates the host key that sops decrypts with.
      # Not reachable from outside; the firewall only lets it through on the NetBird interface.
      services.openssh = {
        enable = true;
        openFirewall = false;
        settings = {
          PermitRootLogin = if sshServer then "prohibit-password" else "no";
          PasswordAuthentication = false;
        };
      };

      # Servers pull the private secrets repo with their read-only key
      programs.ssh.extraConfig = mkIf sshServer ''
        Host github.com
          IdentityFile /var/lib/ssh_automation/id_ed25519_read
          IdentitiesOnly yes
      '';

      users.users = {
        root.openssh.authorizedKeys.keys = optional sshServer cfg.ssh.rootKeyPub;
      }
      // genAttrs cfg.users (_: {
        openssh.authorizedKeys.keys = optional sshServer cfg.ssh.userKeyPub;
      });

      environment.systemPackages = with pkgs; [
        wget
        curl
        fastfetch
        btop
        htop
        man-pages
        man-pages-posix
        eza

        # Archive
        zip
        unzip
        p7zip
      ];
    }

    (mkProfileHome cfg (hm: {
      imports = [
        ../features/home/starship.nix
        ../features/home/yazi.nix
      ]
      ++ optional zsh ../features/home/zsh.nix;

      home.packages = with pkgs; [
        jq
        tree
        plocate
      ];

      programs.fzf.enable = true;

      # Admin keys (placed by sops-admin.nix) and the hosts they are for
      programs.ssh = mkIf sshClient {
        enable = true;
        # Silence warning about default value drops 25.11 to 26.05
        enableDefaultConfig = false;
        settings =
          let
            key = name: "${hm.config.home.homeDirectory}/.ssh/id_ed25519_${name}";
            inherit (inputs.nix-secrets.networking) schiggi digda;
          in
          {
            "github.com" = {
              HostName = "github.com";
              identityFile = key "github";
              AddKeysToAgent = "6h";
            };
            "schiggi" = {
              HostName = schiggi.netbirdIp;
              User = "root";
              identityFile = key "deploy";
              AddKeysToAgent = "1h";
            };
            "schiggi.dt" = {
              HostName = schiggi.netbirdIp;
              User = "dt";
              identityFile = key "dt";
            };
            "digda" = {
              HostName = digda.netbirdIp;
              User = "root";
              identityFile = key "deploy";
              AddKeysToAgent = "1h";
            };
            "digda.keeper" = {
              HostName = digda.netbirdIp;
              User = "keeper";
              identityFile = key "dt";
            };
          };
      };

      # Caches passphrase-protected keys
      services.ssh-agent.enable = sshClient;
    }))
  ]);
}
