vim.opt.background = "dark"
vim.cmd.colorscheme("e-ink")

local set_hl = vim.api.nvim_set_hl
local palette = require("e-ink.palette")
local mono = palette.mono()

-- Everforest dark colors blended into the e-ink gray ramp, then slightly lifted.
local accent = {
	aqua = "#92A497",
	blue = "#91A3A1",
	green = "#9DA491",
	purple = "#AB99A1",
	red = "#B09191",
	yellow = "#ADA391",
}

-- Color only semantic landmarks and state that benefits from quick recognition.
local highlights = {
	Added = { fg = accent.green },
	Changed = { fg = accent.blue },
	Constant = { fg = accent.purple },
	DiagnosticError = { fg = accent.red },
	DiagnosticHint = { fg = accent.blue },
	DiagnosticInfo = { fg = accent.aqua },
	DiagnosticOk = { fg = accent.green },
	DiagnosticWarn = { fg = accent.yellow },
	DiagnosticUnderlineError = { sp = accent.red, underline = true },
	DiagnosticUnderlineHint = { sp = accent.blue, underline = true },
	DiagnosticUnderlineInfo = { sp = accent.aqua, underline = true },
	DiagnosticUnderlineOk = { sp = accent.green, underline = true },
	DiagnosticUnderlineWarn = { sp = accent.yellow, underline = true },
	DiffText = { fg = mono[16], bg = mono[5], bold = true },
	ErrorMsg = { fg = accent.red },
	Function = { fg = accent.green },
	MatchParen = { fg = accent.green, bold = true },
	Removed = { fg = accent.red },
	RenderMarkdownChecked = { fg = accent.green },
	RenderMarkdownWarn = { fg = accent.yellow },
	SpellBad = { sp = accent.red, undercurl = true },
	SpellCap = { sp = accent.blue, undercurl = true },
	SpellLocal = { sp = accent.green, undercurl = true },
	SpellRare = { sp = accent.purple, undercurl = true },
	Statement = { fg = accent.red },
	String = { fg = accent.aqua },
	Todo = { fg = accent.yellow, bold = true },
	Type = { fg = accent.yellow },
	WarningMsg = { fg = accent.yellow },
	["@constant"] = { fg = accent.purple },
	["@function"] = { fg = accent.green },
	["@function.call"] = { fg = accent.green },
	["@keyword"] = { fg = accent.red, italic = true },
	["@string"] = { fg = accent.aqua },
	["@type"] = { fg = accent.yellow },

	-- Telescope remains entirely within the grayscale ramp.
	TelescopeBorder = { fg = mono[7], bg = mono[1] },
	TelescopeMatching = { fg = mono[16], bold = true },
	TelescopeNormal = { fg = mono[12], bg = mono[1] },
	TelescopePreviewBorder = { fg = mono[7], bg = mono[1] },
	TelescopePreviewNormal = { fg = mono[12], bg = mono[1] },
	TelescopePromptBorder = { fg = mono[8], bg = mono[2] },
	TelescopePromptNormal = { fg = mono[14], bg = mono[2] },
	TelescopeResultsBorder = { fg = mono[7], bg = mono[1] },
	TelescopeResultsNormal = { fg = mono[12], bg = mono[1] },
	TelescopeSelection = { fg = mono[16], bg = mono[3], bold = true },
	TelescopeSelectionCaret = { fg = mono[16], bg = mono[3] },
	TelescopeTitle = { fg = mono[14], bg = mono[1], bold = true },
}

for group, styles in pairs(highlights) do
	set_hl(0, group, styles)
end

local git_highlights = {
	"NeoTreeGitAdded",
	"NeoTreeGitConflict",
	"NeoTreeGitDeleted",
	"NeoTreeGitIgnored",
	"NeoTreeGitModified",
	"NeoTreeGitRenamed",
	"NeoTreeGitStaged",
	"NeoTreeGitUnstaged",
	"NeoTreeGitUntracked",
}

for _, group in ipairs(git_highlights) do
	set_hl(0, group, { fg = mono[9] })
end
