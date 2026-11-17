local v = vim

-- No comment leader on a new line. Most ftplugins add these flags back, so setting the option once would not stick.
v.api.nvim_create_autocmd("FileType", {
	group = v.api.nvim_create_augroup("no_comment_continuation", { clear = true }),
	callback = function()
		v.opt_local.formatoptions:remove({ "c", "r", "o" })
	end,
})
