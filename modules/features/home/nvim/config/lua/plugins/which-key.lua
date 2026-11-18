return {
	"which-key.nvim",
	dev = true,
	event = "VeryLazy",
	opts = {
		spec = {
			{ "<leader><leader>", group = "buffer commands" },
			{ "<leader>d", group = "[d]iagnostics" },
			{ "<leader>f", group = "[f]ind" },
			{ "<leader>g", group = "[g]it" },
			{ "<leader>l", group = "[l]sp" },
			{ "<leader>n", group = "[n]avigate" },
			{ "<leader>w", group = "[w]orkspace" },
		},
	},
}
