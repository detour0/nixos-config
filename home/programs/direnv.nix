{ pkgsUnstable, ... }:
{
  programs.direnv = {
    enable = true;
    package = pkgsUnstable.direnv;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };
}
