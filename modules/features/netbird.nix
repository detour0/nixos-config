{
  lib,
  config,
  pkgsUnstable,
  ...
}:
let
  cfg = config.features.netbird;
in
{
  options.features.netbird = {
    enable = lib.mkEnableOption "the NetBird client wt0";

    # Not wired up yet: the module's login unit greps for "Connected", which "Disconnected"
    # matches too, so it never logs in. Until then: `netbird-wt0 up --setup-key ...` once per host.
    setupKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to the file containing the setup key.";
      example = "/etc/netbird/setup-key";
    };
  };

  config = lib.mkIf cfg.enable {
    services.netbird = {
      package = pkgsUnstable.netbird;
      # Daemon only; the module would add a UI and menu entry on any machine with a desktop session.
      ui.enable = false;
      clients.wt0 = {
        # WireGuard listen port
        port = 51821;
        # Ports for direct connections without a relay
        openFirewall = true;
        # Ports on the client's own interface
        openInternalFirewall = true;
      };
    };
  };
}
