local v = vim

return {
	"yazi.nvim",
	event = "VeryLazy",
	dev = true,
	dependencies = {
		{ "plenary.nvim", lazy = true, dev = true },
	},
	keys = {
		-- 👇 in this section, choose your own keymappings!
		{
			"<leader>nf",
			mode = { "n", "v" },
			"<cmd>Yazi<cr>",
			desc = "[N]avigate yazi at the current [F]ile",
		},
		{
			-- Open in the current working directory
			"C-e",
			"<cmd>Yazi cwd<cr>",
			desc = "[N]avigate yazi in nvim's [C]WD",
		},
		{
			"<leader>nl",
			"<cmd>Yazi toggle<cr>",
			desc = "[N]avigate the [L]ast yazi session",
		},
	},
	opts = {
		-- if you want to open yazi instead of netrw, see below for more info
		open_for_directories = true,
		keymaps = {
			show_help = "<f1>",
		},
	},
	-- 👇 if you use `open_for_directories=true`, this is recommended
	init = function()
		-- mark netrw as loaded so it's not loaded at all.
		--
		-- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
		v.g.loaded_netrwPlugin = 1

		-- Get the start argument
		local arg = v.fn.argv(0)
		if arg and arg ~= "" then
			-- Convert to absolute path
			local path = v.fn.fnamemodify(arg, ":p")

			-- If it's a directory, force the CWD immediately
			if v.fn.isdirectory(path) == 1 then
				v.api.nvim_set_current_dir(path)
			-- If it's a file, set CWD to that file's parent folder
			elseif v.fn.filereadable(path) == 1 then
				v.api.nvim_set_current_dir(v.fn.fnamemodify(path, ":h"))
			end
		end
	end,
}
