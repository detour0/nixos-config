return {
	"bufferline.nvim",
	dev = true,
	event = "VeryLazy",
	dependencies = { "nvim-web-devicons" },
	keys = {
		{ "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
		{ "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev tab" },
		{ "<leader>x", "<Cmd>bdelete<CR>", desc = "[X] Close Buffer" },
		{ "<leader>X", "<Cmd>BufferLineCloseOthers<CR>", desc = "[X] Close all other buffers" },
	},
	opts = {
		options = {
			max_prefix_length = 6,
			diagnostics = "nvim_lsp",
		},
	},
}
