return {
	"nvim-treesitter-context",
	dev = true,
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		max_lines = 3,
	},
	keys = {
		{
			"[c",
			function()
				require("treesitter-context").go_to_context(vim.v.count1)
			end,
			desc = "Jump up to [C]ontext parent",
		},
	},
}
