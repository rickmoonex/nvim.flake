local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then
	capabilities = cmp_lsp.default_capabilities(capabilities)
end

vim.lsp.config("*", {
	capabilities = capabilities,
})

vim.lsp.config("ts_ls", {})
vim.lsp.config("biome", {})
vim.lsp.config("markdown_oxide", {})
vim.lsp.config("nushell", {})
vim.lsp.config("nu-lint", {
	cmd = { "nu-lint", "--lsp" },
	filetypes = { "nu" },
	root_markers = { ".git" },
})
vim.lsp.config("zls", {})

vim.lsp.enable({ "ts_ls", "biome", "markdown_oxide", "nushell", "nu-lint", "zls" })

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local opts = { buffer = args.buf, silent = true }
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
	end,
})
