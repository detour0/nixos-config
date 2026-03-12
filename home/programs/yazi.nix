{ ... }:
{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
    theme = {
      flavor = {
        dark = "catppuccin-mocha";
      };
    };
    flavors."catppuccin-mocha" = ../../dotfiles/yazi/flavors/catppuccin-mocha;
    settings = {
      manager = {
        ratio = [
          2
          5
          5
        ];
      };
    };
  };
}
