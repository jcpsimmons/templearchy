-- ============================================================================
-- AUTOCOMMANDS
-- ============================================================================
-- Highlight text when yanking
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", {
		clear = true,
	}),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Filetype detection for Strudel files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	desc = "Set filetype for Strudel files",
	group = vim.api.nvim_create_augroup("strudel-filetype", {
		clear = true,
	}),
	pattern = "*.str",
	callback = function()
		vim.bo.filetype = "javascript"
	end,
})

-- TypeScript/JavaScript formatting on save
-- Only create this autocommand in terminal mode - VSCode handles formatting
if not vim.g.vscode then
	local autocmd = vim.api.nvim_create_autocmd
	local Format = vim.api.nvim_create_augroup("Format", {
		clear = true,
	})
	autocmd("BufWritePre", {
		group = Format,
		pattern = "*.ts,*.tsx,*.jsx,*.js,*.str",
		callback = function(args)
			vim.cmd("TSToolsOrganizeImports sync") -- sync keyword avoids race condition
			vim.cmd("TSToolsAddMissingImports sync")
			require("conform").format({
				bufnr = args.buf,
			})
		end,
	})
end
