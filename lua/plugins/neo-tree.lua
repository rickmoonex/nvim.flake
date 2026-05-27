require("neo-tree").setup({
	nesting_rules = {
		["package.json"] = {
			pattern = "^package%.json$", -- <-- Lua pattern
			files = { "package-lock.json", "yarn*" }, -- <-- glob pattern
		},
		["script_yaml_ts"] = {
			pattern = "^(.*)%.ts$",
			files = { "%1.script.yaml", "%1.script.lock" },
		},
		["script_yaml_py"] = {
			pattern = "^(.*)%.py$",
			files = { "%1.script.yaml", "%1.script.lock" },
		},
	},

	event_handlers = {
		{
			event = "neo_tree_buffer_enter",
			handler = function()
				vim.bo.buflisted = false
			end,
		},
	},
})
vim.keymap.set("n", "<C-e>", ":Neotree filesystem reveal left toggle<CR>", { desc = "Toggle Neo-tree" })
