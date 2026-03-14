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
    ../common/bluetooth.nix

    ../common/docker.nix
    ../common/printing.nix
    ../common/pipewire.nix
    ../common/mullvad.nix

    # ../common/gnome.nix
    ../common/sway.nix

    ../common/vm.nix
    ../common/steam.nix
  ];

  networking.hostName = "shaundi";

  # login/default shell can only be set system wide
  programs = {
    zsh.enable = true;
  };
  # GDM only shows users with their default shell in /etc/shells
  environment.shells = [ pkgs.zsh ];
  users.defaultUserShell = pkgs.zsh;

  environment.variables.EDITOR = "nvim";

  environment.systemPackages =
    (with pkgs; [

      wget
      curl
      fastfetch
      btop
      htop
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
    ])
    ++ [
    ];

  networking.firewall = {
    allowedTCPPorts = [ ]; # 80 HTTP/ 443 HTTPS
    # trustedInterfaces = [ "docker0" ]; # Trust Docker bridge
    enable = true;
  };

  # Do not change from 25-05!
  system.stateVersion = "25.05";
}
