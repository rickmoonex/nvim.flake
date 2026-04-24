local null_ls = require("null-ls")
local helpers = require("null-ls.helpers")

local nufmt = helpers.make_builtin({
  name = "nufmt",
  meta = {
    url = "https://github.com/nushell/nufmt",
    description = "Nushell formatter",
  },
  method = require("null-ls.methods").internal.FORMATTING,
  filetypes = { "nu" },
  generator_opts = {
    command = "nufmt",
    args = { "--stdin" },
    to_stdin = true,
  },
  factory = helpers.formatter_factory,
})

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.biome,
    null_ls.builtins.formatting.alejandra,
    null_ls.builtins.formatting.terraform_fmt,
    nufmt,
  },
})

vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
