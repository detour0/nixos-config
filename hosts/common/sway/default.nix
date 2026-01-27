{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    grim # screenshot functionality
    slurp # screenshot functionality, region selection
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    mako # notification system developed by swaywm maintainer
    # sway
  ];

  # Enable the gnome-keyring secrets vault. 
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;

  # In case swaylock cannot be unlocked with correct password:
  # security.pam.services.swaylock = {};

  # enable Sway window manager
  programs = {
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraOptions = [
        # "--unsupported-gpu"
      ];
    };
  };

  services.greetd = {                                                      
    enable = true;                                                         
    settings = {                                                           
      default_session = {                                                  
        command = "${lib.getExe pkgs.tuigreet} --time --cmd sway";
        user = "greeter";                                                  
      };                                                                   
    };                                                                     
  };
}
