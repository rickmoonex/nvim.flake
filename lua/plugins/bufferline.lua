require("bufferline").setup({})

vim.keymap.set("n", "<S-h>", function()
	require("bufferline").cycle(-1)
end, { desc = "Previous buffer" })
vim.keymap.set("n", "<S-l>", function()
	require("bufferline").cycle(1)
end, { desc = "Next buffer" })
