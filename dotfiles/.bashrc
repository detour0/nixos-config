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

dotbak() {
    # Define source and target directories
    local source_dir="$HOME/.config"
    local target_dir="$HOME/nixos-config/dotfiles"
    local backup_dir="$target_dir/backups/$(date +%Y%m%d_%H%M%S)"

    # Files to copy
    local files=(
        "Code/User/settings.json"
        "Code/User/keybindings.json"
        ".bashrc"
        "starship.toml"
        "nvim"
    )

    # Create backup directory if it doesn't exist
    mkdir -p "$backup_dir"

    # Iterate over files and copy them
    for file in "${files[@]}"; do
        local source_file="$source_dir/$file"
        local target_file="$target_dir/$file"

        # Check if the source file exists
        if [[ -e "$source_file" ]]; then
            # If the target file exists, move it to the backup directory
            if [[ -e "$target_file" ]]; then
                mkdir -p "$(dirname "$backup_dir/$file")"
                mv "$target_file" "$backup_dir/$file"
                echo "Backed up $target_file to $backup_dir/$file"
            fi

            # Copy the source file to the target directory
            mkdir -p "$(dirname "$target_file")"
            cp -r "$source_file" "$target_file"
            echo "Copied $source_file to $target_file"
        else
            echo "Source file $source_file does not exist, skipping."
        fi
    done

    echo "Backup and copy completed. Backup directory: $backup_dir"
}
# # Make sure the function is available in the current shell
# export -f nrs
# export -f dotbak

# Aliases
alias ..="cd .."
alias nixconf="code ~/nixos-config"
alias nfc="nix flake check ~/nixos-config"
