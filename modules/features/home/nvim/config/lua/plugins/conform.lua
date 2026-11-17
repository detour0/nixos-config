return {
	"conform.nvim",
	dev = true,
	event = "BufWritePre",
	cmd = "ConformInfo",
	keys = {
		{
			"<leader>F",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = { "n", "v" },
			desc = "[F]ormat [F]ile",
		},
	},
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "ruff_organize_imports", "ruff_format" },
			nix = { "nixfmt" },
			go = { "goimports", "gofmt" },
			yaml = { "yamlfmt" },
			sql = { "sqlfluff" },

			-- prettierd: the daemon, for speed
			javascript = { "prettierd" },
			typescript = { "prettierd" },
			css = { "prettierd" },
			html = { "prettierd" },
			json = { "prettierd" },
			markdown = { "prettierd" },
		},
		formatters = {
			yamlfmt = {
				args = { "-formatter", "retain_line_breaks_single=true" },
			},
		},
		-- Switch off with vim.g.disable_autoformat or vim.b.disable_autoformat
		format_on_save = function(bufnr)
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end
			return { timeout_ms = 500, lsp_format = "fallback" }
		end,
	},
}
