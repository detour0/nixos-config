{ config, pkgs, ... }:

{
  services.hermes-agent = {
    enable = true; # native systemd service, no container

    settings = {
      model = {
        provider = "nous";
        default = "tencent/hy3"; # hy3 from Nous as the standard model
      };

      fallback_providers = [
        {
          provider = "custom";
          model = "mistral-medium";
          base_url = "100.74.11.59:4000/v1";
          key_env = "LITELLM_KEY";
        }
      ];

      # ── Secrets ────────────────────────────────────────────────────────
      environmentFiles = [ config.sops.secrets."hermes_env".path ];

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

    # Free-plan Portal auth needs no API key. Add a key later via an
    # env file rather than inlining it:
    # environmentFiles = [ /var/lib/hermes/env ];

    # ── Service tuning ─────────────────────────────────────────────────
    addToSystemPackages = true;
    extraArgs = [ ]; # e.g. [ "--verbose" ]
    restart = "always";
    restartSec = 5;

    extraPackages = with pkgs; [ ]; # tools the agent can call
  };
}
