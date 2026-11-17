local v = vim

return {
	"yazi.nvim",
	dev = true,
	-- Has to be loaded before a directory is opened, to take it over from netrw
	event = "VeryLazy",
	dependencies = { "plenary.nvim" },
	keys = {
		{ "<leader>nf", "<Cmd>Yazi<CR>", mode = { "n", "v" }, desc = "[N]avigate yazi at the current [F]ile" },
		{ "<C-e>", "<Cmd>Yazi cwd<CR>", desc = "[E]xplore yazi in nvim's CWD" },
		{ "<leader>nl", "<Cmd>Yazi toggle<CR>", desc = "[N]avigate the [L]ast yazi session" },
	},
	opts = {
		open_for_directories = true,
		keymaps = {
			show_help = "<f1>",
		},
	},
	init = function()
		-- netrw must not load at all: https://github.com/mikavilpas/yazi.nvim/issues/802
		v.g.loaded_netrwPlugin = 1

		-- `nvim <dir>` works in that directory, `nvim <file>` in the file's directory
		local arg = v.fn.argv(0)
		if arg ~= "" then
			local path = v.fn.fnamemodify(arg, ":p")
			if v.fn.isdirectory(path) == 1 then
				v.api.nvim_set_current_dir(path)
			elseif v.fn.filereadable(path) == 1 then
				v.api.nvim_set_current_dir(v.fn.fnamemodify(path, ":h"))
			end
		end
	end,
}
