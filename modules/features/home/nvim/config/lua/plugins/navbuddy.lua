local v = vim

-- Symbol tree of the buffer in a popup: move through it with h/j/k/l, act on whole symbols
local function open()
	local buf = v.api.nvim_get_current_buf()
	local clients = v.lsp.get_clients({ bufnr = buf, method = "textDocument/documentSymbol" })
	if #clients == 0 then
		v.notify("No LSP client with document symbols in this buffer")
		return
	end
	-- Attached here, on the first use, instead of to every client up front
	local navbuddy = require("nvim-navbuddy")
	for _, client in ipairs(clients) do
		navbuddy.attach(client, buf)
	end
	navbuddy.open(buf)
end

return {
	"nvim-navbuddy",
	dev = true,
	dependencies = { "nvim-navic", "nui.nvim" },
	opts = {
		mappings = {
			-- The default t opens telescope, which is not installed
			["t"] = {
				callback = function(display)
					display:close()
					Snacks.picker.lsp_symbols()
				end,
				description = "Fuzzy find symbols (snacks picker)",
			},
		},
	},
	keys = {
		{ "<leader>dn", open, desc = "[N]avbuddy symbol tree" },
	},
}
