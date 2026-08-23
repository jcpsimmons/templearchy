-- ============================================================================
-- TERMINAL PLUGINS
-- ============================================================================
return {{
    "voldikss/vim-floaterm",
    keys = {{
        "<leader>tn",
        "<cmd>FloatermNew<CR>",
        desc = "[T]erminal [n]ew"
    }, {
        "<leader>tt",
        "<cmd>FloatermToggle<CR>",
        desc = "[T]erminal [t]oggle"
    }, {
        "<leader>tk",
        "<cmd>FloatermKill<CR>",
        desc = "[T]erminal [k]ill"
    }, {
        "<leader>tl",
        "<cmd>FloatermNext<CR>",
        desc = "[T]erminal next"
    }, {
        "<leader>th",
        "<cmd>FloatermPrev<CR>",
        desc = "[T]erminal previous"
    }}
}}
