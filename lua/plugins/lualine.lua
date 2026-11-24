local colors = require("theme.rose-pine")

local rose_pine = {
	normal = {
		a = { fg = colors.background, bg = colors.accent, gui = "bold" },
		b = { fg = colors.foreground, bg = colors.raised },
		c = { fg = colors.foreground, bg = colors.surface },
	},
	insert = {
		a = { fg = colors.background, bg = colors.blue, gui = "bold" },
	},
	visual = {
		a = { fg = colors.foreground, bg = colors.magenta, gui = "bold" },
	},
	replace = {
		a = { fg = colors.background, bg = colors.red, gui = "bold" },
	},
	command = {
		a = { fg = colors.background, bg = colors.yellow, gui = "bold" },
	},
	inactive = {
		a = { fg = colors.muted, bg = colors.background },
		b = { fg = colors.muted, bg = colors.background },
		c = { fg = colors.muted, bg = colors.background },
	},
}

require("lualine").setup({
	options = {
		theme = rose_pine,
		component_separators = "│",
		section_separators = { left = "", right = "" },
	},
})
