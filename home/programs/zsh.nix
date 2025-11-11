{ pkgs, ... }:
{
  home.shell.enableZshIntegration = true;
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";

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
      size = 100000; 
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
    
    initContent = ''
      setopt AUTO_CD
    '';

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
