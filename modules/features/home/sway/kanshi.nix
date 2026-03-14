{ config, pkgs, ... }:
let
  # Use string concatenation - prevents Nix from copying to store
  kanshiPath = "${config.home.homeDirectory}/workspace/nixos-config/dotfiles/kanshi/config";
in
{
  services.kanshi = {
    enable = true;
    # systemdTarget = "sway-session.target";
  };
  home.packages = [
    (pkgs.writeShellScriptBin "kanshi-profile" ''
      name=$1

      if [ -z "$name" ]; then
          echo "Usage: $0 <name>"
          exit 1
      fi

      echo "Saving profile $name"
      echo "Saving to ${kanshiPath}"


      echo -e "\nprofile $name {" >> ${kanshiPath}
      swaymsg -t get_outputs | \
        jq '.[] | "  output '"'"'\(.make) \(.model) \(.serial)'"'"' mode \(.current_mode.width)x\(.current_mode.height) position \(.rect.x),\(.rect.y)"' -r \
        >> ${kanshiPath}
      echo "}" >> ${kanshiPath}

    '')
  ];

  # Symlink the config file
  xdg.configFile."kanshi/config".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/workspace/nixos-config/dotfiles/kanshi/config";
}
