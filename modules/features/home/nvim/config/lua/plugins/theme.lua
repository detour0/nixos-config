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
	require("kanagawa").load("wave"),
	{
		"kanagawa-nvim",
		dev = true,
		lazy = false,
		priority = 1000,
		config = function()
			require("kanagawa").load("dragon")
		end,
	},
}
