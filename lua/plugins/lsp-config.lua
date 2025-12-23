local lspconfig = require("lspconfig")

vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
vim.keymap.set("n", "gr", vim.lsp.buf.references)
local servers = { "ts_ls" }
for _, server in ipairs(servers) do
	vim.lsp.enable(server)
end
