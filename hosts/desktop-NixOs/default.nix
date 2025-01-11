{ pkgs, ... }:

{
  imports =
    [
      ../../modules/system.nix
      ../../modules/steam.nix
      ../../modules/vm.nix

      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
    };
    systemd-boot.enable = true;
  };

  networking.hostName = "desktop-NixOs"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # for Nvidia GPU

  environment.systemPackages = with pkgs; [

    # Installing Home Manager binary and adding to PATH
    home-manager

    wget
    curl
    neofetch
    btop
    man-pages
    man-pages-posix
    
    # Archive
    zip
    unzip
    p7zip

    vim
    nil

  ];

  # Setting default editor to vim
  environment.variables.EDITOR = "vim";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
