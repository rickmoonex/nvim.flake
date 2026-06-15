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
-- Local/relative links and [[wikilinks]] are resolved via the
-- markdown-oxide LSP (textDocument/definition). External URLs are
-- opened with the system handler (gx). Falls back to a normal <CR>
-- when the cursor is not on a link.
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function(args)
		vim.keymap.set("n", "<CR>", function()
			-- Grab the WORD under the cursor to detect an external URL.
			local word = vim.fn.expand("<cWORD>")
			if word:match("https?://") or word:match("^<?https?://") then
				vim.cmd("normal! gx")
				return
			end

			-- Prefer LSP definition (resolves relative links / wikilinks).
			local clients = vim.lsp.get_clients({ bufnr = args.buf, method = "textDocument/definition" })
			if not vim.tbl_isempty(clients) then
				vim.lsp.buf.definition()
				return
			end

			-- No link handler available: behave like a normal <CR>.
			local cr = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
			vim.api.nvim_feedkeys(cr, "n", false)
		end, { buffer = args.buf, silent = true, desc = "Follow markdown link" })
	end,
})
