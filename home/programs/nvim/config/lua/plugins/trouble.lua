return {
	"trouble.nvim",
	dev = true,
	cmd = "Trouble",
	opts = {
		-- Best for modern displays: use icons and fancy formatting
		use_diagnostic_signs = true,
	},
	keys = {
		-- Diagnostics [D]
		{
			"<leader>dd",
			"<cmd>Trouble diagnostics toggle<cr>",
			desc = "Project [D]iagnostics (Trouble)",
		},
		{
			"<leader>db",
			"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
			desc = "[B]uffer Diagnostics (Trouble)",
		},

		-- Symbols & LSP (Code [C] context)
		{
			"<leader>cs",
			"<cmd>Trouble symbols toggle focus=false<cr>",
			desc = "Code [S]ymbols (Trouble)",
		},
		{
			"<leader>cl",
			"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
			desc = "LSP [L]ist (Definitions/References)",
		},

		-- Lists [X] (Kept 'x' for lists as they are "extra" tools)
		{
			"<leader>xl",
			"<cmd>Trouble loclist toggle<cr>",
			desc = "Location List (Trouble)",
		},
		{
			"<leader>xq",
			"<cmd>Trouble qflist toggle<cr>",
			desc = "Quickfix List (Trouble)",
		},
	},
}
