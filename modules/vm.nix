{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    qemu # QEMU tools
    libvirt # Optional: libvirt for managing VMs
  ];

  # Enable KVM for performance (optional)
  virtualisation.libvirtd.enable = true;
}
