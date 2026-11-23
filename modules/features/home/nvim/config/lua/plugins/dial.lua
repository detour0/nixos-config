-- <leader>+ / <leader>- increment and decrement numbers, booleans, dates and semvers under the cursor.
-- Not on <C-a>/<C-x>: <C-a> is select all (config/keys.lua).
local function dial(direction, mode)
	return function()
		require("dial.map").manipulate(direction, mode)
	end
end

return {
	"dial.nvim",
	dev = true,
	keys = {
		{ "<leader>+", dial("increment", "normal"), desc = "Increment / toggle under cursor" },
		{ "<leader>-", dial("decrement", "normal"), desc = "Decrement / toggle under cursor" },
		{ "<leader>+", dial("increment", "visual"), mode = "x", desc = "Increment / toggle in selection" },
		{ "<leader>-", dial("decrement", "visual"), mode = "x", desc = "Decrement / toggle in selection" },
	},
	config = function()
		local augend = require("dial.augend")
		require("dial.config").augends:register_group({
			default = {
				augend.integer.alias.decimal_int,
				augend.integer.alias.hex,
				augend.constant.alias.bool, -- true <-> false
				augend.constant.new({ elements = { "True", "False" } }), -- python
				augend.date.alias["%Y-%m-%d"],
				augend.semver.alias.semver,
			},
		})
	end,
}
