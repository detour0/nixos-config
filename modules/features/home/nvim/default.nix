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

      typescript-language-server
      eslint_d
      prettierd

      rust-analyzer
      gopls

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
        nvim-treesitter-context

        blink-cmp
        blink-compat
        colorful-menu-nvim
        luasnip
        cmp-cmdline

        nvim-lspconfig

        telescope-fzf-native-nvim
        telescope-ui-select-nvim
        telescope-nvim
        plenary-nvim

        nvim-treesitter-textobjects
        # nvim-treesitter.withAllGrammars
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
            jsonc
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
            regex
            toml
            nginx
            bash
            zsh
            sway
            vim
            tmux
            ssh-config
          ]
        ))

        mini-icons
        nvim-web-devicons
      ]
      ++ (with pkgsUnstable.vimPlugins; [
        indent-blankline-nvim
      ]);

    extraLuaConfig = ''
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
