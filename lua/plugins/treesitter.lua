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
