{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.features.sway;
in
{
  options.features.sway.enable = lib.mkEnableOption "swaywm based environment";

  config = lib.mkIf cfg.enable {
    # Enable the gnome-keyring secrets vault.
    # Will be exposed through DBus to programs willing to store secrets.
    services.gnome.gnome-keyring.enable = true;

    environment.systemPackages = with pkgs; [
      nemo
      qimgv
    ];

    # swaylock: no delay after a wrong password, 60 s lockout after 5 failures.
    # Standard faillock stack: preauth, unix (skips authfail on success), authfail, authsucc.
    # swaylock runs as the user, so the tally lives in a user-owned dir instead of /run/faillock.
    security.pam.services.swaylock =
      let
        unixOrder = config.security.pam.services.swaylock.rules.auth.unix.order;
        faillock = settings: {
          control = "required";
          modulePath = "${pkgs.pam}/lib/security/pam_faillock.so";
          settings = {
            dir = "/run/swaylock-faillock";
            deny = 5;
            unlock_time = 60;
          }
          // settings;
        };
      in
      {
        nodelay = true;
        rules.auth = {
          unix.control = lib.mkForce "[success=1 default=ignore]";
          faillock-preauth = faillock { preauth = true; } // {
            order = unixOrder - 10;
          };
          faillock-authfail = faillock { authfail = true; } // {
            order = unixOrder + 10;
            control = "[default=die]";
          };
          faillock-authsucc = faillock { authsucc = true; } // {
            order = unixOrder + 20;
            control = "sufficient";
          };
        };
      };
    systemd.tmpfiles.rules = [ "d /run/swaylock-faillock 0700 dt users -" ];

    # security.polkit.enable = true;

    # enable Sway window manager
    # Doing it like this should enable polkit by default
    programs = {
      sway = {
        enable = true;
        # wrapperFeatures.gtk = true;
        extraOptions = [
          # "--unsupported-gpu"
        ];
        # Overide extraPkgs to avoid default installations (foot, etc...)
        extraPackages = with pkgs; [
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

    home-manager.sharedModules = [
      (lib.mkFeatureBridge ./home/sway)
    ];
  };
}
