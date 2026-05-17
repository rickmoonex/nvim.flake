-- forest-pixel: pixel art forest with teal character and crimson berries
local catppuccin = require("catppuccin")

catppuccin.setup({
	flavour = "mocha",
	transparent_background = true,
	color_overrides = {
		mocha = {
			base = "#282d20",
			mantle = "#323b28",
			crust = "#3c4832",
			surface0 = "#4a5840",
			surface1 = "#5c6c50",
			surface2 = "#6e7e62",

			-- Overlay
			overlay0 = "#829478",
			overlay1 = "#96a88e",
			overlay2 = "#aabca4",

			-- Text
			subtext0 = "#bcceb8",
			subtext1 = "#d0e0cc",
			text = "#e8f4e4",

			-- Accents
			red = "#e05050",
			maroon = "#c04040",
			flamingo = "#e88080",
			pink = "#e070a0",
			mauve = "#b098d0",
			blue = "#80b0c8",
			sapphire = "#98c4d4",
			sky = "#b0d4d8",
			teal = "#90c4b4",
			green = "#98c478",
			yellow = "#d8c878",
			peach = "#e0a080",
			lavender = "#b8dcd6",
			rosewater = "#e8f4e4",
		},
	},
	integrations = {
		bufferline = true,
		cmp = true,
		notify = true,
		noice = true,
		telescope = { enabled = true },
		treesitter = true,
		native_lsp = {
			enabled = true,
			underlines = {
				errors = { "undercurl" },
				hints = { "undercurl" },
				warnings = { "undercurl" },
				information = { "undercurl" },
			},
		},
		mini = { enabled = true },
	},
	custom_highlights = function()
		return {
			TelescopeNormal = { bg = "NONE" },
			TelescopeBorder = { bg = "NONE" },
			TelescopePromptNormal = { bg = "NONE" },
			TelescopePromptBorder = { bg = "NONE" },
			TelescopePromptTitle = { bg = "NONE" },
			TelescopePromptCounter = { bg = "NONE" },
			TelescopePromptPrefix = { bg = "NONE" },
			TelescopeResultsNormal = { bg = "NONE" },
			TelescopeResultsBorder = { bg = "NONE" },
			TelescopeResultsTitle = { bg = "NONE" },
			TelescopePreviewNormal = { bg = "NONE" },
			TelescopePreviewBorder = { bg = "NONE" },
			TelescopePreviewTitle = { bg = "NONE" },
			TelescopeSelection = { bg = "NONE" },
			TelescopeSelectionCaret = { bg = "NONE" },
		}
	end,
})

-- Force recompile to avoid stale cache after nix flake updates.
-- Nix store paths lack .git, so catppuccin's cache hash can collide
-- across different plugin versions.
catppuccin.compile()

vim.cmd.colorscheme("catppuccin")
