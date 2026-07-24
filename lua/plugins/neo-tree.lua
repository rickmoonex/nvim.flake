local mono = require("e-ink.palette").mono()
local devicons = require("nvim-web-devicons")

devicons.setup({ color_icons = false })
devicons.set_default_icon(devicons.get_default_icon().icon, mono[10], "246")
devicons.set_icon({
	proto = {
		icon = "󰅪",
		name = "Proto",
	},
})

require("neo-tree").setup({
	default_component_configs = {
		name = {
			use_git_status_colors = false,
		},
		git_status = {
			align = "right",
		},
	},
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
