{ pkgs, ... }:

{
  imports = [
    ../../modules/system.nix
    ../../modules/steam.nix
    ../../modules/vm.nix
    # ../../modules/kde-plasma.nix
    ../../modules/gnome.nix
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

  services = {
    mullvad-vpn.enable = true;
    mullvad-vpn.package = pkgs.mullvad-vpn;
    resolved.enable = true;
  };

  # for Nvidia GPU

  environment.systemPackages =
    (with pkgs; [

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

      # Nix Language Server
      nil
      nixfmt-rfc-style

      docker-compose
      docker-compose-language-service
    ])
    ++ [
    ];

  # After changing settings, Docker needs manual restart 'systemctl --user restart docker.service'
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
    daemon.settings = {
      # DNS needs to be set, or requests from inside the container won't resolve
      # Docker usually reads the DNS from /etc/ersolv.conf, which Nixos keeps in the Nix Store
      dns = [
        "1.1.1.1"
        "9.9.9.9"
      ];
    };
  };

  networking.firewall = {
    # allowedTCPPorts = [
    #   80
    #   443
    # ]; # HTTP/HTTPS
    # trustedInterfaces = [ "docker0" ]; # Trust Docker bridge
    enable = true;
  };

  # Setting default editor to vim
  # environment.variables.EDITOR = "neovim";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
