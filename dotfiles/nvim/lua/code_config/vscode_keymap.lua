local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

vim.opt.ignorecase = true -- search case insensitiv
vim.opt.smartcase = true -- search matters if capital letter
vim.opt.inccommand = "split" -- "for incsearch while sub

-- Better Navigation
keymap({ "n", "x" }, "<C-j>", "<cmd>lua require('vscode').action('workbench.action.navigateDown')<CR>", opts)
keymap({ "n", "x" }, "<C-k>", "<cmd>lua require('vscode').action('workbench.action.navigateUp')<CR>", opts)
keymap({ "n", "x" }, "<C-h>", "<cmd>lua require('vscode').action('workbench.action.navigateLeft')<CR>", opts)
keymap({ "n", "x" }, "<C-l>", "<cmd>lua require('vscode').action('workbench.action.navigateRight')<CR>", opts)

-- Show which-key
keymap({ "n", "x" }, "<Space>", "<cmd>lua require('vscode').action('whichkey.show')<CR>", opts)
-- Show Hover Menu
keymap("n", "H", "<cmd>lua require('vscode').action('editor.action.showHover')<CR>", opts)

-- ////////// DOES NOT WORK BUT IMPORTANT /////////////
-- yank to system clipboard
keymap({ "n", "v" }, "<C+y>", "<cmd>lua require('vscode').action('editor.action.clipboardCopyAction')<CR>", opts)
keymap({ "n", "v" }, "<C+p>", "<cmd>lua require('vscode').action('editor.action.clipboardPasteAction')<CR>", opts)

-- Cycle through open Editors
keymap({ "n", "v" }, "<Tab>", "<cmd>lua require('vscode').action('workbench.action.nextEditorInGroup')<CR>", opts)
keymap({ "n", "v" }, "<S-Tab>", "<cmd>lua require('vscode').action('workbench.action.previousEditorInGroup')<CR>", opts)

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

-- general keymaps
-- keymap({"n", "v"}, "<leader>t", "<cmd>lua require('vscode').action('workbench.action.terminal.toggleTerminal')<CR>")
-- keymap({"n", "v"}, "<leader>b", "<cmd>lua require('vscode').action('editor.debug.action.toggleBreakpoint')<CR>")
-- keymap({"n", "v"}, "<leader>d", "<cmd>lua require('vscode').action('editor.action.showHover')<CR>")
-- keymap({"n", "v"}, "<leader>a", "<cmd>lua require('vscode').action('editor.action.quickFix')<CR>")
-- keymap({"n", "v"}, "<leader>sp", "<cmd>lua require('vscode').action('workbench.actions.view.problems')<CR>")
-- keymap({"n", "v"}, "<leader>cn", "<cmd>lua require('vscode').action('notifications.clearAll')<CR>")
-- keymap({"n", "v"}, "<leader>ff", "<cmd>lua require('vscode').action('workbench.action.quickOpen')<CR>")
-- keymap({"n", "v"}, "<leader>cp", "<cmd>lua require('vscode').action('workbench.action.showCommands')<CR>")
-- keymap({"n", "v"}, "<leader>pr", "<cmd>lua require('vscode').action('code-runner.run')<CR>")
-- keymap({"n", "v"}, "<leader>fd", "<cmd>lua require('vscode').action('editor.action.formatDocument')<CR>")
