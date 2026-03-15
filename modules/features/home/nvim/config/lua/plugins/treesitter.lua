local v = vim

return {
	{
		"nvim-treesitter",
		dev = true,
		-- We load on BufReadPost instead of DeferredUIEnter for faster startup
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			{ "nvim-treesitter-textobjects", dev = true },
		},
		config = function()
			require("nvim-treesitter.configs").setup({
				-- IMPORTANT for Nix: Disable automatic installation
				auto_install = false,
				ensure_installed = {}, -- Nix handles this, keep empty!

				highlight = {
					enable = true,
					-- Optional: disable for very large files to maintain performance
					disable = function(lang, buf)
						local max_filesize = 300 * 1024 -- 300 KB
						local ok, stats = pcall(v.loop.fs_stat, v.api.nvim_buf_get_name(buf))
						if ok and stats and stats.size > max_filesize then
							return true
						end
					end,
				},

				-- Indent is still "experimental" but works well for many languages
				indent = { enable = true },

				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<c-space>",
						node_incremental = "<c-space>",
						scope_incremental = "<c-s>",
						node_decremental = "<M-space>",
					},
				},

				textobjects = {
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
				},
			})
		end,
	},
	-- Ensure the textobjects plugin is also recognized as a Nix-dev plugin
	{ "nvim-treesitter-textobjects", dev = true },
}
