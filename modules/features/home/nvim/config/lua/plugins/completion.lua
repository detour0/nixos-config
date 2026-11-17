return {
	"blink.cmp",
	dev = true,
	-- Right after the first draw: ready before the first keystroke without costing startup time
	event = "VeryLazy",
	dependencies = { "colorful-menu.nvim" },
	opts = {
		keymap = {
			preset = "default",
			["<CR>"] = { "accept", "fallback" },
			["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
			["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
		},
		completion = {
			menu = {
				draw = {
					columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
					-- Labels highlighted by treesitter
					components = {
						label = {
							text = function(ctx)
								return require("colorful-menu").blink_components_text(ctx)
							end,
							highlight = function(ctx)
								return require("colorful-menu").blink_components_highlight(ctx)
							end,
						},
					},
				},
			},
			documentation = { auto_show = true, window = { border = "rounded" } },
			ghost_text = { enabled = true },
		},
		signature = { enabled = true, window = { border = "rounded" } },
	},
}
