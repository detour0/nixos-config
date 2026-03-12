local v = vim

-- v.api.nvim_create_autocmd("VimEnter", {
-- 	callback = function()
-- 		local path = v.fn.argv(0)
-- 		if path and v.fn.isdirectory(path) == 1 then
-- 			-- Expand to full absolute path
-- 			local full_path = v.fn.fnamemodify(path, ":p")
-- 			v.api.nvim_set_current_dir(full_path)
-- 			print("CWD set to: " .. full_path)
-- 		end
-- 	end,
-- })
