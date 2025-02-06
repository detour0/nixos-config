local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Better Navigation
keymap({ "n", "x" }, "<C-j>", "<cmd>lua require('vscode').action('workbench.action.navigateDown')<CR>", opts)
keymap({ "n", "x" }, "<C-k>", "<cmd>lua require('vscode').action('workbench.action.navigateUp')<CR>", opts)
keymap({ "n", "x" }, "<C-h>", "<cmd>lua require('vscode').action('workbench.action.navigateLeft')<CR>", opts)
keymap({ "n", "x" }, "<C-l>", "<cmd>lua require('vscode').action('workbench.action.navigateRight')<CR>", opts)

-- Toggle editor widths
keymap("n", "<C-w>_", "<cmd>lua require('vscode').action('workbench.action.toggleEditorWidths')<CR>", opts)

-- Show which-key
keymap({ "n", "x" }, "<Space>", "<cmd>lua require('vscode').action('whichkey.show')<CR>", opts)

-- Comment Functionality
keymap({ "n", "x" }, "<C-/>", "<cmd>lua Comment()<CR>", opts)

-- remap leader key
keymap("n", "<Space>", "", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- yank to system clipboard
keymap({"n", "v"}, "<leader>y", '"+y', opts)
-- paste from system clipboard
keymap({"n", "v"}, "<leader>p", '"+p', opts)

-- better indent handling
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- move text up and down
keymap("v", "J", ":m .+1<CR>==", opts)
keymap("v", "K", ":m .-2<CR>==", opts)
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)

-- paste preserves primal yanked piece
keymap("v", "p", '"_dP', opts)

-- removes highlighting after escaping vim search
keymap("n", "<Esc>", "<Esc>:noh<CR>", opts)