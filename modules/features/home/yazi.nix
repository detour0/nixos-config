_: {
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
    theme = {
      flavor = {
        dark = "everforest-medium";
      };
    };
    # flavors."catppuccin-mocha" = ../../../dotfiles/yazi/flavors/catppuccin-mocha;
    flavors."everforest-medium" = ../../../dotfiles/yazi/flavors/everforest-medium;
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
