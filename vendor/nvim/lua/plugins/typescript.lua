-- ============================================================================
-- TYPESCRIPT TOOLS
-- ============================================================================
-- Don't load TypeScript tools in VSCode - let VSCode handle TypeScript
if vim.g.vscode then
    return {}
end

return {{
    "pmizio/typescript-tools.nvim",
    dependencies = {"nvim-lua/plenary.nvim", "neovim/nvim-lspconfig"},
    opts = {
        settings = {
            jsx_close_tag = {
                enable = true
            }
        }
    }
}}
