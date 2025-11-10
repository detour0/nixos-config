{ pkgs, ... }:
{
users.defaultUserShell = pkgs.zsh;
environment.shells = pkgs.zsh;
programs = {
   zsh = {
      enable = true;
      autosuggestions.enable = true;
      enableCompletion = true;
      enableBashCompletion = true;

      syntaxHighlighting.enable = true;
      histSize = 10000;
      histFile = "$HOME/.zsh_history";
      # promptInit = ''
      #   eval "$(starship init zsh)"
      # ''
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
