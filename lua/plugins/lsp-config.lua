local lspconfig = require("lspconfig")

-- If you use nvim-cmp:
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then
	capabilities = cmp_lsp.default_capabilities(capabilities)
end

local function on_attach(_, bufnr)
	local opts = { buffer = bufnr, silent = true }
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
end

lspconfig.ts_ls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})
