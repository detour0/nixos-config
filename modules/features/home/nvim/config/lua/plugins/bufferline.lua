return {
	"bufferline.nvim",
	dev = true,
	event = "VeryLazy",
	dependencies = { "nvim-web-devicons" },
	keys = {
		{ "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
		{ "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev tab" },
		{ "<leader>x", "<Cmd>bdelete<CR>", desc = "[X] Close Buffer" },
	},
	opts = {
		options = {
			max_prefix_length = 6,
			diagnostics = "nvim_lsp",
		},
	},
}
