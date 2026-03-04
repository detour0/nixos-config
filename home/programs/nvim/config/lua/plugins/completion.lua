return {
	-- 1. Snippet Engine
	{
		"luasnip",
		dev = true,
		config = function()
			local ls = require("luasnip")
			require("luasnip.loaders.from_vscode").lazy_load()
			ls.config.setup({})

			vim.keymap.set({ "i", "s" }, "<M-n>", function()
				if ls.choice_active() then
					ls.change_choice(1)
				end
			end)
		end,
	},

	-- 2. Modern UI for the menu
	{ "colorful-menu.nvim", dev = true },

	-- 3. Compatibility layer for old cmp sources (like cmdline)
	{ "blink.compat", dev = true, opts = {} },

	-- 4. The Engine
	{
		"blink.cmp",
		dev = true,
		event = "InsertEnter",
		dependencies = {
			"luasnip",
			"colorful-menu.nvim",
			"blink.compat",
			"cmp-cmdline",
		},
		config = function()
			require("blink.cmp").setup({
				keymap = {
					preset = "default",
					["<CR>"] = { "accept", "fallback" },
					["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
					["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
				},

				appearance = {
					-- Use the colorful-menu highlights
					use_nvim_cmp_as_default = true,
					nerd_font_variant = "mono",
				},

				completion = {
					menu = {
						draw = {
							-- Use colorful-menu for that "Gold Standard" visual polish
							columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
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
					ghost_text = { enabled = true }, -- Shows "inline" suggestion (very modern)
				},

				snippets = { preset = "luasnip" },

				sources = {
					default = { "lsp", "path", "snippets", "buffer" },
					providers = {
						-- Integrating your cmp-cmdline source via blink.compat
						cmdline = {
							name = "cmdline",
							module = "blink.compat.source",
						},
					},
				},

				signature = { enabled = true, window = { border = "rounded" } },
			})
		end,
	},
}
