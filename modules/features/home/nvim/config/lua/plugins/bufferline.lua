return {
	{
		"bufferline.nvim",
		dev = true,
		event = "VeryLazy",
		dependencies = { "nvim-web-devicons" },
		keys = {
			{ "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
			{ "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev tab" },
			{ "<leader>x", "<Cmd>bdelete<CR>", desc = "[X] Close Buffer" },
		},
		config = function()
			local bufferline = require("bufferline")

			bufferline.setup({
				options = {
					-- mode = "tabs",
					separator_style = "slant",
					-- Use devicons for file type identification
					show_buffer_icons = true,
					show_buffer_close_icons = true,
					show_close_icon = false,
					-- Only show the bar if you have more than one buffer open | false
					always_show_bufferline = true,
					-- Diagnostics integration (Gold Standard)
					diagnostics = "nvim_lsp",
					offsets = {
						{
							filetype = "NvimTree",
							text = "File Explorer",
							text_align = "left",
							separator = true,
						},
					},
				},
			})
		end,
	},
}
