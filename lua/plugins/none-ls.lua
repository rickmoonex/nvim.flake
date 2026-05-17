local null_ls = require("null-ls")

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.biome,
    null_ls.builtins.formatting.alejandra,
    null_ls.builtins.formatting.terraform_fmt,
  },
})

vim.keymap.set("n", "<leader>gf", function()
  if vim.bo.filetype == "rust" then
    pcall(vim.cmd, "MaudFormat")
  end
  vim.lsp.buf.format()
end, {})
