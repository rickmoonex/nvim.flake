require("render-markdown").setup({
	-- Render only in normal/command/terminal modes. Insert and visual
	-- modes are excluded so raw markdown is shown while editing or
	-- selecting text.
	render_modes = { "n", "c", "t" },
	anti_conceal = {
		-- Keep the cursor line rendered in normal mode (no raw reveal).
		-- Raw markdown is instead shown by switching to insert/visual mode.
		enabled = false,
	},
	heading = {
		icons = { " ", " ", " ", " ", " ", " " },
		border = false,
		above = "",
		below = "",
		width = "full",
	},
	checkbox = {
		unchecked = { icon = "󰄱 " },
		checked = { icon = "󰄲 " },
		custom = {
			in_progress = {
				raw = "[~]",
				rendered = "󰡖 ",
				highlight = "RenderMarkdownWarn",
			},
		},
	},
	bullet = {
		icons = { "•", "◦", "▸", "▹" },
	},
	code = {
		border = "thin",
		width = "block",
		left_pad = 2,
		right_pad = 2,
	},
	dash = {
		width = 60,
	},
	link = {
		image = "󰥶 ",
		hyperlink = "󰌹 ",
	},
	pipe_table = {
		style = "full",
		-- Pad cells so columns line up and the vertical separators merge
		-- into continuous borders even when the source rows are ragged.
		cell = "padded",
		alignment_indicator = "━",
		border = { "╭", "┬", "╮", "├", "┼", "┤", "╰", "┴", "╯", "│", "─" },
	},
})

-- Follow markdown links with <CR> in normal mode.
--
-- Resolution is done in pure Lua relative to the CURRENT FILE's directory
-- (CommonMark semantics). The markdown-oxide LSP is intentionally NOT used
-- here: it resolves targets by name relative to the workspace root and does
-- not handle parent traversal like `../d1.md`, which produced
-- "no location found". Handles [text](target) links, [[wikilinks]],
-- #anchors, external URLs, and falls back to a normal <CR>.
local function follow_markdown_link()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- 1-indexed

	-- Find the [text](target) span that contains the cursor.
	local target
	local search_start = 1
	while true do
		local s, e, link = string.find(line, "%[[^%]]*%]%(([^)]+)%)", search_start)
		if not s then
			break
		end
		if col >= s and col <= e then
			target = link
			break
		end
		search_start = e + 1
	end

	-- Fallback: bare [[wikilink]] under the cursor.
	if not target then
		local s, e, wl = string.find(line, "%[%[([^%]]+)%]%]")
		while s do
			if col >= s and col <= e then
				target = wl:gsub("|.*$", "")
				if not target:match("%.%w+$") and not target:match("#") then
					target = target .. ".md"
				end
				break
			end
			s, e, wl = string.find(line, "%[%[([^%]]+)%]%]", e + 1)
		end
	end

	-- Nothing link-like under the cursor: behave like a normal <CR>.
	if not target or target == "" then
		local cr = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
		vim.api.nvim_feedkeys(cr, "n", false)
		return
	end

	target = vim.trim(target)

	-- External URLs / non-file schemes: hand off to the OS / browser.
	if target:match("^%w[%w+.-]*://") or target:match("^mailto:") or target:match("^tel:") then
		if vim.ui.open then
			vim.ui.open(target)
		else
			vim.cmd("normal! gx")
		end
		return
	end

	-- Split off an #anchor (heading) fragment, if any.
	local path, anchor = target:match("^([^#]*)#(.*)$")
	if not path then
		path = target
	end

	local function jump_to_anchor(a)
		if a and a ~= "" then
			local needle = a:gsub("%-", " ")
			vim.fn.search("\\c^#\\+\\s\\+" .. vim.fn.escape(needle, "\\/.*$^~[]"), "w")
		end
	end

	-- Same-file "#heading" link: search within the current buffer.
	if path == "" and anchor and anchor ~= "" then
		jump_to_anchor(anchor)
		return
	end

	-- URL-decode %20 etc. so paths with spaces work.
	path = path:gsub("%%(%x%x)", function(h)
		return string.char(tonumber(h, 16))
	end)

	-- Resolve relative to the CURRENT FILE's directory.
	local resolved
	if path:match("^~") or path:match("^/") then
		resolved = vim.fn.fnamemodify(vim.fn.expand(path), ":p")
	else
		local base = vim.fn.expand("%:p:h")
		resolved = vim.fn.fnamemodify(base .. "/" .. path, ":p")
	end

	if vim.fn.filereadable(resolved) == 0 and vim.fn.isdirectory(resolved) == 0 then
		vim.notify("Target not found: " .. resolved, vim.log.levels.ERROR)
		return
	end

	vim.cmd.edit(vim.fn.fnameescape(resolved))
	jump_to_anchor(anchor)
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function(args)
		vim.keymap.set(
			"n",
			"<CR>",
			follow_markdown_link,
			{ buffer = args.buf, silent = true, desc = "Follow markdown link" }
		)
	end,
})
