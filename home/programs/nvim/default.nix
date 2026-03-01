# https://nixalted.com/lazynvim-nixos.html

{ pkgs, lib, config, ... }:
{
  home.sessionVariables = {
  EDITOR = "nvim";
  };

  programs.neovim = {
    enable = true;
    # package = pkgs.neovim;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;

    plugins = with pkgs.vimPlugins; [
      lazy-nvim
      which-key-nvim
    ];

    extraLuaConfig = ''
      vim.g.mapleader = " " -- Need to set leader before lazy for correct keybindings
      require("lazy").setup({
        performance = {
          reset_packpath = false,
          rtp = {
              reset = false,
            }
          },
        dev = {
          path = "${pkgs.vimUtils.packDir config.programs.neovim.finalPackage.passthru.packpathDirs}/pack/myNeovimPackages/start",
        },
        install = {
          -- Safeguard in case we forget to install a plugin with Nix
          missing = false,
        },
        spec = {
          { import = "plugins" },
        },
      })
    '';
  };

  xdg.configFile."nvim/lua" = {
    recursive = true;
    source = ./config/lua;
  };
}
