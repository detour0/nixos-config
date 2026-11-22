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
			-- Wide Mermaid diagrams: the CSS lets them use the full window width and scroll (default.nix)
			v.g.mkdp_markdown_css = v.fn.stdpath("config") .. "/markdown-preview.css"
			-- The plugin only fills in its defaults when the variable is unset, so this is the full table
			v.g.mkdp_preview_options = {
				mkit = {},
				katex = {},
				uml = {},
				-- Natural size instead of shrinking to the column width
				maid = { flowchart = { useMaxWidth = false }, sequence = { useMaxWidth = false } },
				disable_sync_scroll = 0,
				sync_scroll_type = "middle",
				hide_yaml_meta = 1,
				sequence_diagrams = {},
				flowchart_diagrams = {},
				content_editable = false,
				disable_filename = 0,
				toc = {},
			}
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
