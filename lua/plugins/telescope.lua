local telescope = require("telescope")
local builtin = require("telescope.builtin")
local fb_actions = require("telescope._extensions.file_browser.actions")

vim.keymap.set("n", "<leader>ff", builtin.find_files, {
	desc = "Telescope find files",
})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {
	desc = "Telescope live grep",
})
vim.keymap.set("n", "<C-e>", function()
	require("telescope").extensions.file_browser.file_browser()
end, { desc = "Open file browser" })

telescope.setup({
	extensions = {
		["ui-select"] = {
			require("telescope.themes").get_dropdown({}),
		},
		file_browser = {
			hijack_netrw = true,
			mappings = {
				["n"] = {
					a = fb_actions.create,
					c = false,
				},
			},
		},
	},
})
telescope.load_extension("ui-select")
telescope.load_extension("file_browser")
