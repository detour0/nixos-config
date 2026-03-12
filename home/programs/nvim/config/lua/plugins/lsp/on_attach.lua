local v = vim

return function(client, bufnr)
	-- 1. nvim-navic (LSP Breadcrumbs)
	local ok_navic, navic = pcall(require, "nvim-navic")
	if ok_navic and client.server_capabilities.documentSymbolProvider then
		navic.attach(client, bufnr)
		v.opt_local.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
	end

	local ok_navbuddy, navbuddy = pcall(require, "nvim-navbuddy")
	if ok_navbuddy and client.server_capabilities.documentSymbolProvider then
		navbuddy.attach(client, bufnr)
	end

	-- Helper to define LSP mappings
	local nmap = function(keys, func, desc)
		if desc then
			desc = "LSP: " .. desc
		end
		v.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
	end

	if ok_navbuddy then
		nmap("<leader>n", function()
			navbuddy.open()
		end, "[N]av[B]uddy view")
	end

	-- Standard LSP actions
	nmap("<leader>lr", "<cmd>LspRestart<cr>", "[R]estart")
	nmap("<leader>li", "<cmd>LspInfo<cr>", "[L]SP [I]nfo")
	nmap("<leader>rn", v.lsp.buf.rename, "[R]e[n]ame")
	nmap("<leader>ca", v.lsp.buf.code_action, "[C]ode [A]ction")
	nmap("gd", v.lsp.buf.definition, "[G]oto [D]efinition")
	nmap("gD", v.lsp.buf.declaration, "[G]oto [D]eclaration")
	nmap("K", v.lsp.buf.hover, "Hover Documentation")
	nmap("<C-k>", v.lsp.buf.signature_help, "Signature Documentation")

	-- 2. Telescope vs. Built-in logic
	-- We check if telescope is available instead of using nixCats()
	local has_telescope, telescope_builtin = pcall(require, "telescope.builtin")

	if has_telescope then
		nmap("gr", telescope_builtin.lsp_references, "[G]oto [R]eferences")
		nmap("gI", telescope_builtin.lsp_implementations, "[G]oto [I]mplementation")
		nmap("<leader>ds", telescope_builtin.lsp_document_symbols, "[D]ocument [S]ymbols")
		nmap("<leader>ws", telescope_builtin.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
	else
		-- 3. THE BUILT-IN VERSIONS (as requested)
		-- Neov 0.11 uses a floating list or quickfix for these automatically
		nmap("gr", v.lsp.buf.references, "[G]oto [R]eferences (Built-in)")
		nmap("gI", v.lsp.buf.implementation, "[G]oto [I]mplementation (Built-in)")
		nmap("<leader>ds", v.lsp.buf.document_symbol, "[D]ocument [S]ymbols (Built-in)")
		nmap("<leader>ws", v.lsp.buf.workspace_symbol, "[W]orkspace [S]ymbols (Built-in)")
	end

	-- Workspace management
	nmap("<leader>D", v.lsp.buf.type_definition, "Type [D]efinition")
	nmap("<leader>wa", v.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
	nmap("<leader>wr", v.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
	nmap("<leader>wl", function()
		print(v.inspect(v.lsp.buf.list_workspace_folders()))
	end, "[W]orkspace [L]ist Folders")

	-- Create a command `:Format` local to the LSP buffer
	v.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
		v.lsp.buf.format()
	end, { desc = "Format current buffer with LSP" })
end
