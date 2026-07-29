local colors = require("theme.orchid").colors
local devicons = require("nvim-web-devicons")

devicons.setup({ color_icons = true })
devicons.set_icon({
	proto = {
		icon = "󰅪",
		color = colors.bright_magenta,
		name = "Proto",
	},
})

local icon_palette = { colors.blue, colors.cyan, colors.yellow, colors.bright_magenta }

local function rgb(hex)
	local value = tonumber(hex:sub(2), 16)
	return math.floor(value / 65536) % 256, math.floor(value / 256) % 256, value % 256
end

local function nearest_icon_color(hex)
	local red, green, blue = rgb(hex)
	local nearest, shortest

	for _, candidate in ipairs(icon_palette) do
		local candidate_red, candidate_green, candidate_blue = rgb(candidate)
		local distance = (red - candidate_red) ^ 2 + (green - candidate_green) ^ 2 + (blue - candidate_blue) ^ 2
		if not shortest or distance < shortest then
			nearest = candidate
			shortest = distance
		end
	end

	return nearest
end

local function apply_icon_palette()
	local applied = {}
	for _, icon in pairs(devicons.get_icons()) do
		if icon.name and icon.color and not applied[icon.name] then
			vim.api.nvim_set_hl(0, "DevIcon" .. icon.name, { fg = nearest_icon_color(icon.color) })
			applied[icon.name] = true
		end
	end
	vim.api.nvim_set_hl(0, "DevIconDefault", { fg = colors.cyan })
end

apply_icon_palette()
vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "orchid-dark",
	group = vim.api.nvim_create_augroup("OrchidDevicons", { clear = true }),
	callback = apply_icon_palette,
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
