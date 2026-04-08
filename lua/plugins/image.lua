local ok, image = pcall(require, "image")
if not ok then
	return
end

image.setup({
	backend = "kitty",
	processor = "magick_cli",
	integrations = {
		markdown = {
			enabled = true,
			clear_in_insert_mode = true,
			download_remote_images = true,
			only_render_image_at_cursor = false,
			filetypes = { "markdown" },
		},
	},
	max_height_window_percentage = 40,
	window_overlap_clear_enabled = true,
	window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "snacks_notif", "scrollview", "scrollview_sign" },
	editor_only_render_when_focused = true,
	tmux_show_only_in_active_window = true,
	hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
})

-- Clear orphaned images after deleting lines
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function(args)
		vim.keymap.set("n", "dd", function()
			local line = vim.api.nvim_get_current_line()
			vim.cmd("normal! dd")
			if line:match("!%[.*%]%(.*%)") then
				vim.defer_fn(function()
					if vim.api.nvim_buf_is_valid(args.buf) then
						image.clear()
						local imgs = image.get_images({ buffer = args.buf })
						for _, img in ipairs(imgs) do
							img:render()
						end
					end
				end, 50)
			end
		end, { buffer = args.buf, desc = "Delete line and clear orphaned images" })
	end,
})

-- Re-render images after render-markdown.nvim finishes placing extmarks.
-- image.nvim renders on BufWinEnter before render-markdown decorates,
-- so the virtual lines shift images out of place. This delayed re-render fixes it.
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
	pattern = "*.md",
	callback = function(args)
		vim.defer_fn(function()
			if vim.api.nvim_buf_is_valid(args.buf) and vim.bo[args.buf].filetype == "markdown" then
				local imgs = image.get_images({ buffer = args.buf })
				for _, img in ipairs(imgs) do
					img:clear()
					img:render()
				end
			end
		end, 500)
	end,
})
