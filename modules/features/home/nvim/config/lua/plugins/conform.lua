local function autoformat(bufnr)
	return not (vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat)
end

-- Filetypes whose formatters take longer than a save should wait: prettierd and markdownlint-cli2
-- (and markdown-toc) together need about a second on markdown
local after_save = { markdown = true }

return {
	"conform.nvim",
	dev = true,
	event = "BufWritePre",
	cmd = "ConformInfo",
	keys = {
		{
			"<leader>F",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = { "n", "v" },
			desc = "[F]ormat [F]ile",
		},
	},
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "ruff_organize_imports", "ruff_format" },
			nix = { "nixfmt" },
			go = { "goimports", "gofmt" },
			yaml = { "yamlfmt" },
			sql = { "sqlfluff" },

			-- prettierd: the daemon, for speed
			javascript = { "prettierd" },
			typescript = { "prettierd" },
			css = { "prettierd" },
			html = { "prettierd" },
			json = { "prettierd" },
			-- markdownlint-cli2 fixes what prettier leaves, only when the linter reports something;
			-- markdown-toc fills in a table of contents below a <!-- toc --> line
			markdown = { "prettierd", "markdownlint-cli2", "markdown-toc" },
		},
		formatters = {
			["markdown-toc"] = {
				condition = function(_, ctx)
					for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
						if line:find("<!%-%-%s*toc%s*%-%->") then
							return true
						end
					end
					return false
				end,
			},
			["markdownlint-cli2"] = {
				prepend_args = function()
					return { "--config", vim.fn.stdpath("config") .. "/.markdownlint-cli2.jsonc" }
				end,
				condition = function(_, ctx)
					local found = vim.tbl_filter(function(d)
						return d.source == "markdownlint"
					end, vim.diagnostic.get(ctx.buf))
					return #found > 0
				end,
			},
			yamlfmt = {
				args = { "-formatter", "retain_line_breaks_single=true" },
			},
		},
		-- Switch off with vim.g.disable_autoformat or vim.b.disable_autoformat
		format_on_save = function(bufnr)
			if autoformat(bufnr) and not after_save[vim.bo[bufnr].filetype] then
				return { timeout_ms = 500, lsp_format = "fallback" }
			end
		end,
		-- Formatted in the background after the write, then saved again
		format_after_save = function(bufnr)
			if autoformat(bufnr) and after_save[vim.bo[bufnr].filetype] then
				return { lsp_format = "fallback" }
			end
		end,
	},
}
