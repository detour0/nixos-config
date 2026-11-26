# Apply or build hosts. `just d all`, `just d shaundi schiggi`, `just b all`.
# shaundi is applied locally with nixos-rebuild; the servers go through deploy-rs (`deploy.nodes` in flake.nix).
# SSH keys have passphrases: ssh-agent asks once, then caches them.

self := "shaundi"
servers := "schiggi digda"

# List recipes
default:
    @just --list

# Deploy hosts (names or `all`): servers via deploy-rs first, then shaundi via nixos-rebuild
d +hosts:
    #!/usr/bin/env bash
    set -euo pipefail
    hosts="{{hosts}}"
    [ "$hosts" = all ] && hosts="{{self}} {{servers}}"
    targets=() apply_self=0
    for h in $hosts; do
      case " {{servers}} " in *" $h "*) targets+=(".#$h"); continue ;; esac
      if [ "$h" = "{{self}}" ]; then apply_self=1
      else echo "unknown host: $h (known: {{self}} {{servers}}, or all)" >&2; exit 1; fi
    done
    if [ ${#targets[@]} -gt 0 ]; then deploy --targets "${targets[@]}"; fi
    if [ $apply_self = 1 ]; then sudo nixos-rebuild switch --flake .#{{self}}; fi

# Build hosts (names or `all`) without applying; needs no root
b +hosts:
    #!/usr/bin/env bash
    set -euo pipefail
    hosts="{{hosts}}"
    [ "$hosts" = all ] && hosts="{{self}} {{servers}}"
    attrs=()
    for h in $hosts; do
      case " {{self}} {{servers}} " in *" $h "*) ;; *) echo "unknown host: $h (known: {{self}} {{servers}}, or all)" >&2; exit 1 ;; esac
      attrs+=(".#nixosConfigurations.$h.config.system.build.toplevel")
    done
    nix build --no-link "${attrs[@]}"

# For you only: agents are kept out by a Claude Code deny rule, not here (`! just gh-push` in a Claude session
# sets AI_AGENT too). Pulls main from Forgejo first (fast-forward only) and pushes Forgejo's main, so GitHub always
# gets the newest version, never unpushed local commits. A repo whose main can't fast-forward (diverged, or
# uncommitted changes in the way) fails and isn't pushed. Never forces, so a rewritten history is rejected.
# Pull main from Forgejo, push it + tags of nixos-config, nix-secrets, sway-workrooms to GitHub (fallback copy)
gh-push:
    #!/usr/bin/env bash
    set -uo pipefail
    # without AI_AGENT, ssh uses your keys instead of the agent block (modules/profiles/core.nix)
    git() { env -u AI_AGENT git "$@"; }
    failed=()
    for r in nixos-config nix-secrets sway-workrooms; do
      d=~/workspace/$r
      echo "== $r"
      git -C "$d" fetch -q --tags origin && git -C "$d" fetch -q github || { failed+=("$r"); continue; }
      if [ "$(git -C "$d" symbolic-ref -q --short HEAD)" = main ]; then
        git -C "$d" merge -q --ff-only origin/main
      else
        git -C "$d" fetch -q origin main:main
      fi || { echo "   could not fast-forward local main to Forgejo's (diverged or dirty checkout), not pushed" >&2; failed+=("$r"); continue; }
      ahead=$(git -C "$d" rev-list --count origin/main..main)
      [ "$ahead" = 0 ] || echo "   note: local main has $ahead commit(s) not on Forgejo, not pushed"
      git -C "$d" log --oneline github/main..origin/main | sed 's/^/   /'
      git -C "$d" push --follow-tags github origin/main:refs/heads/main || failed+=("$r")
    done
    [ ${#failed[@]} -eq 0 ] || { echo "failed: ${failed[*]}" >&2; exit 1; }
