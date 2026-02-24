local catppuccin = require("catppuccin")

catppuccin.setup({
	flavour = "frappe",
	transparent_background = true,
})

-- Force recompile to avoid stale cache after nix flake updates.
-- Nix store paths lack .git, so catppuccin's cache hash can collide
-- across different plugin versions.
catppuccin.compile()

vim.cmd.colorscheme("catppuccin")
