local vault_path = nixCats("obsidian.vault_path") or "~/Vault"
local notes_subdir = nixCats("obsidian.notes_subdir") or "inbox"

-- Save code snippet to vault as a new note (available in all modes)
vim.keymap.set("v", "<leader>cs", function()
	-- Capture selection before leaving visual mode
	local start_line = vim.fn.line("v")
	local end_line = vim.fn.line(".")
	if start_line > end_line then
		start_line, end_line = end_line, start_line
	end
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
	local ft = vim.bo.filetype
	local cwd = vim.fn.getcwd()
	local cwd_name = vim.fn.fnamemodify(cwd, ":t")
	local abs_file = vim.fn.expand("%:p")
	local rel_path = abs_file:sub(#cwd + 2)
	local source_path = cwd_name .. "/" .. rel_path

	-- Leave visual mode and defer prompt so <Esc> doesn't land in the input
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)

	vim.schedule(function()
	vim.ui.input({ prompt = "Snippet title: " }, function(title)
		if not title or title == "" then
			return
		end

		vim.ui.input({ prompt = "Summary: " }, function(summary)
			if not summary then
				summary = ""
			end

			local vault = vim.fn.expand(vault_path)
			local subdir = vault .. "/" .. notes_subdir
			local daily_folder_name = nixCats("obsidian.daily_notes_folder") or "daily"
			local filename = title:lower():gsub(" ", "_")

			-- Write the note
			vim.fn.mkdir(subdir, "p")
			local note_path = subdir .. "/" .. filename .. ".md"
			local content = {
				"---",
				"tags:",
				"  - snippet",
				"---",
				"",
				"# " .. title,
				"",
			}
			if summary ~= "" then
				table.insert(content, summary)
				table.insert(content, "")
			end
			table.insert(content, "Source: `" .. source_path .. "`")
			table.insert(content, "")
			table.insert(content, "```" .. ft)
			for _, line in ipairs(lines) do
				table.insert(content, line)
			end
			table.insert(content, "```")
			table.insert(content, "")

			vim.fn.writefile(content, note_path)
			vim.notify("Snippet saved to " .. note_path, vim.log.levels.INFO)

			-- Add journal entry to today's daily note
			local daily_dir = vault .. "/" .. daily_folder_name
			vim.fn.mkdir(daily_dir, "p")
			local today = os.date("%Y-%m-%d")
			local now = os.date("%H:%M")
			local daily_path = daily_dir .. "/" .. today .. ".md"
			local journal_entry = '- **' .. now .. '**: Created code snippet [[' .. filename .. ']]'

			if vim.fn.filereadable(daily_path) == 0 then
				vim.fn.writefile({
					"---",
					"done: false",
					"---",
					"",
					"# " .. today,
					"",
					"## Tasks",
					"",
					"## Notes",
					"",
					"## Journal",
					"",
					"- **" .. now .. "**: Note created",
					journal_entry,
					"",
				}, daily_path)
			else
				local daily_lines = vim.fn.readfile(daily_path)
				local journal_idx = nil
				local next_section = nil
				for i, l in ipairs(daily_lines) do
					if l == "## Journal" then
						journal_idx = i
					elseif journal_idx and not next_section and l:match("^## ") then
						next_section = i
					end
				end
				if journal_idx then
					local insert_at = next_section or (#daily_lines + 1)
					-- Walk back over blank lines
					while insert_at > journal_idx + 1 and daily_lines[insert_at - 1] == "" do
						insert_at = insert_at - 1
					end
					-- Add blank line if first entry
					local has_content = false
					for i = journal_idx + 1, insert_at - 1 do
						if daily_lines[i] ~= "" then
							has_content = true
							break
						end
					end
					if not has_content then
						table.insert(daily_lines, insert_at, "")
						insert_at = insert_at + 1
						if next_section then
							next_section = next_section + 1
						end
					end
					table.insert(daily_lines, insert_at, journal_entry)
					if next_section then
						-- Ensure blank line before next section
						if daily_lines[insert_at + 1] and daily_lines[insert_at + 1] ~= "" then
							table.insert(daily_lines, insert_at + 1, "")
						end
					end
				else
					table.insert(daily_lines, "")
					table.insert(daily_lines, "## Journal")
					table.insert(daily_lines, "")
					table.insert(daily_lines, journal_entry)
				end
				vim.fn.writefile(daily_lines, daily_path)
			end
		end)
	end)
	end)
end, { desc = "Save code snippet to Obsidian" })

if not vim.g.obsidian_mode then
	return
end

local ok, obsidian = pcall(require, "obsidian")
if not ok then
	return
end

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
		order = { " ", "~", "x" },
	},
	legacy_commands = false,
})

