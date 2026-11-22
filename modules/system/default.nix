{ inputs, lib, ... }:
let
  inherit (lib)
    genAttrs
    mkOption
    types
    ;
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    ../../lib/user-manager.nix
    ./boot.nix
    ./bootstrap.nix
    ./fonts.nix
  ];

  options.machine = {
    type = mkOption {
      type = types.enum [
        "client"
        "headless"
      ];
      description = "client = graphical session (fonts, X); headless = server.";
    };

    bootloader = {
      type = mkOption {
        type = types.enum [
          "dedicated"
          "vServer"
        ];
        description = ''
          dedicated:  UEFI machine, systemd-boot
          vServer:    BIOS VPS, GRUB on a GPT disk (needs an EF02 partition)
        '';
      };

      configurationLimit = mkOption {
        type = types.ints.positive;
        default = 5;
        description = "How many generations to keep in the boot menu.";
      };
    };
  };

  config = {
    nixpkgs.config.allowUnfree = true;

    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      extra-substituters = [
        "https://devenv.cachix.org"
        "https://nix-community.cachix.org"
        "https://nixpkgs-python.cachix.org"
      ];
      extra-trusted-public-keys = [
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU="
      ];
      # 500 MiB
      download-buffer-size = 524288000;
    };

    # Every role decrypts with the host's SSH key; the role module (sops-*.nix) picks the file and the secrets
    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    time.timeZone = "Europe/Berlin";

    # English UI, German formats
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = genAttrs [
      "LC_ADDRESS"
      "LC_IDENTIFICATION"
      "LC_MEASUREMENT"
      "LC_MONETARY"
      "LC_NAME"
      "LC_NUMERIC"
      "LC_PAPER"
      "LC_TELEPHONE"
      "LC_TIME"
    ] (_: "de_DE.UTF-8");

    services.xserver.xkb = {
      layout = "us,de";
      variant = "altgr-intl,";
    };

    # No ~2 s pause after a wrong sudo password; sudo still allows 3 tries per run.
    # Guessing via sudo needs a shell as the user already, and yescrypt hashing keeps it slow.
    security.pam.services.sudo.nodelay = true;
  };
}
