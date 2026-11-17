local v = vim

local function builtin(picker, opts)
	return function()
		require("telescope.builtin")[picker](opts)
	end
end

-- Grep from the git root of the current buffer, or from the cwd outside a repository
local function live_grep_git_root()
	local root = v.fs.root(0, ".git")
	if not root then
		v.notify("Not a git repository, searching the working directory")
	end
	require("telescope.builtin").live_grep({ search_dirs = { root or v.fn.getcwd() } })
end

return {
	"telescope.nvim",
	dev = true,
	cmd = { "Telescope", "LiveGrepGitRoot" },
	dependencies = {
		"plenary.nvim",
		"telescope-fzf-native.nvim",
		"telescope-ui-select.nvim",
	},
	init = function()
		-- vim.ui.select goes through telescope (ui-select), which loads on the first use
		---@diagnostic disable-next-line: duplicate-set-field
		v.ui.select = function(...)
			require("lazy").load({ plugins = { "telescope.nvim" } })
			return v.ui.select(...)
		end
	end,
	opts = function()
		return {
			defaults = {
				sorting_strategy = "ascending",
				layout_strategy = "flex",
				layout_config = {
					prompt_position = "top",
					horizontal = {
						width = 0.95,
						height = 0.8,
						preview_width = 0.5,
					},
					vertical = {
						width = 0.9,
						height = 0.9,
					},
				},
				mappings = {
					i = {
						["<esc>"] = require("telescope.actions").close,
					},
				},
			},
		}
	end,
	config = function(_, opts)
		local telescope = require("telescope")
		telescope.setup(opts)
		telescope.load_extension("fzf")
		telescope.load_extension("ui-select")

		v.api.nvim_create_user_command("LiveGrepGitRoot", live_grep_git_root, {})
	end,
	keys = {
		{ "<leader>ff", builtin("find_files"), desc = "[F]ind [F]iles" },
		{ "<leader>fg", builtin("live_grep"), desc = "[F]ind by [G]rep" },
		{ "<leader>fp", live_grep_git_root, desc = "[F]ind git [P]roject root" },
		{ "<leader>fw", builtin("grep_string"), desc = "[F]ind current [W]ord" },
		{
			"<leader>f/",
			builtin("live_grep", { grep_open_files = true, prompt_title = "Live Grep in Open Files" }),
			desc = "[F]ind [/] in Open Files",
		},
		{ "<leader>f.", builtin("oldfiles"), desc = '[F]ind Recent Files ("." for repeat)' },
		{ "<leader>fr", builtin("resume"), desc = "[F]ind [R]esume" },
		{ "<leader>fd", builtin("diagnostics"), desc = "[F]ind [D]iagnostics" },
		{ "<leader>fk", builtin("keymaps"), desc = "[F]ind [K]eymaps" },
		{ "<leader>fh", builtin("help_tags"), desc = "[F]ind [H]elp" },
		{ "<leader>fs", builtin("builtin"), desc = "[F]ind [S]elect Telescope" },
		{ "<leader><leader>f", builtin("buffers"), desc = "[ ] Find existing buffers" },
		{
			"<leader>/",
			function()
				require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 10,
					previewer = false,
				}))
			end,
			desc = "[/] Fuzzily search in current buffer",
		},
	},
}
