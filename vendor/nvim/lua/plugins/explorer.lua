-- ============================================================================
-- FILE EXPLORER
-- ============================================================================
return {{
    "nvim-neo-tree/neo-tree.nvim",
    version = "*",
    dependencies = {"nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim"},
    cmd = "Neotree",
    keys = {{
        "\\",
        ":Neotree reveal<CR>",
        desc = "NeoTree reveal"
    }},
    opts = {
        filesystem = {
            filtered_items = {
                visible = true,
                show_hidden_count = true,
                hide_dotfiles = false,
                hide_gitignored = false,
                hide_by_name = {"node_modules", ".git", ".DS_Store", "thumbs.db"},
                never_show = {}
            },
            window = {
                mappings = {
                    ["\\"] = "close_window"
                }
            }
        }
    }
}}
