-- Treesitter highlight and indent are enabled by default in Neovim 0.11+.
-- With nixCats, grammars are installed via Nix (nvim-treesitter.withAllGrammars),
-- so no runtime install/setup is needed.

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99

vim.cmd([[silent! autocmd! filetypedetect BufRead,BufNewFile *.tf]])
vim.cmd([[autocmd BufRead,BufNewFile *.hcl set filetype=hcl]])
vim.cmd([[autocmd BufRead,BufNewFile .terraformrc,terraform.rc set filetype=hcl]])
vim.cmd([[autocmd BufRead,BufNewFile *.tf,*.tfvars set filetype=terraform]])
vim.cmd([[autocmd BufRead,BufNewFile *.tfstate,*.tfstate.backup set filetype=json]])

-- Nushell has no built-in Vim syntax file, so highlighting only works if we
-- explicitly start the tree-sitter parser on FileType.
vim.api.nvim_create_autocmd("FileType", {
	pattern = "nu",
	callback = function() vim.treesitter.start() end,
})

-- Rhai: detect `.rhai` and `.d.rhai` definition files as the `rhai` filetype.
-- `.d.rhai` must be registered before `.rhai` so the more specific pattern wins,
-- though both resolve to the same filetype here.
vim.filetype.add({
	extension = {
		rhai = "rhai",
	},
	pattern = {
		[".*%.d%.rhai"] = "rhai",
	},
})

-- The Rhai tree-sitter grammar is custom-built via Nix and is not known to
-- nvim-treesitter's filetype<->parser registry, so register it explicitly and
-- start the parser on FileType (Rhai has no built-in Vim syntax file either).
local ok_parsers, parsers = pcall(require, "nvim-treesitter.parsers")
if ok_parsers and parsers.get_parser_configs then
	local parser_configs = parsers.get_parser_configs()
	parser_configs.rhai = parser_configs.rhai
		or {
			install_info = { url = "none", files = {} },
			filetype = "rhai",
		}
end

vim.treesitter.language.register("rhai", "rhai")

vim.api.nvim_create_autocmd("FileType", {
	pattern = "rhai",
	callback = function() vim.treesitter.start() end,
})

require("nvim-ts-autotag").setup({})
