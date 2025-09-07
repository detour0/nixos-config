[[ $- == *i* ]] || return

HISTFILESIZE=100000
HISTSIZE=10000

shopt -s histappend
shopt -s checkwinsize
shopt -s extglob
shopt -s globstar
shopt -s checkjobs

if [[ ! -v BASH_COMPLETION_VERSINFO ]]; then
  . "/nix/store/knkgz12zyg83w9g61xys6qjxwxgmymh5-bash-completion-2.14.0/etc/profile.d/bash_completion.sh"
fi

# Shortcut function for rebuilding and testing NixOs config
nrs() {
  if [ $# -eq 0 ]; then
    echo "Error: hostname required"
    return 1
  fi

  local hostname="$1"
  local flake_path="~/workspace/nixos-config"
  local cmd="sudo nixos-rebuild switch --flake $flake_path#$hostname"

  case "$2" in
    -r)
      echo "Running '$cmd' and rebooting..."
      $cmd && sudo reboot now
      ;;
    -t)
      cmd="sudo nixos-rebuild test --flake $flake_path#$hostname"
      echo "Running '$cmd'"
      $cmd
      ;;
    -s)
      echo "Running '$cmd' and shutting down..."
      $cmd && sudo shutdown now
      ;;
    *)
      echo "Running '$cmd'..."
      $cmd
      ;;
  esac
}

# Aliases
alias ..="cd .."
alias cdc="cd ~/mega/coding"
alias nixconf="code ~/workspace/nixos-config"
alias nfc="nix flake check ~/workspace/nixos-config"
alias nfu="nix flake update ~/workspace/nixos-config"
alias vimdiff='nvim -d'

# Direnv shell hook
eval "$(direnv hook bash)"
