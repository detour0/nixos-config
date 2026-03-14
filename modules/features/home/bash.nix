{ ... }:
{
  programs.bash = {
  enable = true;
  # Add custom content from another file
  initExtra = builtins.readFile ../../dotfiles/.bashrc;
  };
}