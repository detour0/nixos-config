local v = vim

-- Servers to run. Each needs its binary in extraPackages (default.nix); nvim-lspconfig knows how to start it.
local servers = {
	"nixd",
	"lua_ls",
	"pyright",
	"gopls",
	"ts_ls",
	"cssls",
	"html",
	"dockerls",
	"yamlls",
	"markdown_oxide",
}

-- Buffer-local keymaps, on top of Neovim's defaults (grn rename, gra code action, grr references,
-- gri implementation, grt type definition, gO document symbols, K hover)
local function on_attach(args)
	local function map(lhs, rhs, desc)
		v.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = "LSP: " .. desc })
	end

	map("gd", v.lsp.buf.definition, "[G]oto [D]efinition")
	map("gD", v.lsp.buf.declaration, "[G]oto [D]eclaration")
	map("<leader>D", v.lsp.buf.type_definition, "Type [D]efinition")
	map("<C-k>", v.lsp.buf.signature_help, "Signature Documentation")

	map("<leader>ds", function()
		Snacks.picker.lsp_symbols()
	end, "[D]ocument [S]ymbols")
	map("<leader>ws", function()
		Snacks.picker.lsp_workspace_symbols()
	end, "[W]orkspace [S]ymbols")
	map("<leader>wa", v.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
	map("<leader>wr", v.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
	map("<leader>wl", function()
		print(v.inspect(v.lsp.buf.list_workspace_folders()))
	end, "[W]orkspace [L]ist Folders")

	map("<leader>lr", "<Cmd>lsp restart<CR>", "[R]estart")
	map("<leader>li", "<Cmd>checkhealth vim.lsp<CR>", "[I]nfo")

	v.api.nvim_buf_create_user_command(args.buf, "Format", function()
		v.lsp.buf.format()
	end, { desc = "Format current buffer with LSP" })
end

return {
	-- Only the server definitions (lsp/*.lua on the runtimepath); the client is Neovim's own
	"nvim-lspconfig",
	dev = true,
	event = { "BufReadPre", "BufNewFile" },
	config = function()
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
					formatting = { provider = "none" }, -- ruff formats
				},
			},
		})

		-- Notes as an Obsidian-style vault: links, backlinks, tags, daily notes (:LspToday and so on)
		v.lsp.config("markdown_oxide", {
			-- It watches the vault for files changed outside Neovim
			capabilities = { workspace = { didChangeWatchedFiles = { dynamicRegistration = true } } },
		})

		v.lsp.config("lua_ls", {
			settings = {
				Lua = {
					runtime = { version = "LuaJIT" },
					formatters = { ignoreComments = true },
					signatureHelp = { enabled = true },
					diagnostics = {
						globals = { "vim" },
						disable = { "missing-fields" },
					},
					telemetry = { enabled = false },
				},
			},
		})

		v.api.nvim_create_autocmd("LspAttach", {
			group = v.api.nvim_create_augroup("lsp_keymaps", { clear = true }),
			callback = on_attach,
		})

		v.lsp.enable(servers)
		-- rust-analyzer asks rustc for the sysroot and throws on every Rust buffer without it.
		-- The toolchain is not installed here; it comes from a project's dev shell.
		if v.fn.executable("rustc") == 1 then
			v.lsp.enable("rust_analyzer")
		end
	end,
}
