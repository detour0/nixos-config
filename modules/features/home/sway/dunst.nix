{ pkgs, ... }:
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
        notification_limit = 5;
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

      # catppuccin mocha
      urgency_low = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        frame_color = "#45475a";
        timeout = 4;
      };
      urgency_normal = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        frame_color = "#89b4fa";
        timeout = 8;
      };
      urgency_critical = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        frame_color = "#f38ba8";
        timeout = 0;
      };
    };
  };
}
