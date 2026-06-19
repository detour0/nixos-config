# https://nixalted.com/lazynvim-nixos.html

{
  pkgs,
  config,
  pkgsUnstable,
  ...
}:
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

    # Default changed 25.11 to 26.05
    withPython3 = false;
    withRuby = false;

    extraPackages = with pkgs; [
      ripgrep
      fd
      gcc

      lua-language-server
      stylua
      luajitPackages.luacheck

      pyright
      ruff

      nixd
      statix
      nix
      nixfmt

      typescript-language-server
      eslint_d
      prettierd

      rust-analyzer
      gopls
      go
      gotools

      vscode-langservers-extracted
      stylelint

      tailwindcss-language-server
      yamlfmt
      dockerfile-language-server
      hadolint
      sqlfluff

    ];

    plugins =
      with pkgs.vimPlugins;
      [
        catppuccin-nvim
        kanagawa-nvim
        lualine-nvim
        bufferline-nvim
        snacks-nvim
        yazi-nvim

        lazy-nvim
        which-key-nvim
        conform-nvim

        nvim-lint
        nvim-navic
        nui-nvim
        nvim-navbuddy
        trouble-nvim

        blink-compat
        colorful-menu-nvim
        luasnip
        cmp-cmdline

        nvim-lspconfig

        telescope-fzf-native-nvim
        telescope-ui-select-nvim
        telescope-nvim
        plenary-nvim

        nvim-treesitter-context
        nvim-treesitter-textobjects

        nvim-treesitter # got archived with neovim v0.12
        nvim-treesitter.withAllGrammars
        # This is for if you only want some of the grammars
        (nvim-treesitter.withPlugins (
          plugins: with plugins; [
            c
            python
            nix
            lua
            rust
            javascript
            typescript
            go
            sql
            query
            html
            http
            css
            xml
            markdown
            markdown_inline
            yaml
            json
            jq
            kcl
            kconfig
            helm
            angular
            graphql
            arduino
            dockerfile
            csv
            gitignore
            gpg
            toml
            nginx
            bash
            zsh
            sway
            vim
            tmux
            ssh-config
            latex
          ]
        ))

        mini-icons
        nvim-web-devicons
      ]
      ++ (with pkgsUnstable.vimPlugins; [
        indent-blankline-nvim
        blink-cmp
      ]);

    initLua = ''
      require("config.opts")
      require("config.keys")
      require("lazy").setup({
          rocks = { enabled = false },
          pkg = { enabled = false },
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
