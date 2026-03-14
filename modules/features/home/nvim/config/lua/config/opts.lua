local v = vim

-- NOTE: These 2 need to be set up before any plugins are loaded.
v.g.mapleader = " "
v.g.maplocalleader = " "

-- [[ Setting options ]]
-- See `:help vim.o`

-- Disable netrw
-- v.g.loaded_netrw = 1
-- v.g.loaded_netrwPlugin = 1

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
v.opt.list = true
v.opt.listchars = {
	tab = "  ",
	trail = "￮",
	-- multispace = "￮", -- shows symbol in tab indentation at start of line
	extends = "▶",
	precedes = "◀",
	nbsp = "‿",
}

-- Show git-relativ filepath at top under bufferline
-- v.opt.winbar = "%#WinBar# %f %m"

-- Do not autoinstert comment when breaking new line
v.opt.formatoptions:remove({ "c", "r", "o" })

-- Search
v.opt.ignorecase = true -- search case insensitive
v.opt.smartcase = true -- search matters if capital letter
v.opt.inccommand = "split" -- splits screen to show all matches
v.opt.incsearch = true -- Show search matches as you type
v.opt.hlsearch = true -- Highlight all search matches

-- Tabs/Indents
v.opt.expandtab = true -- Convert tabs to spaces
v.opt.tabstop = 2 -- Number of spaces that a tab represents
v.opt.softtabstop = 2 -- Number of spaces for tab operations (editing)
v.opt.shiftwidth = 2 -- Number of spaces for each indentation level
v.opt.smartindent = true -- auto-indent based on syntax of the code
v.opt.cpoptions:append("I")
v.o.expandtab = true

-- Minimal number of screen lines to keep above and below the cursor.
v.opt.scrolloff = 10
-- Don't redraw screen while executing macros (improves performance)
v.opt.lazyredraw = true
-- Make line numbers default
v.wo.number = true

-- Enable mouse mode
v.o.mouse = "a"

-- stops line wrapping from being confusing
v.o.breakindent = true

-- Save undo history
v.o.undofile = true

-- Keep signcolumn on by default
v.wo.signcolumn = "yes"
v.wo.relativenumber = true

-- Decrease update time
v.o.updatetime = 250
v.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
v.o.completeopt = "menu,preview,noselect"

-- NOTE: You should make sure your terminal supports this
v.o.termguicolors = true
