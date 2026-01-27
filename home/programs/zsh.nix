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
      ls = "ls --color";
      cw = "cd ~/workspace";
      cdc = "cd ~/mega/coding";
      nn = "nvim $HOME/workspace/nixos-config";
    };

    completionInit = ''
      zstyle ':comletion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' menu no
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color=always $realpath'
    '';
    
    initContent = ''
      setopt AUTO_CD

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
         "deno"
      ];
    };
  };
}
