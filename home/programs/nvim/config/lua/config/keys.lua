local v = vim

-- Remove search highlighting with Esc
v.keymap.set("n", "<Esc>", "<Esc>:nohlsearch<CR>", { silent = true })

-- Moving marked lines up and down
v.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Moves Line Down" })
v.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Moves Line Up" })

-- Fast up and down scrolling (this shouldn't be needed?)
-- v.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll Down" })
-- v.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll Up" })

-- Buffer actions
v.keymap.set("n", "<leader><leader>[", "<cmd>bprev<CR>", { desc = "Previous buffer" })
v.keymap.set("n", "<leader><leader>]", "<cmd>bnext<CR>", { desc = "Next buffer" })
v.keymap.set("n", "<leader><leader>l", "<cmd>b#<CR>", { desc = "Last buffer" })
v.keymap.set("n", "<leader><leader>x", "<cmd>bdelete<CR>", { desc = "Delete buffer" })
v.keymap.set("n", "<leader><leader>w", "<cmd>w<CR>", { desc = "[W]rite buffer" })

-- Resize windows with arrow keys
v.keymap.set("n", "<Down>", ":resize +2<CR>", { desc = "Increase window height" })
v.keymap.set("n", "<Up>", ":resize -2<CR>", { desc = "Decrease window height" })
v.keymap.set("n", "<Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })
v.keymap.set("n", "<Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })

-- see help sticky keys on windows
v.cmd([[command! W w]])
v.cmd([[command! Wq wq]])
v.cmd([[command! WQ wq]])
v.cmd([[command! Q q]])

-- Remap for dealing with word wrap
v.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
v.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
v.diagnostic.config({ jump = { float = true }, underline = true })
v.keymap.set("n", "<leader>e", v.diagnostic.open_float, { desc = "Open floating diagnostic message" })
v.keymap.set("n", "<leader>q", v.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- Yanking to clipboard
v.keymap.set({ "v", "x", "n" }, "<leader>y", '"+y', { noremap = true, silent = true, desc = "Yank to clipboard" })
v.keymap.set({ "n", "v", "x" }, "<leader>Y", '"+yy', { noremap = true, silent = true, desc = "Yank line to clipboard" })

v.keymap.set({ "n", "v", "x" }, "<C-a>", "gg0vG$", { noremap = true, silent = true, desc = "Select all" })
v.keymap.set({ "n", "v", "x" }, "<leader>p", '"+p', { noremap = true, silent = true, desc = "Paste from clipboard" })
-- v.keymap.set(
--   "i",
--   "<C-p>",
--   "<C-r><C-p>+",
--   { noremap = true, silent = true, desc = "Paste from clipboard from within insert mode" }
-- )
v.keymap.set(
	"x",
	"<leader>P",
	'"_dP',
	{ noremap = true, silent = true, desc = "Paste over selection without erasing unnamed register" }
)
