{ pkgs, ... }:
let
  c = import ./everforest.nix;
  urgency = frame: timeout: {
    background = c.bg0;
    foreground = c.fg;
    frame_color = frame;
    inherit timeout;
  };
in
{
  # D-Bus activated user service: starts on the first notification, no `exec` in the sway config.
  # Keyboard control lives in dotfiles/sway/config via `dunstctl`.
  services.dunst = {
    enable = true;
    settings = {
      global = {
        follow = "mouse";
        origin = "top-right";
        offset = "(10, 10)";
        width = 350;
        # Up to 8 popups on screen; beyond that dunst folds the rest into a "(N more)" line.
        notification_limit = 8;
        gap_size = 6;
        padding = 10;
        horizontal_padding = 12;
        frame_width = 2;
        corner_radius = 8;
        separator_color = "frame";
        font = "JetBrainsMono Nerd Font 10";
        markup = "full";
        format = "<b>%s</b>\\n%b";
        icon_position = "left";
        max_icon_size = 48;
        history_length = 50;
        show_indicators = true;
        dmenu = "${pkgs.rofi}/bin/rofi -dmenu -p dunst";
        browser = "${pkgs.xdg-utils}/bin/xdg-open";
        mouse_left_click = "do_action, close_current";
        mouse_middle_click = "close_all";
        mouse_right_click = "close_current";
      };

      urgency_low = urgency c.bg3 8;
      urgency_normal = urgency c.green 16 // {
        highlight = c.green;
      };
      urgency_critical = urgency c.red 0 // {
        highlight = c.red;
      };
    };
  };
}
