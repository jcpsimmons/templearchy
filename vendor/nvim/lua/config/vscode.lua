-- ============================================================================
-- VSCODE INTEGRATION
-- ============================================================================
-- Configuration specifically for when Neovim is running inside VSCode
if not vim.g.vscode then
    return
end

local vscode = require("vscode")

-- ============================================================================
-- VSCODE-SPECIFIC KEYMAPS
-- ============================================================================

-- Use VSCode's formatting instead of Neovim's
vim.keymap.set({"n", "x"}, "<leader>f", function()
    vscode.action("editor.action.formatDocument")
end, {
    desc = "[F]ormat document (VSCode)"
})

-- LSP-like actions using VSCode
vim.keymap.set("n", "gd", function()
    vscode.action("editor.action.revealDefinition")
end, {
    desc = "[G]oto [D]efinition (VSCode)"
})

vim.keymap.set("n", "gr", function()
    vscode.action("editor.action.goToReferences")
end, {
    desc = "[G]oto [R]eferences (VSCode)"
})

vim.keymap.set("n", "gI", function()
    vscode.action("editor.action.goToImplementation")
end, {
    desc = "[G]oto [I]mplementation (VSCode)"
})

vim.keymap.set("n", "<leader>rn", function()
    vscode.action("editor.action.rename")
end, {
    desc = "[R]e[n]ame (VSCode)"
})

vim.keymap.set("n", "<leader>ca", function()
    vscode.action("editor.action.quickFix")
end, {
    desc = "[C]ode [A]ction (VSCode)"
})

vim.keymap.set("n", "K", function()
    vscode.action("editor.action.showHover")
end, {
    desc = "Hover Documentation (VSCode)"
})

-- Diagnostics using VSCode
vim.keymap.set("n", "[d", function()
    vscode.action("editor.action.marker.prevInFiles")
end, {
    desc = "Go to previous [D]iagnostic (VSCode)"
})

vim.keymap.set("n", "]d", function()
    vscode.action("editor.action.marker.nextInFiles")
end, {
    desc = "Go to next [D]iagnostic (VSCode)"
})

vim.keymap.set("n", "<leader>e", function()
    vscode.action("editor.action.showHover")
end, {
    desc = "Show diagnostic [E]rror (VSCode)"
})

-- File operations using VSCode
vim.keymap.set("n", "<leader>sf", function()
    vscode.action("workbench.action.quickOpen")
end, {
    desc = "[S]earch [F]iles (VSCode)"
})

vim.keymap.set("n", "<leader>sg", function()
    vscode.action("workbench.action.findInFiles")
end, {
    desc = "[S]earch by [G]rep (VSCode)"
})

vim.keymap.set("n", "<leader>sw", function()
    vscode.action("workbench.action.findInFiles", {
        args = {
            query = vim.fn.expand("<cword>")
        }
    })
end, {
    desc = "[S]earch current [W]ord (VSCode)"
})

-- Symbol search using VSCode
vim.keymap.set("n", "<leader>ds", function()
    vscode.action("workbench.action.gotoSymbol")
end, {
    desc = "[D]ocument [S]ymbols (VSCode)"
})

vim.keymap.set("n", "<leader>ws", function()
    vscode.action("workbench.action.showAllSymbols")
end, {
    desc = "[W]orkspace [S]ymbols (VSCode)"
})

-- Comments using VSCode
vim.keymap.set({"n", "x"}, "<leader>c", function()
    vscode.action("editor.action.commentLine")
end, {
    desc = "[C]omment line (VSCode)"
})

-- Buffer navigation using VSCode tabs
vim.keymap.set("n", "<S-h>", function()
    vscode.action("workbench.action.previousEditor")
end, {
    desc = "Previous buffer/tab (VSCode)"
})

vim.keymap.set("n", "<S-l>", function()
    vscode.action("workbench.action.nextEditor")
end, {
    desc = "Next buffer/tab (VSCode)"
})

-- Quick actions
vim.keymap.set("n", "<leader>p", function()
    vscode.action("workbench.action.showCommands")
end, {
    desc = "Show command [P]alette (VSCode)"
})

-- ============================================================================
-- VSCODE-SPECIFIC SETTINGS
-- ============================================================================

-- Override vim.notify to use VSCode notifications
vim.notify = vscode.notify

-- Disable some Neovim UI elements that conflict with VSCode
vim.opt.laststatus = 0 -- Hide status line (VSCode has its own)
vim.opt.ruler = false -- Hide ruler
vim.opt.showcmd = false -- Hide command display

-- Keep relative line numbers (VSCode supports this)
vim.opt.relativenumber = true

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

-- Helper function to check if we're in VSCode
_G.is_vscode = function()
    return vim.g.vscode ~= nil
end

-- Helper function to call VSCode actions
_G.vscode_action = function(action, args)
    if vim.g.vscode then
        vscode.action(action, args)
    end
end
