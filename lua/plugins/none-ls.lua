local null_ls = require("null-ls")

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.biome,
    null_ls.builtins.formatting.alejandra,
  },
})

vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
