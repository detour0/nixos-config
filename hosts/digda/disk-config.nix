{ ... }:
{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/vda"; # adjust after the lsblk check
    content = {
      type = "gpt";
      partitions = {
        boot = {
          # BIOS boot partition for GRUB on GPT
          size = "1M";
          type = "EF02";
          priority = 1;
        };
        ESP = {
          size = "1G";
          type = "EF00";
          priority = 2;
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        swap = {
          size = "2G";
          priority = 3;
          content.type = "swap";
        };
        root = {
          size = "100%";
          priority = 4; # must come last
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
            mountOptions = [ "noatime" ];
          };
        };
      };
    };
  };
}
