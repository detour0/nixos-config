local v = vim

local function pick(source, opts)
	return function()
		Snacks.picker[source](opts)
	end
end

-- Grep from the git root of the current buffer, or from the cwd outside a repository
local function grep_git_root()
	local root = v.fs.root(0, ".git")
	if not root then
		v.notify("Not a git repository, searching the working directory")
	end
	Snacks.picker.grep({ cwd = root or v.fn.getcwd() })
end

return {
	"snacks.nvim",
	dev = true,
	lazy = false,
	priority = 1000,
	opts = {
		dashboard = {
			enabled = true,
			sections = {
				{ section = "header" },
				{ icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
				{ icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
				{ icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
				{ section = "startup" },
			},
		},
		notifier = { enabled = true },
		indent = {
			enabled = true,
			indent = { char = "│" },
			animate = { enabled = false },
		},
		-- Also takes over vim.ui.select
		picker = {
			enabled = true,
			sources = {
				-- Dotfiles and dot-directories (.claude, .github, …) too; .git and .gitignored files stay out
				files = { hidden = true },
				grep = { hidden = true },
				-- Every git repository under dev, the projects listed here, and the recently used ones
				projects = {
					dev = { "~/workspace" },
					projects = { "~/.claude" },
				},
			},
			win = {
				input = {
					keys = {
						-- Close straight from insert mode, not only from normal mode
						["<Esc>"] = { "close", mode = { "n", "i" } },
						-- Tab only moves; Enter then opens just the focused item. Marking several for Enter is Ctrl+Space
						["<Tab>"] = { "list_down", mode = { "i", "n" } },
						["<S-Tab>"] = { "list_up", mode = { "i", "n" } },
						["<C-Space>"] = { "select_and_next", mode = { "i", "n" } },
					},
				},
				list = {
					keys = {
						["<Tab>"] = "list_down",
						["<S-Tab>"] = "list_up",
						["<C-Space>"] = { "select_and_next", mode = { "n", "x" } },
					},
				},
			},
		},
	},
	init = function()
		v.api.nvim_create_user_command("LiveGrepGitRoot", grep_git_root, {})
	end,
	keys = {
		{ "<leader>ff", pick("files"), desc = "[F]ind [F]iles" },
		{ "<leader>fg", pick("grep"), desc = "[F]ind by [G]rep" },
		{ "<leader>fP", grep_git_root, desc = "[F]ind git [P]roject root" },
		{ "<leader>fp", pick("projects"), desc = "[F]ind and switch to a [P]roject" },
		{ "<leader>fw", pick("grep_word"), mode = { "n", "x" }, desc = "[F]ind current [W]ord" },
		{ "<leader>f/", pick("grep_buffers"), desc = "[F]ind [/] in Open Files" },
		{ "<leader>f.", pick("recent"), desc = '[F]ind Recent Files ("." for repeat)' },
		{ "<leader>fr", pick("resume"), desc = "[F]ind [R]esume" },
		{ "<leader>fd", pick("diagnostics"), desc = "[F]ind [D]iagnostics" },
		{ "<leader>fk", pick("keymaps"), desc = "[F]ind [K]eymaps" },
		{ "<leader>fh", pick("help"), desc = "[F]ind [H]elp" },
		{ "<leader>fs", pick("pickers"), desc = "[F]ind [S]elect picker" },
		{ "<leader>fM", pick("notifications"), desc = "[F]ind [M]essage" },
		{ "<leader><leader>f", pick("buffers"), desc = "[ ] Find existing buffers" },
		{ "<leader>/", pick("lines"), desc = "[/] Fuzzily search in current buffer" },
	},
}
