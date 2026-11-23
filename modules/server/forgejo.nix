{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.server.forgejo;
  fjCfg = config.services.forgejo;
  inherit (inputs.nix-secrets.users) dt;
  agent = inputs.nix-secrets.agents.claude;
  inherit (inputs.nix-secrets) domain;
  # Forgejo comes from its own nixpkgs input, pinned to a fixed rev in flake.nix, so
  # `nix flake update` never moves it. Upgrade by hand: dump first, then bump that rev.
  pinned = inputs.nixpkgs-forgejo.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  # Step of /etc/bootstrap (modules/system/bootstrap.nix), see bootstrap.steps.forgejo below
  bootstrapStep = {
    user = fjCfg.user;
    runtimeInputs = [
      fjCfg.package
      config.services.postgresql.package
      pkgs.curl
      pkgs.jq
      pkgs.gawk
    ];
    script = ''
      # Every value from Nix is shell-quoted here and reaches SQL only as a psql variable.
      api=${lib.escapeShellArg "http://${cfg.listenAddress}:${toString cfg.port}/api"}
      domain=${lib.escapeShellArg domain}
      dt_name=${lib.escapeShellArg dt.name}
      dt_email=${lib.escapeShellArg dt.email.private}
      key=${lib.escapeShellArg dt.sshPub}
      agent_name=${lib.escapeShellArg agent.name}
      agent_email=${lib.escapeShellArg "${agent.name}@noreply.${domain}"}
      agent_key=${lib.escapeShellArg agent.sshPub}

      # HOME is the forgejo user's state dir, which Forgejo itself can write: -X and -q keep
      # ~/.psqlrc and ~/.curlrc out of this step.
      fj() {
        forgejo --work-path ${lib.escapeShellArg fjCfg.stateDir} \
          --config ${lib.escapeShellArg "${fjCfg.customDir}/conf/app.ini"} "$@"
      }
      db() { # query [psql -v name=value ...], referenced as :'name' in the query
        local q=$1
        shift
        # psql only expands variables in queries it reads, not in -c, hence stdin
        psql -X -qtA -v ON_ERROR_STOP=1 -h /run/postgresql -d ${lib.escapeShellArg fjCfg.database.name} "$@" <<<"$q"
      }

      if ! curl -q -fsS "$api/healthz" >/dev/null; then
        echo "Forgejo is not answering at $api (systemctl status forgejo)" >&2
        exit 1
      fi

      create() { # user email [extra flags]
        local user=$1 email=$2
        shift 2
        # awk reads the whole list (no early exit, so no SIGPIPE under pipefail)
        if fj admin user list | awk -v u="$user" 'NR > 1 && $2 == u { found = 1 } END { exit !found }'; then
          echo "user $user: exists, skipped"
          return
        fi
        fj admin user create --username "$user" --email "$email" \
          --random-password --must-change-password "$@"
        echo "user $user: created (note the password above)"
      }
      create forgeadmin "forgeadmin@noreply.$domain" --admin
      create "$dt_name" "$dt_email"
      # The AI agent's own account. Restricted: it sees only repos it gets through a team
      # (homelab → team agents), never the rest of the instance.
      create "$agent_name" "$agent_email" --restricted

      # Each user's SSH key, added through the admin API unless Forgejo already has it.
      # Parallel arrays: owner name, public key.
      key_users=("$dt_name" "$agent_name")
      key_keys=("$key" "$agent_key")
      todo=()
      for i in "''${!key_users[@]}"; do
        u=''${key_users[$i]}
        body=$(cut -d' ' -f2 <<<"''${key_keys[$i]}")
        has_key=$(db "SELECT count(*) FROM public_key k JOIN \"user\" u ON u.id = k.owner_id
          WHERE u.lower_name = lower(:'name') AND strpos(k.content, :'body') > 0" -v name="$u" -v body="$body")
        if [ "$has_key" != 0 ]; then
          echo "ssh key for $u: exists, skipped"
        else
          todo+=("$i")
        fi
      done
      if [ "''${#todo[@]}" -gt 0 ]; then
        # Forgejo rejects API calls from a user who must change their password, so clear
        # forgeadmin's flag for this step and put it back afterwards. The trap also drops the
        # temporary admin token, and says so loudly when either cleanup fails.
        restore_flag=
        cleanup() {
          if ! db "DELETE FROM access_token WHERE name = 'nix-bootstrap'"; then
            echo "WARNING: access token nix-bootstrap of forgeadmin is left over, delete it in the web UI" >&2
          fi
          if [ -n "$restore_flag" ] && ! fj admin user must-change-password forgeadmin >/dev/null; then
            echo "WARNING: forgeadmin no longer has to change its password at first login" >&2
          fi
        }
        trap cleanup EXIT
        if [ "$(db "SELECT must_change_password FROM \"user\" WHERE lower_name = 'forgeadmin'")" = t ]; then
          restore_flag=1
          fj admin user must-change-password --unset forgeadmin >/dev/null
        fi
        db "DELETE FROM access_token WHERE name = 'nix-bootstrap'"
        token=$(fj admin user generate-access-token --username forgeadmin \
          --token-name nix-bootstrap --scopes write:admin --raw)
        for i in "''${todo[@]}"; do
          u=''${key_users[$i]}
          # The header comes from a file descriptor, so the token never shows up in argv (ps)
          jq -n --arg t "$u" --arg k "''${key_keys[$i]}" '{title: $t, key: $k}' |
            curl -q -fsS -X POST -H @<(printf 'Authorization: token %s\n' "$token") \
              -H 'Content-Type: application/json' --data @- "$api/v1/admin/users/$u/keys" >/dev/null
          echo "ssh key for $u: added"
        done
      fi
    '';
  };
in
{
  options.server.forgejo = {
    enable = mkEnableOption "Forgejo git forge";

    listenAddress = mkOption {
      type = types.str;
      default = "127.0.0.1";
    };

    port = mkOption {
      type = types.port;
      default = 3001;
    };

    sshDomain = mkOption {
      type = types.str;
      description = "Host shown in SSH clone URLs. Git over SSH goes through the host's sshd.";
    };
  };

  config = mkIf cfg.enable {
    services.forgejo = {
      enable = true;
      package = pinned.forgejo-lts;

      # Host PostgreSQL over the unix socket with peer auth: no password, no pg_hba line
      database = {
        type = "postgres";
        createDatabase = true;
      };

      lfs.enable = true;

      settings = {
        server = {
          DOMAIN = "git.${domain}";
          ROOT_URL = "https://git.${domain}/";
          PROTOCOL = "http"; # TLS termination belongs to Traefik
          HTTP_ADDR = cfg.listenAddress;
          HTTP_PORT = cfg.port;
          # Shared host sshd: Forgejo writes forced-command entries into the forgejo
          # user's ~/.ssh/authorized_keys, so clone URLs are forgejo@<sshDomain>:owner/repo.git
          START_SSH_SERVER = false;
          SSH_DOMAIN = cfg.sshDomain;
          SSH_PORT = 22;
        };
        service.DISABLE_REGISTRATION = true;
        # New repos start private (the checkbox is pre-ticked; it can still be unticked per repo)
        repository.DEFAULT_PRIVATE = "private";
        actions.ENABLED = true;
        session.COOKIE_SECURE = true;
      };
    };

    # Creates the site admin `forgeadmin`, the normal user `dt` and the restricted agent user `claude`
    # (each of the latter two with its SSH key) unless they exist.
    # Forgejo prints each random password once; it must be changed at first login.
    bootstrap.steps.forgejo = bootstrapStep;
  };
}