if not setup_ok then
	vim.notify("obsidian.nvim: " .. err, vim.log.levels.WARN)
end

-- Obsidian command palette
vim.keymap.set("n", "<leader>oc", "<cmd>Obsidian<cr>", { desc = "Obsidian commands" })

-- Open today's daily note
vim.keymap.set("n", "<leader>dd", "<cmd>Obsidian today<cr>", { desc = "Today's daily note" })

-- Show unreviewed daily notes
vim.keymap.set("n", "<leader>dr", function()
	local vault = vim.fn.expand(vault_path)
	local daily_dir = vault .. "/" .. (nixCats("obsidian.daily_notes_folder") or "daily")
	local files = vim.fn.glob(daily_dir .. "/*.md", false, true)
	local unreviewed = {}

	for _, f in ipairs(files) do
		local lines = vim.fn.readfile(f, "", 5)
		local in_frontmatter = false
		local is_done = false
		for _, line in ipairs(lines) do
			if line == "---" then
				in_frontmatter = not in_frontmatter
			elseif in_frontmatter and line:match("^done:%s*true") then
				is_done = true
				break
			end
		end
		if not is_done then
			table.insert(unreviewed, f)
		end
	end

	table.sort(unreviewed)

	local entries = {}
	for _, f in ipairs(unreviewed) do
		table.insert(entries, vim.fn.fnamemodify(f, ":t"))
	end

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	pickers
		.new({}, {
			prompt_title = "Unreviewed Daily Notes (" .. #entries .. ")",
			finder = finders.new_table({ results = entries }),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					if selection then
						vim.cmd("edit " .. vim.fn.fnameescape(daily_dir .. "/" .. selection[1]))
					end
				end)
				return true
			end,
		})
		:find()
end, { desc = "Unreviewed daily notes" })

-- Toggle done status on current daily note
vim.keymap.set("n", "<leader>dx", function()
	local lines = vim.fn.readfile(vim.fn.expand("%:p"))
	local found = false
	for i, line in ipairs(lines) do
		if line:match("^done:%s*false") then
			lines[i] = "done: true"
			found = true
			break
		elseif line:match("^done:%s*true") then
			lines[i] = "done: false"
			found = true
			break
		end
	end
	if found then
		vim.fn.writefile(lines, vim.fn.expand("%:p"))
		vim.cmd("edit!")
		local is_done = vim.fn.readfile(vim.fn.expand("%:p"), "", 5)
		for _, l in ipairs(is_done) do
			if l:match("^done:%s*true") then
				vim.notify("Daily note marked as done", vim.log.levels.INFO)
				return
			end
		end
		vim.notify("Daily note marked as not done", vim.log.levels.INFO)
	else
		vim.notify("No done property found in frontmatter", vim.log.levels.WARN)
	end
end, { desc = "Toggle daily note done" })

-- Auto-save for markdown files in the vault
vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave", "InsertLeave" }, {
	pattern = vim.fn.expand(vault_path) .. "/**",
	callback = function(args)
		if vim.bo[args.buf].modified and vim.bo[args.buf].modifiable then
			vim.api.nvim_buf_call(args.buf, function()
				vim.cmd("silent! write")
			end)
		end
	end,
})

-- Spell checking and heading navigation for markdown
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function(args)
		local spelldir = vim.fn.stdpath("data") .. "/spell"
		vim.fn.mkdir(spelldir, "p")
		vim.opt_local.spell = true
		vim.opt_local.spelllang = "en"
		vim.opt_local.spellfile = spelldir .. "/en.utf-8.add"

		-- Jump between headings with [ and ]
		vim.keymap.set("n", "]", function()
			vim.fn.search("^##\\+\\s", "W")
		end, { buffer = args.buf, nowait = true, desc = "Next heading" })

		vim.keymap.set("n", "[", function()
			vim.fn.search("^##\\+\\s", "bW")
		end, { buffer = args.buf, nowait = true, desc = "Previous heading" })
	end,
})

-- Navigate between daily notes
local daily_folder = nixCats("obsidian.daily_notes_folder") or "daily"

