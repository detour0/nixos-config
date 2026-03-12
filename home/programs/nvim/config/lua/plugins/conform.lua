return {
	{
		-- "conform-nvim",
		"conform.nvim",
		-- dev = true, -- Crucial for NixOS
		event = { "BufWritePre" }, -- Load on save to trigger format_on_save
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>F",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				mode = { "n", "v" },
				desc = "[F]ormat [F]ile",
			},
		},
		config = function()
			local conform = require("conform")

			conform.setup({
				formatters_by_ft = {
					-- 1. Lua: stylua is the standard
					lua = { "stylua" },

					-- 2. Python: Using the Gold Standard (Ruff)
					-- We run organize_imports then format
					python = { "ruff_organize_imports", "ruff_format" },

					-- 3. Web Development: Using the "daemon" version for speed
					javascript = { "prettierd" },
					typescript = { "prettierd" },
					css = { "prettierd" },
					html = { "prettierd" },
					json = { "prettierd" },
					markdown = { "prettierd" },

					-- 4. Nix
					nix = { "nixfmt" },

					-- 5. Others
					yaml = { "yamlfmt" },
					sql = { "sqlfluff" },
					go = { "goimports", "gofmt" },
				},

				-- Setup format_on_save
				format_on_save = function(bufnr)
					-- Disable with a global or buffer-local variable
					if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
						return
					end
					return { timeout_ms = 500, lsp_fallback = true }
				end,
				-- Custom formatter configurations
				formatters = {
					yamlfmt = {
						args = { "-formatter", "retain_line_breaks_single=true" },
					},
					-- If sqlfluff is too slow, you can tweak it here
					-- sqlfluff = {
					--   args = { "format", "--dialect", "ansi", "-" },
					-- },
				},
			})
		end,
	},
}
