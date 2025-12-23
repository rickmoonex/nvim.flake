vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set softtabstop=2")
vim.g.mapleader = " "

vim.keymap.set("n", "<c-k>", ":wincmd k<CR>")
vim.keymap.set("n", "<c-j>", ":wincmd j<CR>")
vim.keymap.set("n", "<c-h>", ":wincmd h<CR>")
vim.keymap.set("n", "<c-l>", ":wincmd l<CR>")
vim.keymap.set("n", "C-h", ":TmuxNavigateLeft<CR>")
vim.keymap.set("n", "C-j", ":TmuxNavigateDown<CR>")
vim.keymap.set("n", "C-k", ":TmuxNavigateUp<CR>")
vim.keymap.set("n", "C-l", ":TmuxNavigateRight")

vim.opt.number = true
vim.opt.relativenumber = true

vim.diagnostic.enable = true
vim.diagnostic.config({
	virtual_lines = true,
})

-- View persistence
vim.opt.viewoptions:append("folds")
local ignore_ft = { "help", "lazy", "neo-tree", "NvimTree", "gitcommit" }

local function should_ignore()
	return vim.tbl_contains(ignore_ft, vim.bo.filetype)
end

vim.api.nvim_create_autocmd("BufWinLeave", {
	callback = function()
		if should_ignore() then
			return
		end
		pcall(vim.cmd, "mkview")
	end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
	callback = function()
		if should_ignore() then
			return
		end
		pcall(vim.cmd, "loadview")
	end,
})
