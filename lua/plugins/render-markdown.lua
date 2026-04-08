require("render-markdown").setup({
	anti_conceal = {
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
		border = { "╭", "┬", "╮", "├", "┼", "┤", "╰", "┴", "╯", "│", "─" },
	},
})
