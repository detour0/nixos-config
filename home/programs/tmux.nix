{ pkgs, ... }:
{
  home.packages = [ pkgs.xsel ]; # yank dependency
  programs = {
    tmux = {
      enable = true;
      mouse = true;
      # For whatever reason Plugins need to be installed with <Prefix + i>
      plugins = with pkgs.tmuxPlugins; [
        sensible
        vim-tmux-navigator
        catppuccin
        yank
      ];

      extraConfig = ''
        # Set prefix
        unbind C-b
        set -g prefix C-Space
        bind C-Space send-prefix

        # Shift Alt vim Keys to switch windows
        bind -n M-H previous-window
        bind -n M-L next-window

        # Start windows and panes at 1, not 0
        set -g base-index 1
        set -g pane-base-index 1
        set-window-option -g pane-base-index 1
        set-option -g renumber-windows on

        # set vi-mode
        set-window-option -g mode-keys vi
        # keybindings for copying
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

        # Split pane in cwd
        bind '"' split-window -v -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"

        set -g @catppuccin_flavour 'macchiato'
      '';
    };
  };
}
