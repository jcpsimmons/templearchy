-- ============================================================================
-- WRITING & FOCUS PLUGINS
-- ============================================================================
return {
	{
		"gruvw/strudel.nvim",
		build = "npm ci",
		config = function()
			require("strudel").setup({})
		end,
	},
	{
		"junegunn/goyo.vim",
		dependencies = { "preservim/vim-pencil", "arnamak/stay-centered.nvim" },
		cmd = "Goyo",
		keys = { {
			"<leader>z",
			"<cmd>Goyo<CR>",
			desc = "[Z]en mode",
		} },
		config = function()
			local prose_fts = {
				markdown = true,
				text = true,
				rst = true,
				org = true,
				quarto = true,
				typst = true,
				asciidoc = true,
			}
			local function is_prose_ft()
				return prose_fts[vim.bo.filetype] == true
			end

			local ZEN = {
				diag_cfg = nil,
			}

			local function fidget_zen(hide)
				local ok, fidget = pcall(require, "fidget.notification")
				if not ok then
					return
				end
				if hide then
					fidget.clear()
					fidget.suppress(true)
				else
					fidget.suppress(false)
				end
			end

			local function goyo_enter()
				require("lualine").hide()
				fidget_zen(true)
				vim.cmd("Pencil")
				vim.cmd("PencilSoft") -- soft wrap (visual)

				-- Visual-only wrapping; never hard-wrap/save changes
				if is_prose_ft() then
					vim.opt_local.textwidth = 0
					vim.opt_local.formatoptions:remove({ "t", "a" }) -- no auto hard-wrap/autoformat
					vim.opt_local.wrap = true
					vim.opt_local.linebreak = true
					vim.opt_local.breakindent = true
				end

				-- Diagnostics: show ltex suggestions with subtle virtual text
				ZEN.diag_cfg = vim.deepcopy(vim.diagnostic.config())
				vim.diagnostic.config({
					virtual_text = {
						source = "if_many",
						prefix = "💡 ",
						spacing = 2,
						format = function(diagnostic)
							-- Show ltex diagnostics, hide others from virtual text
							if diagnostic.source == "ltex" or diagnostic.source == "LTeX LS" then
								return diagnostic.message
							end
							return false -- explicitly return false to hide
						end,
					},
					signs = {
						severity = { min = vim.diagnostic.severity.HINT }, -- show signs for ltex hints
					},
					underline = {
						severity = { min = vim.diagnostic.severity.HINT }, -- underline ltex suggestions
					},
					severity_sort = true,
					update_in_insert = false,
					float = {
						border = "rounded",
						source = "always",
						focusable = false,
						max_width = 80,
					},
				})
				vim.keymap.set("n", "<leader>d", function()
					vim.diagnostic.open_float(nil, {
						scope = "cursor",
					})
				end, {
					buffer = 0,
					desc = "Diagnostics (cursor)",
				})

				-- Visual line navigation for easier paragraph editing
				vim.keymap.set("n", "gj", "gj", {
					buffer = 0,
					desc = "Move down visual line",
				})
				vim.keymap.set("n", "gk", "gk", {
					buffer = 0,
					desc = "Move up visual line",
				})
				vim.keymap.set("n", "g0", "g0", {
					buffer = 0,
					desc = "Go to start of visual line",
				})
				vim.keymap.set("n", "g$", "g$", {
					buffer = 0,
					desc = "Go to end of visual line",
				})

				require("stay-centered").toggle()
			end

			local function goyo_leave()
				require("lualine").hide({
					unhide = true,
				})
				fidget_zen(false)
				vim.cmd("PencilOff")
				require("stay-centered").toggle()

				if ZEN.diag_cfg then
					vim.diagnostic.config(ZEN.diag_cfg)
					ZEN.diag_cfg = nil
				end
				pcall(vim.keymap.del, "n", "<leader>d", {
					buffer = 0,
				})

				-- Remove visual line navigation mappings
				pcall(vim.keymap.del, "n", "gj", {
					buffer = 0,
				})
				pcall(vim.keymap.del, "n", "gk", {
					buffer = 0,
				})
				pcall(vim.keymap.del, "n", "g0", {
					buffer = 0,
				})
				pcall(vim.keymap.del, "n", "g$", {
					buffer = 0,
				})
			end

			local augroup_id = vim.api.nvim_create_augroup("Goyo", {
				clear = true,
			})
			vim.api.nvim_create_autocmd("User", {
				pattern = "GoyoEnter",
				callback = goyo_enter,
				group = augroup_id,
			})
			vim.api.nvim_create_autocmd("User", {
				pattern = "GoyoLeave",
				callback = goyo_leave,
				group = augroup_id,
			})
		end,
	},
	{
		"preservim/vim-pencil",
		dependencies = { "godlygeek/tabular" },
	},
}
