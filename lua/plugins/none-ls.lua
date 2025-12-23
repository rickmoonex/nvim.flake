local null_ls = require("null-ls")

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.prettierd,
    require("none-ls.diagnostics.eslint_d"),
    null_ls.builtins.formatting.alejandra,
  },
})

vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