vim.keymap.set("n", "<leader>dp", function()
	local vault = vim.fn.expand(vault_path)
	local dir = vault .. "/" .. daily_folder
	local today = os.date("%Y-%m-%d")
	-- Find files in the daily folder, sorted descending
	local files = vim.fn.glob(dir .. "/*.md", false, true)
	table.sort(files)
	local current_file = dir .. "/" .. today .. ".md"
	local buf_path = vim.fn.expand("%:p")
	if buf_path:match("/" .. daily_folder .. "/") then
		current_file = buf_path
	end
	-- Find the previous file
	for i = #files, 1, -1 do
		if files[i] < current_file then
			vim.cmd("edit " .. vim.fn.fnameescape(files[i]))
			return
		end
	end
	vim.notify("No previous daily note", vim.log.levels.INFO)
end, { desc = "Previous daily note" })

vim.keymap.set("n", "<leader>dn", function()
	local vault = vim.fn.expand(vault_path)
	local dir = vault .. "/" .. daily_folder
	local today = os.date("%Y-%m-%d")
	local files = vim.fn.glob(dir .. "/*.md", false, true)
	table.sort(files)
	local current_file = dir .. "/" .. today .. ".md"
	local buf_path = vim.fn.expand("%:p")
	if buf_path:match("/" .. daily_folder .. "/") then
		current_file = buf_path
	end
	for i = 1, #files do
		if files[i] > current_file then
			vim.cmd("edit " .. vim.fn.fnameescape(files[i]))
			return
		end
	end
	vim.notify("No next daily note", vim.log.levels.INFO)
end, { desc = "Next daily note" })

-- Search tags across vault via telescope
vim.keymap.set("n", "<leader>ot", function()
	local vault = vim.fn.expand(vault_path)
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	-- Collect all unique tags from vault (both inline #tag and frontmatter tags)
	local tags = {}
	local tag_set = {}

	-- Scan with ripgrep for inline #tags
	local inline = vim.fn.systemlist({ "rg", "--no-filename", "-oN", "#[a-zA-Z][a-zA-Z0-9_/-]*", vault })
	for _, tag in ipairs(inline) do
		if not tag_set[tag] then
			tag_set[tag] = true
			table.insert(tags, tag)
		end
	end

	-- Scan frontmatter tags (lines like "  - tagname" under "tags:")
	local fm_lines = vim.fn.systemlist({ "rg", "--no-filename", "-N", "^  - [a-zA-Z]", vault, "--glob", "*.md" })
	for _, line in ipairs(fm_lines) do
		local t = line:match("^%s*-%s+(.+)$")
		if t and not t:match("%s") then
			local tag = "#" .. t
			if not tag_set[tag] then
				tag_set[tag] = true
				table.insert(tags, tag)
			end
		end
	end

	table.sort(tags)

	pickers
		.new({}, {
			prompt_title = "Vault Tags",
			finder = finders.new_table({ results = tags }),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					if selection then
						local tag = selection[1]:gsub("^#", "")
						require("telescope.builtin").grep_string({
							search = "#" .. tag .. "\\b|^\\s*-\\s+" .. tag .. "$",
							use_regex = true,
							cwd = vault,
							prompt_title = "Notes tagged: #" .. tag,
						})
					end
				end)
				return true
			end,
		})
		:find()
end, { desc = "Search vault tags" })

-- Find orphan notes (no other note links to them)
vim.keymap.set("n", "<leader>oo", function()
	local vault = vim.fn.expand(vault_path)
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values

	-- Collect all markdown files
	local files = vim.fn.globpath(vault, "**/*.md", false, true)

	-- Build a set of all wiki-link targets across the vault
	local linked = {}
	for _, f in ipairs(files) do
		local content = table.concat(vim.fn.readfile(f), "\n")
		for link in content:gmatch("%[%[([^%]|]+)") do
			linked[link:lower()] = true
		end
	end

	-- Find notes that nobody links to
	local orphans = {}
	for _, f in ipairs(files) do
		local name = vim.fn.fnamemodify(f, ":t:r")
		if not linked[name:lower()] then
			local rel = f:sub(#vault + 2)
			table.insert(orphans, rel)
		end
	end

	table.sort(orphans)

	pickers
		.new({}, {
			prompt_title = "Orphan Notes (" .. #orphans .. ")",
			finder = finders.new_table({ results = orphans }),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr)
				local actions = require("telescope.actions")
				local action_state = require("telescope.actions.state")
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					if selection then
						vim.cmd("edit " .. vim.fn.fnameescape(vault .. "/" .. selection[1]))
					end
				end)
				return true
			end,
		})
		:find()
