{ config, pkgs, lib, ... }:
{
  # Enable the gnome-keyring secrets vault. 
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;

  environment.systemPackages = with pkgs; [
    autotiling
    pavucontrol
    nwg-displays

    kdePackages.qtsvg
    kdePackages.dolphin
    # kdePackages.kio # needed since 25.11
    # kdePackages.kio-fuse #to mount remote filesystems via FUSE
    # kdePackages.kio-extras #extra protocols support (sftp, fish and more)
    
  ];

  # In case swaylock cannot be unlocked with correct password:
  # security.pam.services.swaylock = {};

  # sucirty.polkit.enable = true;

  # enable Sway window manager
  # Doing it like this should enable polkit by default
  programs = {
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraOptions = [
        # "--unsupported-gpu"
      ];
      extraPackages = with pkgs; [
        swaylock
        swayidle
      ];
    };
  };

  services.getty = {
    autologinUser = "dt";
    autologinOnce = true;
  };
  environment.loginShellInit = ''
      [[ "$(tty)" == /dev/tty1 ]] && sway
  '';

  # services.greetd = {                                                      
  #   enable = true;                                                         
  #   settings = {                                                           
  #     default_session = {                                                  
  #       command = "${lib.getExe pkgs.tuigreet} --time --cmd sway";
  #       user = "greeter";                                                  
  #     };                                                                   
  #   };                                                                     
  # };
}
