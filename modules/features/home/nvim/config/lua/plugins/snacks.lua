return {
	{
		"snacks.nvim",
		priority = 1000,
		lazy = false,
		dev = true,
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
			-- Bonus: Bigtext, Scratchpad, etc. can be enabled here too
			notifier = { enabled = true },
		},
	},
}
