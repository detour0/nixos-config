local v = vim

return {
	{
		-- Doesn't work with lua for whatever reason
		"indent-blankline.nvim",
		main = "ibl",
		dev = true,
		-- "BufReadPost" is safer than "BufReadPre" because it ensures
		-- the buffer actually exists and is ready for Tree-sitter.
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			indent = {
				char = "│",
				-- This helps when Treesitter is being lazy
				smart_indent_cap = true,
			},
			exclude = {
				filetypes = { "help", "dashboard", "snacks_dashboard" },
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{
				"nvim-navbuddy",
				dev = true,
				dependencies = {
					{ "nvim-navic", dev = true },
					{ "nui.nvim", dev = true },
				},
			},
		},
		config = function()
			-- This replaces your 'before' block.
			-- On Neovim 0.11+, we can set global defaults like this:
			v.lsp.config("*", {
				-- Ensure this file exists at lua/myLuaConf/LSPs/on_attach.lua
				on_attach = require("plugins/lsp/on_attach"),
			})

			-- Pyright setup
			v.lsp.config("pyright", {
				root_markers = {
					"pyproject.toml",
					"requirements.txt",
					".git",
					"venv",
					".venv",
					"poetry.lock",
					"uv.lock",
				},
				settings = {
					python = {
						formatting = { provider = "none" }, -- Using ruff instead
					},
				},
			})

			v.lsp.config("lua_ls", {
				-- if you provide the filetypes it doesn't ask lspconfig for the filetypes
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						formatters = {
							ignoreComments = true,
						},
						signatureHelp = { enabled = true },
						diagnostics = {
							globals = { "vim" },
							disable = { "missing-fields" },
						},
						telemetry = { enabled = false },
					},
				},
			})

			local lsps = {
				"nixd",
				"lua_ls",
				"pyright",
				"rust_analyzer",
				"gopls",
				"ts_ls", -- modern name for typescript-language-server
				"cssls",
				"html",
				"dockerls",
				"yamlls",
			}

			for _, server in ipairs(lsps) do
				v.lsp.enable(server)
			end
		end,
	},

	-- {
	--   "lazydev.nvim",
	--   dev = true,
	--   ft = "lua",
	--   opts = {
	--     library = {
	--       -- This helps Neovim understand the global 'vim' variable
	--       -- and any other plugins you have installed.
	--       { path = "luvit-meta/library", words = { "vim%.uv" } },
	--     },
	--   },
	-- },
}
