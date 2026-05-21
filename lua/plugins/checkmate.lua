require("checkmate").setup({
  files = {
    "todo",
    "TODO",
    "todo.md",
    "TODO.md",
    "*.todo",
    "*.todo.md",
    vim.fn.expand("~/notes") .. "/**",
  },
})
