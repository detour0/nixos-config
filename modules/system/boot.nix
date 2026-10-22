{ config, lib, ... }:

let
  cfg = config.bootloader;
in
{
  options.bootloader = {
    type = lib.mkOption {
      type = lib.types.enum [
        "dedicated"
        "vServer"
      ];
      description = ''
        dedicated:    UEFI machine, systemd-boot
        vServer:   BIOS VPS, GRUB on a GPT disk (needs an EF02 partition)
      '';
    };

    configurationLimit = lib.mkOption {
      type = lib.types.int;
      default = 5;
      description = "How many generations to keep in the boot menu.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.type == "dedicated") {
      boot.loader.systemd-boot = {
        enable = true;
        inherit (cfg) configurationLimit;
        consoleMode = lib.mkIf (cfg.type == "dedicated") "max";
      };
      boot.loader.efi.canTouchEfiVariables = true;
    })

    (lib.mkIf (cfg.type == "vServer") {
      boot.loader.grub = {
        enable = true;
        inherit (cfg) configurationLimit;
      };
      assertions = [
        {
          assertion = config.boot.loader.grub.devices != [ ];
          message = ''
            bootloader.type = "vServer" needs a GRUB device. Use a disko disk with an
            EF02 (BIOS boot) partition, or set boot.loader.grub.devices in the host config.
          '';
        }
      ];
    })
  ];
}
