# Nix installs every plugin and tool, lazy.nvim only loads the plugins (https://nixalted.com/lazynvim-nixos.html)
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # The plugins below as home-manager packs them: one directory per plugin
  pack = "${config.xdg.dataFile."nvim/site/pack/hm".source}/start";
in
{
  programs.neovim = {
    enable = true;
    vimAlias = true;
    vimdiffAlias = true;

    # No remote plugins, so no provider hosts
    withPython3 = false;
    withRuby = false;

    # On nvim's PATH only. A language is wired up in config/lua/plugins/{lsp,conform,lint}.lua.
    extraPackages = with pkgs; [
      # telescope
      ripgrep
      fd

      # lua
      lua-language-server
      stylua
      luajitPackages.luacheck

      # nix
      nixd
      nixfmt
      statix

      # python
      pyright
      ruff

      # javascript, typescript, html, css, json, markdown
      typescript-language-server
      vscode-langservers-extracted
      eslint_d
      prettierd
      htmlhint

      # go
      gopls
      go
      gotools

      # rust
      rust-analyzer

      # yaml, docker, sql
      yaml-language-server
      yamlfmt
      dockerfile-language-server
      hadolint
      sqlfluff
    ];

    # Each plugin needs a spec with `dev = true` in config/lua/plugins, named after its directory in the pack
    plugins = with pkgs.vimPlugins; [
      lazy-nvim

      # look
      everforest
      catppuccin-nvim
      kanagawa-nvim
      lualine-nvim
      bufferline-nvim
      nvim-web-devicons
      mini-icons
      indent-blankline-nvim
      snacks-nvim
      which-key-nvim

      # navigation
      telescope-nvim
      telescope-fzf-native-nvim
      telescope-ui-select-nvim
      plenary-nvim
      yazi-nvim
      trouble-nvim
      nvim-navbuddy
      diffview-nvim
      nvim-navic
      nui-nvim

      # code
      nvim-lspconfig
      conform-nvim
      nvim-lint
      blink-cmp
      colorful-menu-nvim

      # Parsers and queries for every language, merged into one directory (nvim-treesitter-grammars)
      nvim-treesitter.withAllGrammars
      nvim-treesitter-textobjects
      nvim-treesitter-context
    ];

    initLua = ''
      vim.loader.enable()
      require("config.opts")
      require("config.keys")
      require("config.autocmds")

      local pack = "${pack}"
      vim.opt.rtp:prepend(pack .. "/lazy.nvim")
      require("lazy").setup({
        spec = { import = "plugins" },
        -- Plugins come from the Nix pack and nowhere else: nothing is downloaded, built or updated
        dev = { path = pack },
        install = { missing = false },
        pkg = { enabled = false },
        rocks = { enabled = false },
        readme = { enabled = false },
        change_detection = { enabled = false },
        -- A spec loads on its event, cmd, keys or ft, on require(), or with lazy = false
        defaults = { lazy = true },
        performance = {
          rtp = {
            -- Not a plugin, only parser/ and queries/
            paths = { pack .. "/nvim-treesitter-grammars" },
          },
        },
      })
    '';
  };

  # lazy.nvim reads the pack from the store, so Neovim must not find a second copy on its packpath
  xdg.dataFile."nvim/site/pack/hm".enable = lib.mkForce false;

  xdg.configFile."nvim/lua" = {
    recursive = true;
    source = ./config/lua;
  };
}
