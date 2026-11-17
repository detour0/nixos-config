local v = vim
local map = v.keymap.set

map("n", "<Esc>", "<Cmd>nohlsearch<CR><Esc>", { desc = "Clear search highlight" })

-- Move the selected lines, reindenting as they go
map("x", "J", ":m '>+1<CR>gv=gv", { silent = true, desc = "Move selection down" })
map("x", "K", ":m '<-2<CR>gv=gv", { silent = true, desc = "Move selection up" })

-- Resize windows with the arrow keys
map("n", "<Up>", "<Cmd>resize +2<CR>", { desc = "Increase window height" })
map("n", "<Down>", "<Cmd>resize -2<CR>", { desc = "Decrease window height" })
map("n", "<Right>", "<Cmd>vertical resize +2<CR>", { desc = "Increase window width" })
map("n", "<Left>", "<Cmd>vertical resize -2<CR>", { desc = "Decrease window width" })

-- Move by screen line on wrapped lines, unless a count is given
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Down" })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Up" })

-- Diagnostics
map("n", "<leader>e", v.diagnostic.open_float, { desc = "Open floating diagnostic message" })
map("n", "<leader>q", v.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- System clipboard
map({ "n", "x" }, "<leader>y", '"+y', { desc = "Yank to clipboard" })
map({ "n", "x" }, "<leader>Y", '"+yy', { desc = "Yank line to clipboard" })
map({ "n", "x" }, "<leader>p", '"+p', { desc = "Paste from clipboard" })
map("x", "<leader>P", '"_dP', { desc = "Paste over selection, keeping the unnamed register" })

map({ "n", "x" }, "<C-a>", "<Esc>gg0vG$", { desc = "Select all" })

map("t", "<Esc>", "<C-\\><C-n>", { desc = "Leave terminal mode" })

-- Shift held a little too long (see :help sticky keys)
for typo, cmd in pairs({ W = "w", Wq = "wq", WQ = "wq", Q = "q" }) do
	v.api.nvim_create_user_command(typo, cmd, {})
end
