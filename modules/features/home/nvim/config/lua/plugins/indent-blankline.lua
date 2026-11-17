return {
	"indent-blankline.nvim",
	dev = true,
	main = "ibl",
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		indent = {
			char = "│",
			-- Defaults to the tab of 'listchars', which is blank here
			tab_char = "│",
		},
		exclude = {
			filetypes = { "help", "snacks_dashboard" },
		},
	},
}
