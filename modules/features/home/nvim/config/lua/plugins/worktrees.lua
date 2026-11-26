local v = vim

-- Agent task worktrees: ~/workspace/.worktrees/<task>/<repo> (rules in ~/workspace/home/AGENTS.md)
local root = v.fs.normalize("~/workspace/.worktrees")

local function git(dir, args)
	local out = v.system(v.list_extend({ "git", "-C", dir }, args), { text = true }):wait()
	return out.code == 0 and v.trim(out.stdout) or ""
end

local function count(lines)
	return lines == "" and 0 or #v.split(lines, "\n")
end

-- Where the task branch left main. The working tree against it is everything the task changed, committed or
-- not, without what other sessions merged into main since.
local function base(dir)
	local sha = git(dir, { "merge-base", "main", "HEAD" })
	return sha ~= "" and sha or "HEAD"
end

local function items()
	local list = {}
	for _, dir in ipairs(v.fn.glob(root .. "/*/*", false, true)) do
		if v.uv.fs_stat(dir .. "/.git") then
			local task, repo = dir:match("([^/]+)/([^/]+)$")
			local status = git(dir, { "status", "--short" })
			local log = git(dir, { "log", "--oneline", "main..HEAD" })
			local stat = git(dir, { "diff", "--stat", base(dir) })
			list[#list + 1] = {
				text = task .. " " .. repo,
				task = task,
				repo = repo,
				dir = dir,
				changed = count(status),
				commits = count(log),
				preview = {
					text = table.concat({
						"Uncommitted:",
						status ~= "" and status or "  none",
						"",
						"Commits since main:",
						log ~= "" and log or "  none",
						"",
						"Against main (merge base):",
						stat ~= "" and stat or "  no changes",
					}, "\n"),
					ft = "git",
				},
			}
		end
	end
	return list
end

local function switch(picker, item)
	picker:close()
	if item then
		v.cmd.tcd(v.fn.fnameescape(item.dir))
	end
	return item
end

-- Enter: switch the tab to the worktree and open the task's diff
local function review(picker, item)
	if switch(picker, item) then
		v.cmd("DiffviewOpen -C=" .. v.fn.fnameescape(item.dir) .. " " .. base(item.dir))
	end
end

-- Ctrl+O: switch the tab to the worktree and pick a file in it
local function files(picker, item)
	if switch(picker, item) then
		Snacks.picker.files({ cwd = item.dir })
	end
end

local function pick()
	local list = items()
	if #list == 0 then
		v.notify("No worktrees in " .. root)
		return
	end
	Snacks.picker({
		title = "Worktrees",
		items = list,
		format = function(item)
			return {
				{ ("%-28s"):format(item.task), "Title" },
				{ ("%-16s"):format(item.repo), "Directory" },
				{ ("%d uncommitted, %d commits"):format(item.changed, item.commits), "Comment" },
			}
		end,
		preview = "preview",
		confirm = review,
		actions = { files = files },
		win = { input = { keys = { ["<C-o>"] = { "files", mode = { "n", "i" } } } } },
	})
end

-- Adds to the snacks.nvim spec in snacks.lua
return {
	"snacks.nvim",
	dev = true,
	keys = {
		{ "<leader>gw", pick, desc = "Review a task [W]orktree (Ctrl+O: its files)" },
	},
}
