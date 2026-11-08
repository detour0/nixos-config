{ lib, ... }:
let
  inherit (lib)
    mkOption
    types
    ;
in

{
  imports = [
    ./boot.nix
    ./locale.nix
    ./settings.nix
    ./dns.nix
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
      type = lib.mkOption {
        type = lib.types.enum [
          "dedicated"
          "vServer"
        ];
        description = ''
          dedicated:  UEFI machine, systemd-boot
          vServer:    BIOS VPS, GRUB on a GPT disk (needs an EF02 partition)
        '';
      };

      configurationLimit = lib.mkOption {
        type = types.ints.positive;
        default = 5;
        description = "How many generations to keep in the boot menu.";
      };
    };

  };
  config = {
    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # Set your time zone.
    time.timeZone = "Europe/Berlin";

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "us,de";
      variant = "altgr-intl,";
    };
  };
}
