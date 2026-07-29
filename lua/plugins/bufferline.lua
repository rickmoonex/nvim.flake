local colors = require("theme.orchid").colors

require("bufferline").setup({
	options = {
		offsets = {
			{
				filetype = "neo-tree",
				text = "",
				highlight = "NeoTreeNormal",
				separator = true,
			},
		},
	},
	highlights = {
		fill = { bg = colors.none },
		background = { fg = colors.muted, bg = colors.none },
		buffer_selected = { fg = colors.foreground, bg = colors.surface, bold = true, italic = false },
		indicator_selected = { fg = colors.accent, bg = colors.surface },
		separator = { fg = colors.background, bg = colors.none },
		separator_selected = { fg = colors.accent, bg = colors.surface },
		modified = { fg = colors.yellow, bg = colors.none },
		modified_selected = { fg = colors.yellow, bg = colors.surface },
	},
})

vim.keymap.set("n", "<S-h>", function()
	require("bufferline").cycle(-1)
end, { desc = "Previous buffer" })
vim.keymap.set("n", "<S-l>", function()
	require("bufferline").cycle(1)
end, { desc = "Next buffer" })
