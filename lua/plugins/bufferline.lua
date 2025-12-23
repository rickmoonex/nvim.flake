vim.opt.termguicolors = true
vim.keymap.set("n", "<C-[>", ":BufferLineCyclePrev<CR>", {})
vim.keymap.set("n", "<C-]>", ":BufferLineCycleNext<CR>", {})
vim.keymap.del("n", "<Esc>")
require("bufferline").setup({
	options = {
		offsets = {
			{
				filetype = "neo-tree",
				text = "File Explorer",
				text_align = "center",
				separator = true,
			},
		},
	},
})
