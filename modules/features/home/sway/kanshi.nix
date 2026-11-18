{ config, pkgs, ... }:
let
  inherit (config.lib.dotfiles) dir live source;
  kanshiConfig = "${dir}/kanshi/config";
in
{
  services.kanshi.enable = true;
  xdg.configFile."kanshi/config".source = source "kanshi/config";

  home.packages = [
    # Appends the current output layout to the kanshi dotfile in the repo as a new profile
    (pkgs.writeShellScriptBin "kanshi-profile" ''
      name=$1

      if [ -z "$name" ]; then
          echo "Usage: $0 <name>"
          exit 1
      fi
      if [ ! -f ${kanshiConfig} ]; then
          echo "${kanshiConfig} not found: set dir in lib/user-manager.nix to the repo's dotfiles/"
          exit 1
      fi

      echo "Saving profile $name"
      echo "Saving to ${kanshiConfig}"

      {
        echo -e "\nprofile $name {"
        swaymsg -t get_outputs |
          jq -r '.[] | "  output '"'"'\(.make) \(.model) \(.serial)'"'"' mode \(.current_mode.width)x\(.current_mode.height) position \(.rect.x),\(.rect.y)"'
        echo "}"
      } >> ${kanshiConfig}
      ${if live then "" else ''echo "Rebuild to activate it: kanshi reads a store copy of this file"''}
    '')
  ];
}
