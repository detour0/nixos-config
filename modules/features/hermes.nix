{
  config,
  lib,
  options,
  ...
}:
let
  cfg = config.features.hermes;
in

# Provider login for nous-free: 'hermes auth add nous'.
# A fallback provider ignores key_env and api_key and complains about an empty
# OPENROUTER_API_KEY instead; once that is set it works for one message, then fails again.
# The hermes-agent NixOS module is imported per host in flake.nix; without it this does nothing.
{
  options.features.hermes.enable = lib.mkEnableOption "hermes agent";

  config = lib.optionalAttrs (options.services ? hermes-agent) (
    lib.mkIf cfg.enable {
      # Native systemd service, no container
      services.hermes-agent = {
        enable = true;
        environmentFiles = [ config.sops.secrets.hermes_env.path ];
        addToSystemPackages = true;
        restart = "always";
        restartSec = 5;

        settings = {
          model = {
            provider = "nous";
            default = "tencent/hy3:free";
          };

          documents = { };

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

          display.compact = true;
        };
      };
    }
  );
}
