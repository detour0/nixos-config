{ config, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";

    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    history = {
      append = true;
      expireDuplicatesFirst = true;
      findNoDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      path = "$HOME/.config/zsh/.zsh_history";
      saveNoDups = true;
      share = true;
      save = 10000;
      size = 10000;
    };

    historySubstringSearch = {
      enable = true;
      # searchDownKey = "";
      # searchUpKey = "";
    };

    shellAliases = {
      cw = "cd ~/workspace";
      cdc = "cd ~/mega/coding";
      nn = "nvim $HOME/workspace/nixos-config";
    };

    completionInit = ''
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' menu no
    '';

    initContent = ''
      setopt AUTO_CD

      # eza as a drop-in replacement for ls
      # Something is implicitly generating an ls alias
      unalias ls 2>/dev/null
      ls() {
        eza --icons=auto --color=auto "$@"
      }

      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --icons=always --color=always $realpath'
      zstyle ':fzf-tab:complete:cd:*' fzf-flags --preview-window=right:50%
      zstyle ':fzf-tab:complete:*:*' fzf-preview '[[ -d "$realpath" ]] && eza --icons=auto --color=always "$realpath"'
      # Something overwrites completions with normal fzf
      # bindkey '^I' fzf-tab-complete

      # Ctrl+T: file and directory selection
      export FZF_CTRL_T_OPTS="
        --walker file,dir,follow
        --walker-skip .git,.cache,.local/share/Trash,node_modules,target,dist,.venv,__pycache__
      "

      # Alt+C: directory navigation
      export FZF_ALT_C_OPTS="
        --walker dir,follow
        --walker-skip .git,.cache,.local/share/Trash,node_modules,target,dist,.venv,__pycache__
      "

      # Keybindings
      bindkey "^p" history-search-backward
      bindkey "^n" history-search-forward
    '';

    plugins = [
      {
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
    ];

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "npm"
        "history"
        "python"
        "node"
        "rust"
      ];
    };
  };
}
