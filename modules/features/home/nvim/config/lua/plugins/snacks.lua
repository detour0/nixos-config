return {
	"snacks.nvim",
	dev = true,
	lazy = false,
	priority = 1000,
	opts = {
		dashboard = {
			enabled = true,
			sections = {
				{ section = "header" },
				{ icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
				{ icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
				{ icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
				{ section = "startup" },
			},
		},
		notifier = { enabled = true },
	},
	keys = {
		{
			"<leader>fM",
			function()
				Snacks.notifier.show_history()
			end,
			desc = "[F]ind [M]essage",
		},
	},
}
