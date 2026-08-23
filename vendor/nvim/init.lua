-- ============================================================================
-- NEOVIM CONFIGURATION - MODULAR STRUCTURE
-- ============================================================================
-- Global settings
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

-- ============================================================================
-- WORK CONFIGURATION (OPTIONAL)
-- ============================================================================
-- Load work-specific configuration if it exists
local workconfig_path = os.getenv("HOME") .. "/.config/nvim/workconfig.lua"
local function file_exists(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    end
    return false
end

if file_exists(workconfig_path) then
    print("Loading work configuration...")
    WorkConfig = dofile(workconfig_path)

    -- Apply work-specific settings
    if WorkConfig and WorkConfig.settings then
        WorkConfig.settings()
    end

    -- Apply work-specific keymaps (after loading base config)
    if WorkConfig and WorkConfig.keymaps then
        vim.defer_fn(WorkConfig.keymaps, 100)
    end
end

-- Load configuration modules
require("config.notifications")
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Load VSCode-specific configuration if running in VSCode
if vim.g.vscode then
    require("config.vscode")
end

require("config.lazy")