end, { desc = "Find orphan notes" })

-- Extract headings from a file, skipping frontmatter
local function get_headings(filepath)
	local headings = {}
	local lines = vim.fn.readfile(filepath)
	local start = 1
	if lines[1] == "---" then
		for i = 2, #lines do
			if lines[i] == "---" then
				start = i + 1
				break
			end
		end
	end
	for i = start, #lines do
		local heading = lines[i]:match("^#+%s+(.+)$")
		if heading then
			table.insert(headings, heading)
		end
	end
	return headings
end

-- Insert wiki-link via telescope note picker (notes + headings)
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function(args)
		vim.keymap.set("i", "[[", function()
			local vault = vim.fn.expand(vault_path)
			local files = vim.fn.globpath(vault, "**/*.md", false, true)
			local current_file = vim.fn.expand("%:p")
			local entries = {}

			-- Current note headings from buffer (includes unsaved changes)
			local buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
			local start = 1
			if buf_lines[1] == "---" then
				for i = 2, #buf_lines do
					if buf_lines[i] == "---" then
						start = i + 1
						break
					end
				end
			end
			for i = start, #buf_lines do
				local heading = buf_lines[i]:match("^#+%s+(.+)$")
				if heading then
					table.insert(entries, "#" .. heading)
				end
			end

			-- All notes and their headings
			for _, f in ipairs(files) do
				local name = vim.fn.fnamemodify(f, ":t:r")
				table.insert(entries, name)
				if f ~= current_file then
					for _, h in ipairs(get_headings(f)) do
						table.insert(entries, name .. "#" .. h)
					end
				end
			end

			table.sort(entries)

			local pickers = require("telescope.pickers")
			local finders = require("telescope.finders")
			local conf = require("telescope.config").values
			local actions = require("telescope.actions")
			local action_state = require("telescope.actions.state")

			pickers
				.new({}, {
					prompt_title = "Insert Link",
					finder = finders.new_table({ results = entries }),
					sorter = conf.generic_sorter({}),
					attach_mappings = function(prompt_bufnr)
						actions.select_default:replace(function()
							local selection = action_state.get_selected_entry()
							actions.close(prompt_bufnr)
							if selection then
								local text = "[[" .. selection[1] .. "]]"
								vim.api.nvim_put({ text }, "", false, true)
								local key = vim.api.nvim_replace_termcodes("a", true, false, true)
								vim.api.nvim_feedkeys(key, "n", false)
							end
						end)
						return true
					end,
				})
				:find()
		end, { buffer = args.buf, desc = "Insert wiki-link" })
	end,
})

-- Link word under cursor to existing or new note
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function(args)
		vim.keymap.set("n", "<leader>ll", function()
			local word = vim.fn.expand("<cword>")
			local vault = vim.fn.expand(vault_path)
			local files = vim.fn.globpath(vault, "**/*.md", false, true)
			local notes = {}
			for _, f in ipairs(files) do
				table.insert(notes, vim.fn.fnamemodify(f, ":t:r"))
			end
			table.sort(notes)

			-- Add "Create: <word>" as the first option
			table.insert(notes, 1, "+ Create new: " .. word)

			local pickers = require("telescope.pickers")
			local finders = require("telescope.finders")
			local conf = require("telescope.config").values
			local actions = require("telescope.actions")
			local action_state = require("telescope.actions.state")

			pickers
				.new({}, {
					prompt_title = "Link: " .. word,
					default_text = word,
					finder = finders.new_table({ results = notes }),
					sorter = conf.generic_sorter({}),
					attach_mappings = function(prompt_bufnr)
						actions.select_default:replace(function()
							local selection = action_state.get_selected_entry()
							actions.close(prompt_bufnr)
							if not selection then
								return
							end

							local chosen = selection[1]
							local link_name

							if chosen:match("^%+ Create new: ") then
								-- Create a new note
								local title = action_state.get_current_line()
								if title == "" then
									title = word
								end
								local filename = title:lower():gsub(" ", "_")
								local subdir = vault .. "/" .. notes_subdir
								vim.fn.mkdir(subdir, "p")
								local note_path = subdir .. "/" .. filename .. ".md"
								if vim.fn.filereadable(note_path) == 0 then
									vim.fn.writefile({ "# " .. title, "" }, note_path)
								end
								link_name = filename
							else
								link_name = chosen
							end

							-- Replace the word under cursor with the wiki-link
							vim.cmd("normal! ciw[[" .. link_name .. "]]")
						end)
						return true
					end,
				})
				:find()
		end, { buffer = args.buf, desc = "Link word to note" })
	end,
})

