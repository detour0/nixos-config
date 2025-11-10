{ pkgsUnstable, ... }:
{
  programs.direnv = {
    enable = true;
    package = pkgsUnstable.direnv;
    enableBashIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
