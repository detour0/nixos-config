{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib)
    concatMapStrings
    concatStringsSep
    escapeShellArg
    mapAttrs
    mapAttrsToList
    mkIf
    mkMerge
    mkOption
    stringToCharacters
    substring
    toHexString
    types
    ;
  cfg = config.server.forgejoRunners;
  fj = config.server.forgejo;
  fjCfg = config.services.forgejo;
  host = config.networking.hostName;
  # Same pinned nixpkgs as Forgejo itself (see forgejo.nix), so server and runner move together
  pinned = inputs.nixpkgs-forgejo.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  # Generated runner secrets, root-only. Not backed up: a lost secret only means a new registration.
  secretsDir = "/var/lib/forgejo-runner-secrets";

  # Offline registration (forgejo.org/docs/latest/admin/actions/registration/#offline-registration):
  # the secret is 40 hex characters, and Forgejo derives the runner's UUID from its first 16, ASCII-hex-
  # encoded. So the first 16 are the instance's fixed, non-secret id from Nix, and the last 24 are random
  # bytes generated once on the host. The UUID is then known at evaluation time, as the module wants it.
  # The ASCII codes of 0-9a-f are 0x30-0x39 and 0x61-0x66, so toHexString yields no letters to case.
  uuidOf =
    id:
    let
      hex = concatMapStrings (c: toHexString (lib.strings.charToInt c)) (stringToCharacters id);
    in
    concatStringsSep "-" [
      (substring 0 8 hex)
      (substring 8 4 hex)
      (substring 12 4 hex)
      (substring 16 4 hex)
      (substring 20 12 hex)
    ];

  forgejoCli = ''
    forgejo --work-path ${escapeShellArg fjCfg.stateDir} \
      --config ${escapeShellArg "${fjCfg.customDir}/conf/app.ini"}'';

  instanceModule = {
    options = {
      id = mkOption {
        type = types.strMatching "[0-9a-f]{16}";
        example = "26f7490333c4f02e";
        description = ''
          Fixed first half of the runner secret (od -An -tx1 -N8 /dev/urandom | tr -d ' \n'), not
          secret: it only determines the runner's UUID. Unique per instance. Changing it makes a new
          runner; delete the old one in the web UI.
        '';
      };
      scope = mkOption {
        type = types.str;
        default = "";
        example = "homelab";
        description = ''
          Who the runner takes jobs from: "" for every repo of the instance, "<owner>" for one user or
          organization, "<owner>/<repo>" for one repo. Until the owner exists, registration retries.
        '';
      };
      labels = mkOption {
        type = types.listOf types.str;
        # Each job in a throwaway container. A native ":host" label comes later, for deploys and nix builds.
        default = [ "docker:docker://node:22-bookworm" ];
      };
      capacity = mkOption {
        type = types.ints.positive;
        default = 1;
      };
    };
  };

  perInstance =
    name: inst:
    let
      unit = "forgejo-runner-${name}";
      secretFile = "${secretsDir}/${name}";
    in
    {
      instance = {
        enable = true;
        settings = {
          log.level = "info";
          runner = {
            inherit (inst) capacity labels;
          };
          container = {
            # The runner uses the host's Docker socket to start job containers, but never mounts
            # it into them: a job must not control the daemon the production stacks run on.
            docker_host = "-";
            privileged = false;
            # Jobs may not mount host paths
            valid_volumes = [ ];
          };
          server.connections.forgejo = {
            # Straight to Forgejo, not through Traefik
            url = "http://${fj.listenAddress}:${toString fj.port}/";
            uuid = uuidOf inst.id;
          };
        };
        secrets.server.connections.forgejo.token_url = secretFile;
      };

      units = {
        # Writes id + 24 random hex once, and again only if the id in Nix changed.
        "${unit}-secret" = {
          description = "Forgejo runner ${name}: generate secret";
          restartTriggers = [ inst.id ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            StateDirectory = baseNameOf secretsDir;
            StateDirectoryMode = "0700";
            UMask = "0077";
          };
          script = ''
            f="$STATE_DIRECTORY"/${escapeShellArg name}
            id=${escapeShellArg inst.id}
            if [ -s "$f" ] && [ "$(head -c 16 "$f")" = "$id" ]; then
              exit 0
            fi
            rand=$(od -An -tx1 -N12 /dev/urandom | tr -d ' \n')
            printf '%s%s' "$id" "$rand" > "$f.tmp"
            mv "$f.tmp" "$f"
            echo "secret for runner ${name}: generated"
          '';
        };

        # Registers the runner (or updates its name and scope: idempotent) through the Forgejo CLI.
        # Retries forever, e.g. until the org named in scope exists.
        "${unit}-register" = {
          description = "Forgejo runner ${name}: register with Forgejo";
          requires = [ "${unit}-secret.service" ];
          after = [
            "${unit}-secret.service"
            "forgejo.service"
          ];
          wants = [ "forgejo.service" ];
          restartTriggers = [
            inst.id
            inst.scope
          ];
          path = [ fjCfg.package ];
          startLimitIntervalSec = 0;
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            User = fjCfg.user;
            Group = fjCfg.group;
            LoadCredential = "secret:${secretFile}";
            Restart = "on-failure";
            RestartSec = "30s";
          };
          script = ''
            ${forgejoCli} \
              forgejo-cli actions register --name ${escapeShellArg "${host}-${name}"} \
              --scope ${escapeShellArg inst.scope} --secret-file "$CREDENTIALS_DIRECTORY/secret" >/dev/null
            echo "runner ${host}-${name}: registered (scope: ${if inst.scope == "" then "instance" else inst.scope})"
          '';
        };

        # wants, not requires: if registration still fails, the runner starts anyway and keeps
        # restarting (upstream Restart=on-failure) until the register unit has succeeded.
        ${unit} = {
          wants = [ "${unit}-register.service" ];
          after = [ "${unit}-register.service" ];
          restartTriggers = [ inst.id ];
        };
      };
    };
in
{
  # services.forgejo-runner is new in NixOS 26.11. Drop this import once schiggi is on 26.11.
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/continuous-integration/forgejo-runner.nix"
  ];

  options.server.forgejoRunners = mkOption {
    type = types.attrsOf (types.submodule instanceModule);
    default = { };
    description = ''
      Forgejo Actions runners on the host's Docker daemon, one systemd unit set per instance
      (forgejo-runner-<name>{,-secret,-register}). Registration is automatic, no sops secret.
    '';
  };

  config = mkIf (cfg != { }) {
    assertions = [
          {
            assertion = fj.enable && config.virtualisation.docker.enable;
            message = "server.forgejoRunners needs server.forgejo and Docker on the same host.";
          }
          {
            assertion =
              let
                ids = mapAttrsToList (_: i: i.id) cfg;
              in
              lib.length ids == lib.length (lib.unique ids);
            message = "server.forgejoRunners: every instance needs its own id.";
          }
        ];
    services.forgejo-runner = {
      package = pinned.forgejo-runner;
      instances = mapAttrs (name: inst: (perInstance name inst).instance) cfg;
    };
    # The top-level keys must not depend on cfg (infinite recursion), hence one mkMerge per option
    systemd.services = mkMerge (mapAttrsToList (name: inst: (perInstance name inst).units) cfg);
  };
}
