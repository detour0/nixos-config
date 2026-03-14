return {
  {
    "nvim-lint",
    dev = true, -- Points to your Nix-managed plugins directory
    event = { "BufReadPre", "BufNewFile" }, -- Lazy load when a file is opened
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        docker = { "hadolint" },
        html = { "htmlhint" },
        lua = { "luacheck" },
        nix = { "statix" },
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        python = { "ruff" },
        sql = { "sqlfluff" },
      }

      -- Create an autocmd to trigger linting automatically
      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })

      -- Manual trigger keybind
      vim.keymap.set("n", "<leader>L", function()
        lint.try_lint()
      end, { desc = "[L]int current file" })
    end,
  },
}