-- Obsidian follow link / backlinks
vim.keymap.set("n", "<leader>l", function()
	local ok_link, _ = pcall(vim.cmd, "Obsidian follow_link")
	if not ok_link then
		vim.cmd("Obsidian backlinks")
	end
end, { desc = "Obsidian Follow Link / Backlinks" })

-- Auto-continue task lists and journal entries in markdown
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
			elseif line:match("^%s*- %*%*%d%d:%d%d%*%*: $") then
				-- Empty journal entry: clear and break out
				vim.api.nvim_set_current_line("")
				return "<CR>"
			elseif line:match("^%s*- %*%*%d%d:%d%d%*%*: ") then
				local indent = line:match("^(%s*)")
				local time = os.date("%H:%M")
				return "<CR>" .. indent .. "- **" .. time .. "**: "
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

-- Paste image from clipboard into markdown
local img_ok, img_clip = pcall(require, "img-clip")
if img_ok then
	local vault = vim.fn.expand(vault_path)
	img_clip.setup({
		default = {
			dir_path = vault .. "/assets",
			relative_to_current_file = false,
			prompt_for_file_name = false,
			file_name = "%Y%m%d_%H%M%S",
		},
	})
	vim.keymap.set("n", "<leader>p", "<cmd>PasteImage<cr>", { desc = "Paste image from clipboard" })
end

-- Wrap visual selection as markdown link with clipboard URL
vim.keymap.set("v", "<leader>k", function()
	local url = vim.fn.getreg("+"):gsub("%s+$", "")
	if not url:match("^https?://") then
		vim.notify("Clipboard does not contain a URL", vim.log.levels.WARN)
		return
	end

	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
	vim.schedule(function()
		local start_pos = vim.api.nvim_buf_get_mark(0, "<")
		local end_pos = vim.api.nvim_buf_get_mark(0, ">")
		local line = vim.api.nvim_buf_get_lines(0, start_pos[1] - 1, start_pos[1], false)[1]
		local text = line:sub(start_pos[2] + 1, end_pos[2] + 1)
		local replacement = "[" .. text .. "](" .. url .. ")"
		vim.api.nvim_buf_set_text(0, start_pos[1] - 1, start_pos[2], end_pos[1] - 1, end_pos[2] + 1, { replacement })
	end)
end, { desc = "Wrap selection as markdown link with clipboard URL" })

-- Cheatsheet popup
vim.keymap.set("n", "<leader>?", function()
	local lines = {
		" Obsidian Keybindings",
		"",
		" Navigation",
		"  <leader>oc     Obsidian command palette",
		"  <leader>l      Follow link / backlinks",
		"  <leader>dd     Today's daily note",
		"  <leader>dr     Unreviewed daily notes",
		"  <leader>dx     Toggle daily note done",
		"  <leader>dp     Previous daily note",
		"  <leader>dn     Next daily note",
		"  [  ]           Jump between headings",
		"",
		" Notes",
		"  <leader>cs     Save code snippet (visual)",
		"  <leader>k      Wrap as markdown link (visual)",
		"  <leader>p      Paste image from clipboard",
		"  <leader>ot     Search tags across vault",
		"  <leader>oo     Find orphan notes",
		"  <leader>ll     Link word under cursor",
		"  [[              Insert wiki-link (insert mode)",
		"",
		" Writing",
		"  <leader>z      Toggle Zen Mode",
		"  <CR>           Auto-continue tasks/journal (insert)",
		"  :TableModeToggle  Toggle table mode",
		"",
		" Spelling",
		"  zg              Add word to dictionary",
		"  zw              Mark word as wrong",
		"  zug             Undo add to dictionary",
		"  z=              Show suggestions",
		"  ]s / [s         Next / previous misspelling",
		"",
		" Press q to close",
	}

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	vim.bo[buf].bufhidden = "wipe"

	local width = 50
	local height = #lines
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = " Cheatsheet ",
		title_pos = "center",
	})

	vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, nowait = true })
	vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, nowait = true })
end, { desc = "Obsidian cheatsheet" })

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
