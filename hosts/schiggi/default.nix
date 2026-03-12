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

    ../common/systemd-boot.nix
    ../common/networking.nix

    ../common/docker.nix
    ../common/printing.nix
    ../common/pipewire.nix
    ../common/mullvad.nix

    ../common/vm.nix
  ];

  networking.hostName = "schiggi";

  # login/default shell can only be set system wide
  programs = {
    zsh.enable = true;
  };
  # GDM only shows users with their default shell in /etc/shells
  users.defaultUserShell = pkgs.zsh;

  environment = {
    shells = [ pkgs.zsh ];
    variables.EDITOR = "nvim";

    systemPackages = with pkgs; [
      wget
      curl
      fastfetch
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
    ];

  };

  networking.firewall = {
    allowedTCPPorts = [ ]; # 80 HTTP/ 443 HTTPS
    # trustedInterfaces = [ "docker0" ]; # Trust Docker bridge
    enable = true;
  };

  # Do not change from 25-05!
  system.stateVersion = "25.11";
}
