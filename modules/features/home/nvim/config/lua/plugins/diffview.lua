local v = vim

-- Open the diff of the working tree, or close it when one is already open in this tab
local function toggle()
	if require("diffview.lib").get_current_view() then
		v.cmd.DiffviewClose()
	else
		v.cmd.DiffviewOpen()
	end
end

-- Inside a diff view: <Tab>/<S-Tab> next/previous file, - stage/unstage the file under the cursor,
-- S stage all, U unstage all, X restore the file, g? all mappings.
return {
	"diffview.nvim",
	dev = true,
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles", "DiffviewRefresh" },
	opts = {
		enhanced_diff_hl = true,
	},
	keys = {
		{ "<leader>gd", toggle, desc = "[D]iff working tree (toggle)" },
		{ "<leader>gs", "<Cmd>DiffviewOpen --staged<CR>", desc = "Diff [S]taged changes" },
		{ "<leader>gl", "<Cmd>DiffviewOpen HEAD~1<CR>", desc = "Diff including the [L]ast commit" },
		{ "<leader>gh", "<Cmd>DiffviewFileHistory %<CR>", desc = "File [H]istory" },
		{ "<leader>gH", "<Cmd>DiffviewFileHistory<CR>", desc = "Repository [H]istory" },
		{ "<leader>gh", ":DiffviewFileHistory<CR>", mode = "x", desc = "[H]istory of the selected lines" },
		{ "<leader>gf", "<Cmd>DiffviewToggleFiles<CR>", desc = "Toggle the [F]ile panel" },
		{ "<leader>gq", "<Cmd>DiffviewClose<CR>", desc = "[Q]uit the diff view" },
	},
}
