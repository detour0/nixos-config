local v = vim

return {
	{
		"nvim-treesitter",
		dev = true,
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			-- Replicating your 1MB filesize limit natively
			v.api.nvim_create_autocmd("FileType", {
				group = v.api.nvim_create_augroup("treesitter_large_file_disable", { clear = true }),
				callback = function(args)
					local max_filesize = 1024 * 1024 -- 1 MB
					local ok, stats = pcall(v.loop.fs_stat, v.api.nvim_buf_get_name(args.buf))
					if ok and stats and stats.size > max_filesize then
						-- Tell Neovim's native Treesitter client to abort parsing
						pcall(v.treesitter.stop, args.buf)
						-- Fallback to standard regex syntax highlighting
						v.cmd("syntax on")
					end
				end,
			})
		end,
	},

	-- --------------------------------------------------------
	-- TEXTOBJECTS (Standalone Setup)
	-- --------------------------------------------------------
	{
		"nvim-treesitter-textobjects",
		dev = true,
		dependencies = { "nvim-treesitter" },
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["aa"] = "@parameter.outer",
						["ia"] = "@parameter.inner",
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						["ic"] = "@class.inner",
					},
				},
				move = {
					enable = true,
					set_jumps = true,
					goto_next_start = { ["]m"] = "@function.outer", ["]]"] = "@class.outer" },
					goto_next_end = { ["]M"] = "@function.outer", ["]["] = "@class.outer" },
					goto_previous_start = { ["[m"] = "@function.outer", ["[["] = "@class.outer" },
					goto_previous_end = { ["[M"] = "@function.outer", ["[]"] = "@class.outer" },
				},
				swap = {
					enable = true,
					swap_next = { ["<leader>a"] = "@parameter.inner" },
					swap_previous = { ["<leader>A"] = "@parameter.inner" },
				},
			})
		end,
	},
}
