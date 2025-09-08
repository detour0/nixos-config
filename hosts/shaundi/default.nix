{
  pkgs,
  inputs,
  mkUser,
  ...
}:

{

  imports = [
    ./hardware-configuration.nix
    ../common/global

    (mkUser "dt")

    ../../overlays
    ../common/extrargs.nix
    inputs.sops-nix.nixosModules.sops

    ../common/systemd-boot.nix
    ../common/networking.nix

    ../common/docker.nix
    ../common/printing.nix
    ../common/pipewire.nix
    ../common/mullvad.nix

    ../common/gnome.nix
    ../common/vm.nix
    ../common/steam.nix

  ];

  networking.hostName = "shaundi";

  environment.variables.EDITOR = "nano";

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

  networking.firewall = {
    allowedTCPPorts = [ ]; # 80 HTTP/ 443 HTTPS
    # trustedInterfaces = [ "docker0" ]; # Trust Docker bridge
    enable = true;
  };

  system.stateVersion = "25.05";
}
