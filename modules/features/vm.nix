{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.vm;
in
{
  options.features.vm.enable = lib.mkEnableOption "qemu and virt vm";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      qemu
      libvirt
      virt-viewer
      virtiofsd
    ];

    virtualisation.libvirtd.enable = true;
  };
}
