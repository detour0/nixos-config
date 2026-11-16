{
  config,
  lib,
  pkgs,
  ...
}:
let
  # everforest dark hard (neanias/everforest-nvim)
  c = {
    bg_dim = "#1e2326";
    bg0 = "#272e33";
    bg_red = "#493b40";
    bg_green = "#3c4841";
    fg = "#d3c6aa";
    red = "#e67e80";
    green = "#a7c080";
    grey1 = "#859289";
  };

  # Destructive actions go through a one-entry rofi prompt: Enter runs it, Esc cancels.
  power-confirm = pkgs.writeShellApplication {
    name = "power-confirm";
    runtimeInputs = with pkgs; [
      rofi
      sway
      systemd
    ];
    text = ''
      case "''${1:-}" in
        exit) cmd=(swaymsg exit) ;;
        reboot) cmd=(systemctl reboot) ;;
        poweroff) cmd=(systemctl poweroff) ;;
        *) echo "usage: power-confirm exit|reboot|poweroff" >&2; exit 1 ;;
      esac

      if echo "$1" | rofi -dmenu -no-custom -i \
        -p "confirm" -mesg "Enter to $1, Esc to cancel" \
        -theme-str '
          * { background-color: ${c.bg0}; text-color: ${c.fg}; font: "JetBrainsMono Nerd Font Bold 12"; }
          window { width: 360px; border: 2px; border-color: ${c.red}; border-radius: 8px; padding: 12px; }
          inputbar { enabled: false; }
          message { border: 0; padding: 0 0 8px 0; }
          textbox { text-color: ${c.grey1}; }
          listview { lines: 1; fixed-height: false; scrollbar: false; border: 0; }
          element { padding: 6px; border-radius: 6px; }
          element selected.normal { background-color: ${c.bg_red}; text-color: ${c.red}; }
        ' >/dev/null; then
        "''${cmd[@]}"
      fi
    '';
  };

  # `swaymsg exec` detaches, so wlogout closes before the rofi prompt opens
  confirm = action: "swaymsg exec '${power-confirm}/bin/power-confirm ${action}'";
  # Pixel-art version of the wallpaper: tiny PNG, sharp blocks, drawn without scaling.
  # GTK3 can only scale smoothly (blurry), so the blocks are enlarged at build time instead.
  background =
    pkgs.runCommand "wlogout-background.png" { nativeBuildInputs = [ pkgs.imagemagick ]; }
      ''
        # everforest dark hard: backgrounds, accents, greys
        magick ${
          lib.concatMapStringsSep " " (x: "xc:'${x}'") [
            "#1e2326"
            "#272e33"
            "#2e383c"
            "#374145"
            "#414b50"
            "#495156"
            "#4f5b58"
            "#4c3743"
            "#493b40"
            "#3c4841"
            "#384b55"
            "#45443c"
            "#463f48"
            "#d3c6aa"
            "#e67e80"
            "#e69875"
            "#dbbc7f"
            "#a7c080"
            "#83c092"
            "#7fbbb3"
            "#d699b6"
            "#7a8478"
            "#859289"
            "#9da9a0"
          ]
        } +append palette.png
        # 320x180, dimmed, snapped to the palette without dithering: flat pixel-art blocks
        magick ${config.wallpaper} -resize 320x180^ -gravity center -extent 320x180 \
          -fill "${c.bg_dim}" -colorize 45 -dither None -remap palette.png small.png
        # 8x nearest-neighbour to 2560x1440, the largest output, so GTK never rescales it
        magick small.png -filter point -resize 800% -define png:compression-level=9 $out
      '';

  icon = name: ''image(url("${pkgs.wlogout}/share/wlogout/icons/${name}.png"))'';
in
{
  programs.wlogout = {
    enable = true;

    # 3x2 grid (`wlogout -b 3`): safe actions on top, destructive ones below
    layout = [
      {
        label = "lock";
        action = "swaylock -f";
        text = "[l]ock";
        keybind = "l";
      }
      {
        label = "suspend";
        action = "systemctl suspend";
        text = "[s]uspend";
        keybind = "s";
      }
      {
        label = "hibernate";
        action = "systemctl hibernate";
        text = "[h]ibernate";
        keybind = "h";
      }
      {
        label = "exit";
        action = confirm "exit";
        text = "[e]xit";
        keybind = "e";
      }
      {
        label = "reboot";
        action = confirm "reboot";
        text = "[r]eboot";
        keybind = "r";
      }
      {
        label = "poweroff";
        action = confirm "poweroff";
        text = "[p]oweroff";
        keybind = "p";
      }
    ];

    # Flat, borderless tiles that touch, over the dimmed wallpaper
    style = ''
      * {
        background-image: none;
        box-shadow: none;
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-weight: bold;
        font-size: 16px;
      }

      window {
        background-image: url("${background}");
        /* Drawn 1:1, never scaled: 1440p shows it whole, 1080p shows the centre */
        background-size: auto;
        background-repeat: no-repeat;
        background-color: ${c.bg_dim};
        background-position: center;
      }

      button {
        color: ${c.grey1};
        background-color: ${c.bg0};
        border-width: 0;
        border-radius: 0;
        margin: 0;
        opacity: 0.9;
        background-repeat: no-repeat;
        background-position: center;
        background-size: 25%;
      }

      button:focus,
      button:hover {
        color: ${c.green};
        background-color: ${c.bg_green};
        box-shadow: inset 0 -4px ${c.green};
        opacity: 1;
        outline-style: none;
      }

      #exit:focus, #exit:hover,
      #reboot:focus, #reboot:hover,
      #poweroff:focus, #poweroff:hover {
        color: ${c.red};
        background-color: ${c.bg_red};
        box-shadow: inset 0 -4px ${c.red};
      }

      #lock { background-image: ${icon "lock"}; }
      #exit { background-image: ${icon "logout"}; }
      #suspend { background-image: ${icon "suspend"}; }
      #hibernate { background-image: ${icon "hibernate"}; }
      #reboot { background-image: ${icon "reboot"}; }
      #poweroff { background-image: ${icon "shutdown"}; }
    '';
  };
}
