return function(client, bufnr)
  -- 1. nvim-navic (LSP Breadcrumbs)
  local ok_navic, navic = pcall(require, "nvim-navic")
  if ok_navic and client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end

  -- Helper to define LSP mappings
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  -- Standard LSP actions
  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- 2. Telescope vs. Built-in logic
  -- We check if telescope is available instead of using nixCats()
  local has_telescope, telescope_builtin = pcall(require, 'telescope.builtin')

  if has_telescope then
    nmap('gr', telescope_builtin.lsp_references, '[G]oto [R]eferences')
    nmap('gI', telescope_builtin.lsp_implementations, '[G]oto [I]mplementation')
    nmap('<leader>ds', telescope_builtin.lsp_document_symbols, '[D]ocument [S]ymbols')
    nmap('<leader>ws', telescope_builtin.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
  else
    -- 3. THE BUILT-IN VERSIONS (as requested)
    -- Neovim 0.11 uses a floating list or quickfix for these automatically
    nmap('gr', vim.lsp.buf.references, '[G]oto [R]eferences (Built-in)')
    nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation (Built-in)')
    nmap('<leader>ds', vim.lsp.buf.document_symbol, '[D]ocument [S]ymbols (Built-in)')
    nmap('<leader>ws', vim.lsp.buf.workspace_symbol, '[W]orkspace [S]ymbols (Built-in)')
  end

  -- Workspace management
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end
