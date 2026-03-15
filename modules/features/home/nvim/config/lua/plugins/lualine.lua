return {
	{
		"lualine.nvim",
		dev = true,
		event = "VeryLazy", -- Replaces DeferredUIEnter
		dependencies = { "nvim-web-devicons", dev = true },
		config = function()
			require("lualine").setup({
				options = {
					theme = "auto", -- Automatically detects Catppuccin
					icons_enabled = true,
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
					disabled_filetypes = { "alpha", "dashboard", "NvimTree" },
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					-- OPTION 1: Path inside lualine
					lualine_c = {
						{
							"filename",
							path = 1, -- 0: Name, 1: Relative, 2: Absolute, 3: Absolute with ~
							symbols = { modified = " ●", readonly = " 󰈡", unnamed = "[No Name]" },
						},
					},
					lualine_x = { "encoding", "fileformat", "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			})

			-- OPTION 2: The Winbar (Thin line at the top of the buffer)
			-- This shows the relative path and the "modified" circle icon
			-- You can add this directly to your lualine config file or your opts.lua
			-- vim.opt.winbar = "%#WinBar# %f %m"
		end,
	},
}
