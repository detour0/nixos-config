{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

with lib;

let
  cfg = config.features.hermes;
in
{
  # 1. OPTIONS: what this feature exposes
  options.features.hermes = {
    enable = mkEnableOption "hermes agent";
  };
  config = mkIf cfg.enable {
    services.hermes-agent = {
      enable = true; # native systemd service, no container

      # ── Secrets ────────────────────────────────────────────────────────
      environmentFiles = [ config.sops.secrets."hermes_env".path ];

      settings = {
        model = {
          provider = "nous";
          default = "tencent/hy3"; # hy3 from Nous as the standard model
        };

        fallback_providers = [
          {
            provider = "custom";
            model = "mistral-medium";
            base_url = "http://${inputs.nix-secrets.networking.schiggi.netbirdIp}:4000";
            key_env = "LITELLM_KEY";
          }
        ];

        # ── Documents ──────────────────────────────────────────────────────
        documents = {
          # "USER.md" = ../../dotfiles/agents/documents/USER.md;
        };

        toolsets = [ "all" ];

        terminal = {
          backend = "docker";
          cwd = ".";
          timeout = 180;
        };

        agent = {
          max_turns = 30;
          verbose = false;
        };

        compression = {
          enabled = true;
          threshold = 0.85;
        };

        memory = {
          memory_enabled = true;
          user_profile_enabled = true;
        };

        display = {
          compact = true;
        };
      };

      # ── Service tuning ─────────────────────────────────────────────────
      addToSystemPackages = true;
      extraArgs = [ ]; # e.g. [ "--verbose" ]
      restart = "always";
      restartSec = 5;

      extraPackages = with pkgs; [ ]; # tools the agent can call
    };
  };
}
