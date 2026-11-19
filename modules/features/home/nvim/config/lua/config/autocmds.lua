local v = vim

-- No comment leader on a new line. Most ftplugins add these flags back, so setting the option once would not stick.
v.api.nvim_create_autocmd("FileType", {
	group = v.api.nvim_create_augroup("no_comment_continuation", { clear = true }),
	callback = function()
		v.opt_local.formatoptions:remove({ "c", "r", "o" })
	end,
})

-- Markdown: each heading's section is a fold (Neovim's own ftplugin, which also shows the hidden line count)
v.g.markdown_folding = 1

v.api.nvim_create_autocmd("FileType", {
	group = v.api.nvim_create_augroup("markdown_buffer", { clear = true }),
	pattern = "markdown",
	callback = function()
		-- Prose wraps at word boundaries, not in the middle of a word
		v.opt_local.linebreak = true
		-- Files open unfolded: zc / zM close sections
		v.opt_local.foldlevel = 99
	end,
})
