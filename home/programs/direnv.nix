{ pkgsUnstable, ... }:
{
  programs.direnv = {
    enable = true;
    package = pkgsUnstable.direnv;
  };
}