{ config, pkgs, lib, ... }:
{
  # Enable the gnome-keyring secrets vault. 
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;

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
