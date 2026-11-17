-- Plugins without a config of their own: other specs name them in `dependencies` or just require() them.
-- lazy.nvim only finds a plugin in the Nix pack through a spec with `dev = true`.
return {
	{ "plenary.nvim", dev = true },
	{ "nui.nvim", dev = true },
	{ "nvim-navic", dev = true },
	{ "nvim-web-devicons", dev = true },
	{ "mini.icons", dev = true }, -- which-key's icons
	{ "colorful-menu.nvim", dev = true },
	{ "telescope-fzf-native.nvim", dev = true },
	{ "telescope-ui-select.nvim", dev = true },
}
