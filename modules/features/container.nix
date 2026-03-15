{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.features.container;
in
{
  # 1. OPTIONS: what this feature exposes
  options.features.container = {
    enable = mkEnableOption "container runtimes";

    runtime = mkOption {
      type = types.enum [
        "docker"
        "podman"
        "both"
      ];
      default = "docker";
      description = "Container runtime to enable";
    };

    compose = mkOption {
      type = types.bool;
      default = true;
      description = "Include docker-compose/podman-compose";
    };
    rootless = mkOption {
      type = types.bool;
      default = true;
      description = "Run docker in rootless mode";
    };
  };

  config = mkIf cfg.enable {
    # Docker runtime
    virtualisation.docker = mkIf (cfg.runtime == "docker" || cfg.runtime == "both") {
      enable = mkIf (!cfg.rootless) true;

      # Conditionally enable rootless mode
      rootless = mkIf cfg.rootless {
        enable = true;
        setSocketVariable = true;
        daemon.settings.dns = [
          "1.1.1.1"
          "9.9.9.9"
        ];
      };

      # Rootful daemon settings (only when NOT rootless)
      daemon.settings = mkIf (!cfg.rootless) {
        dns = [
          "1.1.1.1"
          "9.9.9.9"
        ];
      };
    };

    # Podman runtime
    virtualisation.podman = mkIf (cfg.runtime == "podman" || cfg.runtime == "both") {
      enable = true;
      dockerCompat = cfg.runtime == "both";
      defaultNetwork.settings.dns_enabled = true;
    };

    # Compose tool (runtime-agnostic)
    environment.systemPackages = optionals cfg.compose (
      (optional (cfg.runtime == "docker" || cfg.runtime == "both") pkgs.docker-compose)
      ++ (optional (cfg.runtime == "podman" || cfg.runtime == "both") pkgs.podman-compose)
    );

    # Groups for socket access
    # users.groups.docker = mkIf (cfg.runtime == "docker" || cfg.runtime == "both") { };
  };
}
