return {
	"lualine.nvim",
	dev = true,
	event = "VeryLazy",
	dependencies = { "nvim-web-devicons" },
	opts = {
		options = {
			component_separators = { left = "", right = "" },
			section_separators = { left = "", right = "" },
		},
		sections = {
			lualine_c = {
				{
					"filename",
					path = 1, -- relative to the cwd
					symbols = { modified = " ●", readonly = " 󰈡", unnamed = "[No Name]" },
				},
			},
		},
	},
}
