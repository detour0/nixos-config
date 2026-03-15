return {
	-- which-key helps you remember key bindings by showing a popup
	-- with the active keybindings of the command you started typing.
	{
		"which-key.nvim",
		dev = true,
		event = "UIEnter",
		opts = {
			defaults = {
				mode = { "n", "v" },
			},
			plugins = { spelling = true },
			spec = {
				{ "<leader><leader>", group = "buffer commands" },
				{ "<leader>c", group = "[c]ode" },
				{ "<leader>d", group = "[d]ocument" },
				{ "<leader>g", group = "[g]it" },
				{ "<leader>m", group = "[m]arkdown" },
				{ "<leader>r", group = "[r]ename" },
				{ "<leader>f", group = "[f]ind" },
				{ "<leader>t", group = "[t]oggles" },
				{ "<leader>w", group = "[w]orkspace" },
			},
		},
		config = function(_, opts)
			require("which-key").setup(opts)
		end,
	},
}
