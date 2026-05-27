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
vim.lsp.config("rust_analyzer", {
	settings = {
		["rust-analyzer"] = {
			check = {
				command = "clippy",
				allTargets = true,
				features = "all",
				extraArgs = {
					"--workspace",
					"--",
					"-Dwarnings",
					"-Wclippy::pedantic",
					"-Wclippy::nursery",
					"-Aclippy::module-name-repetitions",
				},
			},
		},
	},
})
vim.lsp.config("html", {
	filetypes = { "html", "templ" },
	init_options = {
		provideFormatter = true,
		embeddedLanguages = { css = true, javascript = true },
		configurationSection = { "html", "css", "javascript" },
	},
})
vim.lsp.config("cssls", {
	filetypes = { "css", "scss", "less" },
	init_options = { provideFormatter = true },
})
vim.lsp.config("buf_ls", {})
vim.lsp.config("emmet_language_server", {
	filetypes = {
		"html",
		"css",
		"scss",
		"less",
		"sass",
		"javascriptreact",
		"typescriptreact",
		"vue",
		"svelte",
	},
})

vim.lsp.enable({
	"ts_ls",
	"biome",
	"markdown_oxide",
	"nushell",
	"nu-lint",
	"zls",
	"rust_analyzer",
	"html",
	"cssls",
	"emmet_language_server",
	"buf_ls",
})

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
