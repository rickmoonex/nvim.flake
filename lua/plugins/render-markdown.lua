require("render-markdown").setup({
	-- Render in normal/command/terminal modes; show raw markdown while
	-- editing (insert mode) so tables are easy to modify.
	render_modes = { "n", "c", "t" },
	anti_conceal = {
		-- Reveal raw markdown on the line the cursor is on so you can
		-- edit it, while the rest of the buffer stays rendered.
		enabled = true,
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
