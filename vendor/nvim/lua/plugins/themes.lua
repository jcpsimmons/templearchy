-- ============================================================================
-- THEMES & APPEARANCE
-- ============================================================================
return { -- Main colorscheme
{
    "sainnhe/everforest",
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
        -- Load the colorscheme here.
        vim.cmd.colorscheme("murphy")
        -- You can configure highlights by doing something like:
        vim.cmd.hi("Comment gui=none")
    end
}, -- Highlight todo, notes, etc in comments
{
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = {"nvim-lua/plenary.nvim"},
    opts = {
        signs = false
    }
}, -- Status line
{
    "nvim-lualine/lualine.nvim",
    opts = {
        theme = "16color"
    },
    dependencies = {"nvim-tree/nvim-web-devicons"}
}, -- Surround plugin
{"tpope/vim-surround"}, -- Collection of various small independent plugins/modules
{
    "echasnovski/mini.nvim",
    config = function()
        -- Better Around/Inside textobjects
        --
        -- Examples:
        --  - va)  - [V]isually select [A]round [)]paren
        --  - yinq - [Y]ank [I]nside [N]ext [']quote
        --  - ci'  - [C]hange [I]nside [']quote
        require("mini.ai").setup({
            n_lines = 500
        })

        -- Add/delete/replace surroundings (brackets, quotes, etc.)
        --
        -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
        -- - sd'   - [S]urround [D]elete [']quotes
        -- - sr)'  - [S]urround [R]eplace [)] [']
        -- disabled to use tpope/vim-surround instead
        -- require("mini.surround").setup()
    end
}}
