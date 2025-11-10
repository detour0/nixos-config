{ pkgs, ... }:
{
users.defaultUserShell = pkgs.zsh;
programs = {
   zsh = {
      enable = true;
      enableCompletion = true;
      enableBashCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      histSize = 10000;
      histFile = "$HOME/.zsh_history";

      promptInit = ''
        eval "$(starship init zsh)"
      '';
      shellAliases = {
        cw = "cd ~/workspace";
        cdc = "cd ~/mega/coding";
      };

      ohMyZsh = {
         enable = true;
         plugins = [
           "zsh-autosuggestions"
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
  };
}
