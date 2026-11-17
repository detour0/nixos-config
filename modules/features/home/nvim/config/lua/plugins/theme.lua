return {
	{
		"everforest",
		dev = true,
		lazy = false,
		priority = 1000,
		config = function()
			vim.g.everforest_background = "hard"
			vim.cmd.colorscheme("everforest")
		end,
	},
	-- Alternatives, loaded by `:colorscheme catppuccin-mocha` or `:colorscheme kanagawa`
	-- (plain `catppuccin` is the port that ships with Neovim)
	{ "catppuccin-nvim", dev = true },
	{ "kanagawa.nvim", dev = true },
}
