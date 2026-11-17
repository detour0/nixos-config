local v = vim
local o = v.opt

-- Leader keys have to be set before any plugin loads
v.g.mapleader = " "
v.g.maplocalleader = " "

-- Whitespace: tabs stay blank (indent-blankline draws the guides), the rest is marked
o.list = true
o.listchars = {
	tab = "  ",
	trail = "￮",
	extends = "▶",
	precedes = "◀",
	nbsp = "‿",
}

-- Search
o.ignorecase = true
o.smartcase = true -- case sensitive once a capital letter is typed
o.inccommand = "split" -- preview :substitute in a split

-- Indentation
o.expandtab = true
o.tabstop = 2
o.softtabstop = 2
o.shiftwidth = 2
o.smartindent = true
o.breakindent = true -- wrapped lines keep their indent
o.cpoptions:append("I") -- keep autoindent when moving off an otherwise empty line

-- UI
o.number = true
o.relativenumber = true
o.signcolumn = "yes"
o.scrolloff = 10
o.termguicolors = true
o.mouse = "a"
o.lazyredraw = true -- no redraw while a macro runs

-- Behaviour
o.undofile = true
o.updatetime = 250
o.timeoutlen = 300
o.completeopt = "menu,preview,noselect"

v.diagnostic.config({
	underline = true,
	jump = {
		-- Show the diagnostic that ]d / [d land on
		on_jump = function(_, bufnr)
			v.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
		end,
	},
})
