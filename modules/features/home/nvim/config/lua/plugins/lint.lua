local v = vim

local function lint()
	require("lint").try_lint()
end

return {
	"nvim-lint",
	dev = true,
	event = { "BufReadPre", "BufNewFile" },
	keys = {
		{ "<leader>L", lint, desc = "[L]int current file" },
	},
	config = function()
		require("lint").linters_by_ft = {
			dockerfile = { "hadolint" },
			html = { "htmlhint" },
			lua = { "luacheck" },
			nix = { "statix" },
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			python = { "ruff" },
			sql = { "sqlfluff" },
			markdown = { "markdownlint-cli2" },
		}
		require("lint").linters["markdownlint-cli2"].args =
			{ "--config", v.fn.stdpath("config") .. "/.markdownlint-cli2.jsonc", "-" }

		v.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = v.api.nvim_create_augroup("lint", { clear = true }),
			callback = lint,
		})
	end,
}
