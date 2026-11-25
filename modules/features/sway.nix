{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.features.sway;
  # The session belongs to one user: tty1 logs them in and starts sway
  user = "dt";
in
{
  options.features.sway.enable = lib.mkEnableOption "swaywm based environment";

  config = lib.mkIf cfg.enable {
    # Secrets vault, exposed over DBus to programs that want to store secrets
    services.gnome.gnome-keyring.enable = true;

    environment.systemPackages = with pkgs; [
      nemo
      qimgv
    ];

    # Also enables polkit
    programs.sway = {
      enable = true;
      # Replaces the default extra packages (foot and so on)
      extraPackages = [ pkgs.swayidle ];
    };

    # Mounting removable drives as the user (udiskie in the tray, nemo)
    services.udisks2.enable = true;

    # GIO virtual filesystems: nemo's Trash (trash:///, Del = move to trash), network shares, MTP
    services.gvfs.enable = true;

    services.getty = {
      autologinUser = user;
      autologinOnce = true;
    };
    environment.loginShellInit = ''
      [[ "$(tty)" == /dev/tty1 ]] && sway
    '';

    # On the charger, closing the lid never suspends. Opening the lid briefly disconnects the external
    # monitors, and logind (still seeing the lid closed and no monitor) suspended right then.
    # On battery the lid still suspends.
    services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";

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
    systemd.tmpfiles.rules = [ "d /run/swaylock-faillock 0700 ${user} users -" ];

    # The home-manager side, for every home-manager user of the host
    home-manager.sharedModules = [ ./home/sway ];
  };
}
