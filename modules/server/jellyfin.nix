{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.server.jellyfin;
  jfCfg = config.services.jellyfin;
in
{
  options.server.jellyfin = {
    enable = mkEnableOption "Jellyfin media server (netbird only)";

    mediaDir = mkOption {
      type = types.str;
      default = "/srv/media";
      description = "Media root, owned by the admin user; libraries are set up in the Jellyfin UI.";
    };

    owner = mkOption {
      type = types.str;
      description = "User who owns mediaDir and copies media into it.";
    };

    memoryMax = mkOption {
      type = types.str;
      default = "1536M";
      description = "systemd MemoryMax for jellyfin, so a runaway scan cannot push the other services into OOM.";
    };
  };

  config = mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      # Unstable on purpose (12.x, unpinned): `nix flake update` can run a database migration.
      # Back up /var/lib/jellyfin before updating nixpkgs-unstable.
      package = pkgsUnstable.jellyfin;
      # Opens 8096 on every interface; only wt0 below
      openFirewall = false;

      # Skylake iGPU (HD 530): H.264 and HEVC 8-bit in hardware. Only used for video.
      hardwareAcceleration = {
        enable = true;
        type = "vaapi";
        device = "/dev/dri/renderD128";
      };
    };

    hardware.graphics = {
      enable = true;
      extraPackages = [ pkgs.intel-media-driver ];
    };

    systemd.services.jellyfin.serviceConfig.MemoryMax = cfg.memoryMax;

    # netbird only. Docker bridges are trusted interfaces, so containers on this host can reach it too.
    networking.firewall.interfaces.wt0.allowedTCPPorts = [ 8096 ];

    # World-readable so the jellyfin user can read it; music goes to ${cfg.mediaDir}/music
    systemd.tmpfiles.rules = [
      "d ${cfg.mediaDir} 0755 ${cfg.owner} users -"
      "d ${cfg.mediaDir}/music 0755 ${cfg.owner} users -"
    ];

    users.users.${jfCfg.user}.extraGroups = [
      "render"
      "video"
    ];
  };
}
