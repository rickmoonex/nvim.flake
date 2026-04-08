local ok, obsidian = pcall(require, "obsidian")
if not ok then
	return
end

local vault_path = nixCats("obsidian.vault_path") or "~/Vault"
local notes_subdir = nixCats("obsidian.notes_subdir") or "inbox"
local config_dir = require("nixCats").configDir

local setup_ok, err = pcall(obsidian.setup, {
	workspaces = {
		{
			name = "vault",
			path = vault_path,
		},
	},
	notes_subdir = notes_subdir,
	new_notes_location = "notes_subdir",
	note_id_func = function(title)
		if title then
			return title:lower():gsub(" ", "_")
		end
		return tostring(os.time())
	end,
	note = {
		template = config_dir .. "/templates/note.md",
	},
	daily_notes = {
		folder = nixCats("obsidian.daily_notes_folder") or "daily",
		date_format = "%Y-%m-%d",
		template = config_dir .. "/templates/daily.md",
	},
	checkbox = {
		create_new = false,
		order = { " ", "x" },
	},
	legacy_commands = false,
})

if not setup_ok then
	vim.notify("obsidian.nvim: " .. err, vim.log.levels.WARN)
end

-- Auto-continue task lists in markdown
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function(args)
		vim.keymap.set("i", "<CR>", function()
			local line = vim.api.nvim_get_current_line()
			if line:match("^%s*- %[.%] $") then
				-- Empty task: clear the line and break out of the list
				vim.api.nvim_set_current_line("")
				return "<CR>"
			elseif line:match("^%s*- %[.%] ") then
				local indent = line:match("^(%s*)")
				return "<CR>" .. indent .. "- [ ] "
			end
			return "<CR>"
		end, { buffer = args.buf, expr = true })
	end,
})

-- Prevent obsidian.nvim's <CR> smart_action from overriding neo-tree mappings
vim.api.nvim_create_autocmd("FileType", {
	pattern = "neo-tree",
	callback = function(args)
		pcall(vim.keymap.del, "n", "<CR>", { buffer = args.buf })
	end,
})

if vim.g.obsidian_mode then
	vim.api.nvim_create_autocmd("VimEnter", {
		once = true,
		callback = function()
			local vault = vim.fn.expand(vault_path)
			vim.cmd("Obsidian today")
			vim.cmd("Neotree filesystem show left dir=" .. vim.fn.fnameescape(vault))
			vim.cmd("wincmd l")
			require("outline").open({ focus_outline = false })
		end,
	})
end
