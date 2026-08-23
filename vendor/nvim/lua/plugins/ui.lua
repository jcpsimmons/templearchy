-- ============================================================================
-- UI & NAVIGATION PLUGINS
-- ============================================================================
return {{
    "folke/which-key.nvim",
    event = "VimEnter",
    config = function()
        local wk = require("which-key")
        wk.setup()
        wk.add({{
            "<leader>t",
            group = "[T]erminal",
            icon = {
                icon = "",
                color = "yellow"
            }
        }, {
            "<leader>g",
            group = "[G]it"
        }, {
            "<leader>l",
            group = "[L]SP"
        }, {
            "<leader>f",
            group = "[F]ormat",
            icon = {
                icon = "",
                color = "green"
            }
        }, {
            "<leader>c",
            group = "[C]omment",
            icon = {
                icon = "󰆈",
                color = "blue"
            }
        }, {
            "<leader>d",
            group = "[D]ocument",
            icon = {
                icon = "",
                color = "orange"
            }
        }, {
            "<leader>r",
            group = "[R]ename"
        }, {
            "<leader>s",
            group = "[S]earch",
            icon = {
                icon = "",
                color = "red"
            }
        }, {
            "<leader>w",
            group = "[W]orkspace",
            icon = {
                icon = "󰇃",
                color = "green"
            }
        }})
    end
}, {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    branch = "master",
    dependencies = {"nvim-lua/plenary.nvim", {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
            return vim.fn.executable("make") == 1
        end
    }, {"nvim-telescope/telescope-ui-select.nvim"}, {
        "nvim-tree/nvim-web-devicons",
        enabled = vim.g.have_nerd_font
    }},
    config = function()
        require("telescope").setup({
            extensions = {
                ["ui-select"] = {require("telescope.themes").get_dropdown()}
            }
        })
        pcall(require("telescope").load_extension, "fzf")
        pcall(require("telescope").load_extension, "ui-select")

        local builtin = require("telescope.builtin")

        -- In VSCode, some telescope keymaps should defer to VSCode equivalents
        if vim.g.vscode then
            local vscode = require("vscode")

            -- Only override <leader>sw to use VSCode equivalent
            -- Keep <leader>sf and <leader>sg using Telescope as requested
            vim.keymap.set("n", "<leader>sw", function()
                vscode.action("workbench.action.findInFiles", {
                    args = {
                        query = vim.fn.expand("<cword>")
                    }
                })
            end, {
                desc = "[S]earch current [W]ord (VSCode)"
            })
            
            -- Use telescope for file and grep search as requested
            vim.keymap.set("n", "<leader>sf", builtin.find_files, {
                desc = "[S]earch [F]iles"
            })
            vim.keymap.set("n", "<leader>sg", builtin.live_grep, {
                desc = "[S]earch by [G]rep"
            })
        else
            -- Terminal mode - use normal telescope keymaps
            vim.keymap.set("n", "<leader>sf", builtin.find_files, {
                desc = "[S]earch [F]iles"
            })
            vim.keymap.set("n", "<leader>sg", builtin.live_grep, {
                desc = "[S]earch by [G]rep"
            })
            vim.keymap.set("n", "<leader>sw", builtin.grep_string, {
                desc = "[S]earch current [W]ord"
            })
        end

        -- These keymaps work well in both VSCode and terminal
        vim.keymap.set("n", "<leader>sh", builtin.help_tags, {
            desc = "[S]earch [H]elp"
        })
        vim.keymap.set("n", "<leader>sk", builtin.keymaps, {
            desc = "[S]earch [K]eymaps"
        })
        vim.keymap.set("n", "<leader>ss", builtin.builtin, {
            desc = "[S]earch [S]elect Telescope"
        })
        vim.keymap.set("n", "<leader>sd", builtin.diagnostics, {
            desc = "[S]earch [D]iagnostics"
        })
        vim.keymap.set("n", "<leader>sr", builtin.resume, {
            desc = "[S]earch [R]esume"
        })
        vim.keymap.set("n", "<leader>s.", builtin.oldfiles, {
            desc = '[S]earch Recent Files ("." for repeat)'
        })
        vim.keymap.set("n", "<leader><leader>", builtin.buffers, {
            desc = "[ ] Find existing buffers"
        })
        vim.keymap.set("n", "<leader>/", function()
            builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
                winblend = 10,
                previewer = false
            }))
        end, {
            desc = "[/] Fuzzily search in current buffer"
        })
        vim.keymap.set("n", "<leader>s/", function()
            builtin.live_grep({
                grep_open_files = true,
                prompt_title = "Live Grep in Open Files"
            })
        end, {
            desc = "[S]earch [/] in Open Files"
        })
    end
}, {
    "nvim-lualine/lualine.nvim",
    cond = not vim.g.vscode, -- Only load in terminal mode
    opts = {
        theme = "16color"
    },
    dependencies = {"nvim-tree/nvim-web-devicons"}
}}
