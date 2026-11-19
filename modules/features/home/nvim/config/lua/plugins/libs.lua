-- Plugins without a config of their own: other specs name them in `dependencies` or just require() them.
-- lazy.nvim only finds a plugin in the Nix pack through a spec with `dev = true`.
return {
	{ "plenary.nvim", dev = true }, -- yazi.nvim
	{ "nui.nvim", dev = true }, -- navbuddy
	{ "nvim-navic", dev = true }, -- navbuddy
	{ "nvim-web-devicons", dev = true },
	{ "mini.icons", dev = true }, -- which-key's icons
	{ "colorful-menu.nvim", dev = true },
}
