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
      qemu # QEMU tools
      libvirt # Optional: libvirt for managing VMs
      virt-viewer
      virtiofsd
    ];

    # Enable KVM for performance (optional)
    virtualisation.libvirtd.enable = true;
  };
}
