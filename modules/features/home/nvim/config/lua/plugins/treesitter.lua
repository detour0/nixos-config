local v = vim

-- Keymaps for nvim-treesitter-textobjects, which defines none itself
local function textobject_keys()
	local keys = {}
	local function add(module, fn, modes, maps)
		for lhs, query in pairs(maps) do
			keys[#keys + 1] = {
				lhs,
				function()
					require("nvim-treesitter-textobjects." .. module)[fn](query, "textobjects")
				end,
				mode = modes,
				desc = fn:gsub("_", " ") .. " " .. query,
			}
		end
	end

	add("select", "select_textobject", { "x", "o" }, {
		["aa"] = "@parameter.outer",
		["ia"] = "@parameter.inner",
		["af"] = "@function.outer",
		["if"] = "@function.inner",
		["ac"] = "@class.outer",
		["ic"] = "@class.inner",
	})

	local nxo = { "n", "x", "o" }
	add("move", "goto_next_start", nxo, { ["]m"] = "@function.outer", ["]]"] = "@class.outer" })
	add("move", "goto_next_end", nxo, { ["]M"] = "@function.outer", ["]["] = "@class.outer" })
	add("move", "goto_previous_start", nxo, { ["[m"] = "@function.outer", ["[["] = "@class.outer" })
	add("move", "goto_previous_end", nxo, { ["[M"] = "@function.outer", ["[]"] = "@class.outer" })

	add("swap", "swap_next", "n", { ["<leader>a"] = "@parameter.inner" })
	add("swap", "swap_previous", "n", { ["<leader>A"] = "@parameter.inner" })
	return keys
end

return {
	{
		-- Highlighting is Neovim's own and only has to be started. Nix installs the parsers and queries for
		-- every language (default.nix); this plugin adds the filetype aliases and query predicates they need.
		"nvim-treesitter",
		dev = true,
		lazy = false,
		config = function()
			v.api.nvim_create_autocmd("FileType", {
				group = v.api.nvim_create_augroup("treesitter_start", { clear = true }),
				callback = function(args)
					-- Files over 1 MB keep regex highlighting
					local stat = v.uv.fs_stat(v.api.nvim_buf_get_name(args.buf))
					if stat and stat.size > 1024 * 1024 then
						pcall(v.treesitter.stop, args.buf)
					else
						-- Fails for filetypes without a parser, which keep regex highlighting too
						pcall(v.treesitter.start, args.buf)
					end
				end,
			})
		end,
	},
	{
		"nvim-treesitter-textobjects",
		dev = true,
		opts = {
			select = { lookahead = true },
			move = { set_jumps = true },
		},
		keys = textobject_keys,
	},
	{
		"nvim-treesitter-context",
		dev = true,
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			max_lines = 3,
		},
		keys = {
			{
				"[c",
				function()
					require("treesitter-context").go_to_context(v.v.count1)
				end,
				desc = "Jump up to [C]ontext parent",
			},
		},
	},
}
