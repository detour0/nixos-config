# Port of dotfiles/wezterm.lua (best effort).
{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      # wezterm: color_scheme = "Everforest Dark Hard (Gogh)"; this is the iTerm2 variant, close but not identical
      theme = "Everforest Dark Hard";
      # wezterm defaults: JetBrains Mono, 12pt
      font-family = "JetBrains Mono";
      font-size = 12;
      # wezterm: window_decorations = "NONE"
      window-decoration = "none";
      gtk-titlebar = false;
      # wezterm: retro tab bar, shown even with one tab (hide_tab_bar_if_only_one_tab is commented out).
      # Narrow flat tabs, restyled by the CSS below.
      window-show-tab-bar = "always";
      gtk-wide-tabs = false;
      gtk-toolbar-style = "flat";
      gtk-custom-css = "${pkgs.writeText "ghostty-tabs.css" ''

        /* WezTerm retro tab bar look: flat #333 bar, compact monospace tabs, active tab black */
        tabbar, tabbar > revealer > box {
          min-height: 0;
          padding: 0;
          margin: 0;
          background: #333333;
          box-shadow: none;
          border: none;
        }
        tabbar tabbox { padding: 0; margin: 0; }
        tabbar tab {
          min-height: 0;
          min-width: 0;
          padding: 0px 8px;
          margin: 0;
          border-radius: 0;
          background: transparent;
          color: #808080;
          font-family: "JetBrains Mono";
          font-size: 12pt;
        }
        tabbar, tabbar * { border-radius: 0; outline: none; box-shadow: none; }
        tabbar tabbox, tabbar tabboxchild, tabbar .box { padding: 0; margin: 0; }
        /* close button only on hover, like WezTerm */
        tabbar tab:not(:hover) button.tab-close-button { opacity: 0; }
        tabbar tab:selected { background: #000000; color: #c0c0c0; }
        tabbar tab:hover:not(:selected) { background: #3c3c3c; }
        tabbar tab label { margin: 0; padding: 0; }
        tabbar button {
          min-height: 0;
          min-width: 0;
          padding: 0 0px;
          margin: 0;
          border-radius: 0;
          color: #808080;
        }
        tabbar tab button.tab-close-button { padding: 0; margin: 0; }
        tabbar .start-action, tabbar .end-action { padding: 0; margin: 0; }
              
        /* compact: shrink the close/indicator icons that set the tab height */
        tabbar tabbox, tabbar tabboxchild, tabbar tab, tabbar .box, tabbar revealer { min-height: 0; }
        tabbar tab button, tabbar tab image, tabbar tab .tab-close-button, tabbar tab .tab-indicator {
          min-height: 0; min-width: 0; padding: 0; margin: 0; -gtk-icon-size: 10px;
        }
        tabbar tab { padding-top: 0; padding-bottom: 0; }
        /* little side padding around the title */
        tabbar tab { padding: 0 2px; }
        tabbar tab .tab-close-button, tabbar tab .tab-indicator { margin: 0; padding: 0; }
        /* libadwaita gives every tab a fixed ~215 px slot; the margin hides the padding saved above,
           so the tab gets narrower while the title keeps its length */
        tabbar tab { margin-right: 12px; }
      ''}";
      # wezterm: ctrl+shift+<n> jumps to tab n (ghostty's default is alt+<n>), 9 = last tab
      keybind =
        (map (n: "ctrl+shift+digit_${toString n}=goto_tab:${toString n}") [
          1
          2
          3
          4
          5
          6
          7
          8
        ])
        ++ [
          "ctrl+shift+digit_9=last_tab"
        ];
      # wezterm keeps a block cursor; ghostty's shell integration would switch to a bar at the prompt
      shell-integration-features = "no-cursor";
      # wezterm: window_background_opacity = 0.95
      background-opacity = 0.95;
      # wezterm: adjust_window_size_when_changing_font_size = false (ghostty never resizes a tiled window)
      # wezterm: enable_wayland = true (ghostty's GTK app is native wayland)
    };
  };
}
