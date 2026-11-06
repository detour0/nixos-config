{ config, lib, ... }:
let
  inherit (lib) mkIf mkMerge;
  cfg = config.machine.bootloader;
in
{
  config = mkMerge [
    (mkIf (cfg.type == "dedicated") {
      boot.loader.systemd-boot = {
        enable = true;
        inherit (cfg) configurationLimit;
        consoleMode = "max";
      };
      boot.loader.efi.canTouchEfiVariables = true;
    })
    (mkIf (cfg.type == "vServer") {
      boot.loader.grub = {
        enable = true;
        inherit (cfg) configurationLimit;
        efiSupport = false;
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
