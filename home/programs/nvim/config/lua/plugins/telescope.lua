-- Telescope is a fuzzy finder that comes with a lot of different things that
-- it can fuzzy find! It's more than just a "file finder", it can search
-- many different aspects of Neovim, your workspace, LSP, and more!
--
-- The easiest way to use telescope, is to start by doing something like:
--  :Telescope help_tags
--
-- After running this command, a window will open up and you're able to
-- type in the prompt window. You'll see a list of help_tags options and
-- a corresponding preview of the help.
--
-- Two important keymaps to use while in telescope are:
--  - Insert mode: <c-/>
--  - Normal mode: ?
--
-- This opens a window that shows you all of the keymaps for the current
-- telescope picker. This is really useful to discover what Telescope can
-- do as well as how to actually do it!

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`

-- Definig local v to escape all the warnings
local v = vim

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
	-- Use the current buffer's path as the starting point for the git search
	local current_file = v.api.nvim_buf_get_name(0)
	local current_dir
	local cwd = v.fn.getcwd()
	-- If the buffer is not associated with a file, return nil
	if current_file == "" then
		current_dir = cwd
	else
		-- Extract the directory from the current file's path
		current_dir = v.fn.fnamemodify(current_file, ":h")
	end

	-- Find the Git root directory from the current file's path
	local git_root = v.fn.systemlist("git -C " .. v.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
	if v.v.shell_error ~= 0 then
		print("Not a git repository. Searching on current working directory")
		return cwd
	end
	return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
	local git_root = find_git_root()
	if git_root then
		require("telescope.builtin").live_grep({
			search_dirs = { git_root },
		})
	end
end

return {
	{
		"telescope-nvim", -- Matches the Nix folder name
		dev = true, -- Tells Lazy to look in your Nix dev path
		dependencies = { "plenary.nvim" },
		cmd = "Telescope",
		keys = {
			{ "<leader>fM", "<cmd>Telescope notify<CR>", mode = { "n" }, desc = "[F]ind [M]essage" },
			{ "<leader>fp", live_grep_git_root, mode = { "n" }, desc = "[F]ind git [P]roject root" },
			{
				"<leader>/",
				function()
					-- Slightly advanced example of overriding default behavior and theme
					-- You can pass additional configuration to telescope to change theme, layout, etc.
					require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
						winblend = 10,
						previewer = false,
					}))
				end,
				mode = { "n" },
				desc = "[/] Fuzzily search in current buffer",
			},
			{
				"<leader>f/",
				function()
					require("telescope.builtin").live_grep({
						grep_open_files = true,
						prompt_title = "Live Grep in Open Files",
					})
				end,
				mode = { "n" },
				desc = "[F]ind [/] in Open Files",
			},
			{
				"<leader><leader>f",
				function()
					return require("telescope.builtin").buffers()
				end,
				mode = { "n" },
				desc = "[ ] Find existing buffers",
			},
			{
				"<leader>f.",
				function()
					return require("telescope.builtin").oldfiles()
				end,
				mode = { "n" },
				desc = '[F]ind Recent Files ("." for repeat)',
			},
			{
				"<leader>fr",
				function()
					return require("telescope.builtin").resume()
				end,
				mode = { "n" },
				desc = "[F]ind [R]esume",
			},
			{
				"<leader>fd",
				function()
					return require("telescope.builtin").diagnostics()
				end,
				mode = { "n" },
				desc = "[F]ind [D]iagnostics",
			},
			{
				"<leader>fg",
				function()
					return require("telescope.builtin").live_grep()
				end,
				mode = { "n" },
				desc = "[F]ind by [G]rep",
			},
			{
				"<leader>fw",
				function()
					return require("telescope.builtin").grep_string()
				end,
				mode = { "n" },
				desc = "[F]ind current [W]ord",
			},
			{
				"<leader>fs",
				function()
					return require("telescope.builtin").builtin()
				end,
				mode = { "n" },
				desc = "[F]ind [S]elect Telescope",
			},
			{
				"<leader>ff",
				function()
					return require("telescope.builtin").find_files()
				end,
				mode = { "n" },
				desc = "[F]ind [F]iles",
			},
			{
				"<leader>fk",
				function()
					return require("telescope.builtin").keymaps()
				end,
				mode = { "n" },
				desc = "[F]ind [K]eymaps",
			},
			{
				"<leader>fh",
				function()
					return require("telescope.builtin").help_tags()
				end,
				mode = { "n" },
				desc = "[F]ind [H]elp",
			},
		},
		config = function()
			require("telescope").setup({
				-- You can put your default mappings / updates / etc. in here
				--  All the info you're looking for is in `:help telescope.setup()`
				--
				defaults = {
					mappings = {
						i = { ["<c-enter>"] = "to_fuzzy_refine" },
					},
				},
				-- pickers = {}
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
			})

			-- Enable telescope extensions, if they are installed
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")

			v.api.nvim_create_user_command("LiveGrepGitRoot", live_grep_git_root, {})
		end,
	},
}
