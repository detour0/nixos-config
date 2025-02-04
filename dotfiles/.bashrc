# Shortcut function for rebuilding and testing NixOs config
nrs() {
  if [ "$1" = "-r" ]; then
    echo "Running 'sudo nixos-rebuild switch' and rebooting..."
    sudo nixos-rebuild switch && sudo reboot now
  elif [ "$1" = "-t" ]; then
    echo "Running 'sudo nixos-rebuild test'"
    sudo nixos-rebuild test
  else
    echo "Running 'sudo nixos-rebuild switch'..."
    sudo nixos-rebuild switch
  fi
}

# Make sure the function is available in the current shell
export -f nrs

# Aliases
alias ..="cd .."
alias nixconf="code ~/nixos-config"
alias nfc="nix flake check ~/nixos-config"
