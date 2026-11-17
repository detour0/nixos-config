return {
	"trouble.nvim",
	dev = true,
	cmd = "Trouble",
	opts = {},
	keys = {
		{ "<leader>dd", "<Cmd>Trouble diagnostics toggle<CR>", desc = "Project [D]iagnostics (Trouble)" },
		{ "<leader>db", "<Cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "[B]uffer Diagnostics (Trouble)" },
		-- Capital S: <leader>ds is the document symbol picker (plugins/lsp.lua)
		{ "<leader>dS", "<Cmd>Trouble symbols toggle focus=false<CR>", desc = "Code [S]ymbols (Trouble)" },
		{
			"<leader>dl",
			"<Cmd>Trouble lsp toggle focus=false win.position=right<CR>",
			desc = "LSP [L]ist (Definitions/References)",
		},
		{ "<leader>do", "<Cmd>Trouble loclist toggle<CR>", desc = "Location List (Trouble)" },
		{ "<leader>dq", "<Cmd>Trouble qflist toggle<CR>", desc = "Quickfix List (Trouble)" },
	},
}
