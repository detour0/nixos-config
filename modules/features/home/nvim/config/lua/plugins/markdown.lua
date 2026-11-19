local v = vim

return {
	{
		-- Renders markdown in the buffer: headings, tables, lists, code blocks, links reduced to their text.
		-- The line under the cursor shows the raw text.
		"render-markdown.nvim",
		dev = true,
		ft = "markdown",
		opts = {},
		keys = {
			{ "<leader>mr", "<Cmd>RenderMarkdown toggle<CR>", ft = "markdown", desc = "Toggle [R]endering" },
		},
	},
	{
		-- Live preview in the browser
		"markdown-preview.nvim",
		dev = true,
		cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
		init = function()
			v.g.mkdp_filetypes = { "markdown" }
		end,
		config = function()
			-- Its commands are buffer-local and set on FileType, which has already passed for this buffer
			v.cmd.doautocmd("FileType")
		end,
		keys = {
			{ "<leader>mp", "<Cmd>MarkdownPreviewToggle<CR>", ft = "markdown", desc = "Toggle browser [P]review" },
		},
	},
}
