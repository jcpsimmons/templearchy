-- ============================================================================
-- KEYMAPS
-- ============================================================================
-- Clear search highlighting
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic navigation
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, {
    desc = "Go to previous [D]iagnostic message"
})
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, {
    desc = "Go to next [D]iagnostic message"
})
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, {
    desc = "Show diagnostic [E]rror messages"
})
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, {
    desc = "Open diagnostic [Q]uickfix list"
})

-- Debug LTeX startup
vim.keymap.set("n", "<leader>ls", function()
    print("🔧 Manually starting LTeX...")
    local bufnr = vim.api.nvim_get_current_buf()
    local filetype = vim.bo[bufnr].filetype
    local filename = vim.api.nvim_buf_get_name(bufnr)
    
    print("Buffer: " .. bufnr .. ", Filetype: " .. filetype .. ", File: " .. filename)
    
    if filetype == "markdown" or filetype == "text" or filetype == "typst" or filetype == "latex" then
        local clients_before = vim.lsp.get_clients({ bufnr = bufnr })
        print("Clients before start: " .. #clients_before)
        
        vim.cmd("LspStart ltex")
        
        -- Wait and check again
        vim.defer_fn(function()
            local clients_after = vim.lsp.get_clients({ bufnr = bufnr })
            print("Clients after start: " .. #clients_after)
            for _, client in ipairs(clients_after) do
                print("  - " .. client.name .. " (id: " .. client.id .. ")")
            end
        end, 1000)
        
        print("Started LTeX for filetype: " .. filetype)
    else
        print("Current filetype '" .. filetype .. "' not supported by LTeX")
    end
end, { desc = "Manually start LTeX" })

-- Check LSP log for errors
vim.keymap.set("n", "<leader>ll", function()
    vim.cmd("LspLog")
end, { desc = "Open LSP log" })

-- Terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", {
    desc = "Exit terminal mode"
})

-- Disable arrow keys (with helpful messages)
vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", {
    desc = "Move focus to the left window"
})
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", {
    desc = "Move focus to the right window"
})
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", {
    desc = "Move focus to the lower window"
})
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", {
    desc = "Move focus to the upper window"
})
