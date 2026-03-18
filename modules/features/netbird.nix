{
  lib,
  config,
  pkgs,
  pkgsUnstable,
  ...
}:
let
  cfg = config.netbird-wt0;
  inherit (lib) mkIf optionals;
in
{
  options.netbird-wt0 =
    let
      inherit (lib) mkEnableOption mkOption types;
    in
    {
      enable = mkEnableOption "NetBird setup";
      ui.enable = mkEnableOption "NetBird UI";

      setupKeyFile = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Path to the file containing the setup key.";
        example = "/etc/netbird/setup-key";
      };
    };

  config = mkIf cfg.enable {
    environment.systemPackages = optionals cfg.ui.enable [ pkgsUnstable.netbird-ui ];
    services.netbird.package = pkgsUnstable.netbird;
    # environment.systemPackages = optionals cfg.ui.enable [ pkgs.netbird-ui ];
    # services.netbird.package = pkgs.netbird;

    services.netbird.clients.wt0 = {
      # Login does nothing atm, might be because the grep "Connected" in the script
      # ${client.service.name}-login returns 0 when finding "Disconnected"
      login = {
        enable = true;
        inherit (cfg) setupKeyFile;
      };

      ui.enable = cfg.ui.enable;
      # Port used to listen to wireguard connections
      port = 51821;
      # This opens ports required for direct connection without a relay
      openFirewall = true;
      # This opens necessary firewall ports in the Netbird client's network interface
      openInternalFirewall = true;
    };

    # systemd.services.netbird.postStart = lib.optionalString (cfg.setupKeyFile != null) ''
    #   set -x
    #   nb='${lib.getExe config.services.netbird.clients.default.wrapper}'
    #
    #   fetch_status() {
    #     status="$("$nb" status 2>&1)"
    #   }
    #
    #   print_status() {
    #     test -n "$status" || refresh_status
    #     cat <<EOF
    #   $status
    #   EOF
    #   }
    #
    #   refresh_status() {
    #     fetch_status
    #     print_status
    #   }
    #
    #   main() {
    #     print_status | ${lib.getExe pkgs.gnused} 's/^/STATUS:INIT: /g'
    #     while refresh_status | grep --quiet 'Disconnected' ; do
    #       sleep 1
    #     done
    #     print_status | ${lib.getExe pkgs.gnused} 's/^/STATUS:WAIT: /g'
    #
    #     if print_status | grep --quiet 'NeedsLogin' ; then
    #       "$nb" up
    #     fi
    #   }
    #
    #   main "$@"
    # '';

    # disko.simple.impermanence.persist.directories = [
    #   "/var/lib/netbird"
    # ];
  };
}
