require("zen-mode").setup({
	window = {
		width = 80,
		options = {
			number = false,
			relativenumber = false,
			signcolumn = "no",
		},
	},
	plugins = {
		twilight = { enabled = false },
	},
})

vim.keymap.set("n", "<leader>z", function()
	-- Focus a file buffer before toggling zen mode
	local dominated = { "neo-tree", "Outline", "noice", "notify" }
	local dominated_set = {}
	for _, ft in ipairs(dominated) do
		dominated_set[ft] = true
	end
	if dominated_set[vim.bo.filetype] then
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local buf = vim.api.nvim_win_get_buf(win)
			if not dominated_set[vim.bo[buf].filetype] and vim.bo[buf].buflisted then
				vim.api.nvim_set_current_win(win)
				break
			end
		end
	end
	vim.cmd("ZenMode")
end, { desc = "Toggle Zen Mode" })
