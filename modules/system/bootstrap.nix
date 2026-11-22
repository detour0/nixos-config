{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption types;
  steps = config.bootstrap.steps;
  names = builtins.attrNames steps;
  # a before b when b lists a in `after`
  sorted = lib.toposort (a: b: builtins.elem a steps.${b}.after) names;
  order = sorted.result or (throw "bootstrap.steps: cycle in `after`: ${toString sorted.cycle}");

  # inheritPath = false everywhere: the caller's PATH (under sudo still the user's, with
  # user-writable dirs like ~/.nix-profile/bin) must never decide which binary a step runs.
  stepBin =
    name:
    lib.getExe (
      pkgs.writeShellApplication {
        name = "bootstrap-${name}";
        inheritPath = false;
        runtimeInputs = [ pkgs.coreutils ] ++ steps.${name}.runtimeInputs;
        text = steps.${name}.script;
      }
    );

  # Each step runs as a transient system service, not via runuser: a clean environment,
  # no access to the caller's terminal (a step's user can't read or write the root
  # session), leftover processes die with the unit, and credentials come in through
  # LoadCredential, so their files can stay root-only. --pipe hands systemd-run's own stdio
  # to the step, so run() gives it /dev/null and a pipe instead of the terminal: output
  # still shows here and stays out of the journal. --wait returns the step's exit status.
  runStep =
    n:
    lib.escapeShellArgs (
      [
        "systemd-run"
        "--quiet"
        "--wait"
        "--pipe"
        "--collect"
        "--service-type=exec"
        "--unit=bootstrap-${n}"
        "--property=User=${steps.${n}.user}"
      ]
      ++ lib.mapAttrsToList (c: path: "--property=LoadCredential=${c}:${path}") steps.${n}.credentials
      ++ [ (stepBin n) ]
    );

  bootstrap = pkgs.writeShellApplication {
    name = "bootstrap";
    inheritPath = false;
    runtimeInputs = [
      pkgs.coreutils
      config.systemd.package
    ];
    text = ''
      order=(${lib.escapeShellArgs order})
      run() {
        case $1 in
      ${lib.concatMapStrings (n: ''
        ${lib.escapeShellArg n})
          echo "==> ${n} (as ${steps.${n}.user})"
          ${runStep n} </dev/null 2>&1 | cat
          ;;
      '') order}
          *)
            echo "unknown step: $1 (see $0 --list)" >&2
            exit 1
            ;;
        esac
      }

      if [ "''${1-}" = --list ]; then
        printf '%s\n' ${lib.escapeShellArgs (map (n: "${n} (as ${steps.${n}.user})") order)}
        exit
      fi
      if [ "$(id -u)" != 0 ]; then
        echo "run as: sudo $0 [step...]" >&2
        exit 1
      fi
      cd /
      if [ $# -eq 0 ]; then
        set -- "''${order[@]}"
      fi
      for s in "$@"; do
        run "$s"
      done
      echo "==> done"
    '';
  };
in
{
  options.bootstrap.steps = mkOption {
    description = ''
      Steps of /etc/bootstrap: one-off setup that state on disk can't hold, run by hand after a fresh install
      with `sudo /etc/bootstrap` (all steps in order), `sudo /etc/bootstrap <step>...` (only those) or
      `/etc/bootstrap --list`. Not on PATH on purpose. Modules add their own step when enabled.
      Every step must be idempotent: a second run has to be harmless.
    '';
    default = { };
    type = types.attrsOf (
      types.submodule {
        options = {
          user = mkOption {
            type = types.str;
            default = "root";
            description = "User the step's transient service runs as.";
          };
          after = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Steps that must run before this one.";
          };
          runtimeInputs = mkOption {
            type = types.listOf types.package;
            default = [ ];
            description = "The step's whole PATH, besides coreutils. The caller's PATH is not inherited.";
          };
          credentials = mkOption {
            type = types.attrsOf types.str;
            default = { };
            example = {
              token = "/run/secrets/some_token";
            };
            description = ''
              Files the step reads as `$CREDENTIALS_DIRECTORY/<name>` (systemd LoadCredential, read by
              root), so a secret needs no owner of its own for the step.
            '';
          };
          script = mkOption {
            type = types.lines;
            description = "Bash, run with `set -euo pipefail` and checked by shellcheck at build time.";
          };
        };
      }
    );
  };

  config = lib.mkIf (steps != { }) {
    assertions = lib.concatMap (
      n:
      map (d: {
        assertion = steps ? ${d};
        message = "bootstrap.steps.${n}.after: there is no step named ${d}";
      }) steps.${n}.after
    ) names;

    environment.etc.bootstrap.source = lib.getExe bootstrap;
  };
}
