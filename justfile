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
