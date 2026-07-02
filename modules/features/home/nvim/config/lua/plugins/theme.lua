return {
	--    {
	--    "catppuccin-nvim", -- needs to match name in packDir
	--    dev = true, -- needs to be explicitly set (presumeably when lazy = false)
	--    lazy = false,
	--    priority = 1000,
	--    config = function()
	-- require("catppuccin").setup({
	-- 	flavour = "mocha"
	-- })
	--        vim.cmd("colorscheme catppuccin")
	--    end,
	--    },
	-- require("everforest").load("hard"),
	{
		"everforest",
		dev = true,
		lazy = false,
		priority = 1000,
		config = function()
			-- Set your configuration options before loading the colorscheme
			vim.g.everforest_background = "hard"

			-- Load the colorscheme natively via Vim's runtime path
			vim.cmd([[colorscheme everforest]])
		end,
	},
}
