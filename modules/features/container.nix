{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    elem
    mkEnableOption
    mkIf
    mkOption
    optional
    optionals
    types
    ;
  cfg = config.features.container;
  docker = elem cfg.runtime [
    "docker"
    "both"
  ];
  podman = elem cfg.runtime [
    "podman"
    "both"
  ];
  # Docker reads DNS from /etc/resolv.conf, which containers cannot use on NixOS
  dns = config.networking.nameservers;
in
{
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
    virtualisation.docker = mkIf docker {
      enable = !cfg.rootless;

      rootless = mkIf cfg.rootless {
        enable = true;
        setSocketVariable = true;
        daemon.settings = { inherit dns; };
      };

      daemon.settings = mkIf (!cfg.rootless) {
        inherit dns;
        log-driver = "json-file";
        log-opts = {
          max-size = "300m";
          max-file = "5";
        };
      };
    };

    virtualisation.podman = mkIf podman {
      enable = true;
      dockerCompat = cfg.runtime == "both";
      defaultNetwork.settings.dns_enabled = true;
    };

    environment.systemPackages = optionals cfg.compose (
      optional docker pkgs.docker-compose
      ++ optional podman pkgs.podman-compose
      ++ optional docker pkgs.lazydocker
    );

    networking.firewall.trustedInterfaces = mkIf (!cfg.rootless) [
      "docker0"
      "br-+"
    ];
  };
}
