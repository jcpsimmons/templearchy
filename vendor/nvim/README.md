# Neovim Configuration Structure

This is a modular Neovim configuration organized for maintainability and clarity. **It works seamlessly in both terminal and VSCode environments.**

## 🚀 Dual-Mode Support

This configuration automatically detects whether it's running in:

- **Terminal Mode**: Full-featured Neovim with LSP, completion, formatting, etc.
- **VSCode Mode**: Optimized for VSCode Neovim extension with VSCode handling LSP/formatting

### VSCode Integration

When running in VSCode via the [VSCode Neovim extension](https://marketplace.visualstudio.com/items?itemName=asvetliakov.vscode-neovim):

- ✅ **Keeps**: Telescope (file picker), Which-key, text objects, treesitter (for text objects), editing plugins, NeoTree file explorer
- ❌ **Disables**: LSP servers, completion, formatters, dashboard, treesitter highlighting
- 🔄 **Defers**: Formatting, linting, and language features to VSCode

**Key Design Principle**: VSCode handles all language intelligence (LSP, completion, diagnostics, formatting) while Neovim provides superior text editing capabilities (motions, text objects, modal editing).

## Structure

```
~/.config/nvim/
├── init.lua                 # Main entry point
├── init_backup.lua          # Backup of original monolithic config
├── vscode-settings.json     # Recommended VSCode settings
├── lazy-lock.json           # Lazy.nvim lock file
└── lua/
    ├── config/              # Core configuration modules
    │   ├── autocmds.lua     # Autocommands
    │   ├── keymaps.lua      # Key mappings
    │   ├── lazy.lua         # Lazy.nvim setup
    │   ├── options.lua      # Vim options
    │   └── vscode.lua       # VSCode-specific configuration
    └── plugins/             # Plugin configurations
        ├── ai.lua           # AI & productivity (Copilot)
        ├── autoclose.lua    # Auto-close brackets
        ├── completion.lua   # nvim-cmp completion (terminal only)
        ├── dashboard.lua    # Alpha dashboard (terminal only)
        ├── editing.lua      # Editing plugins (Comment.nvim)
        ├── essential.lua    # Essential plugins (vim-sleuth)
        ├── explorer.lua     # File explorer (terminal only)
        ├── formatting.lua   # Code formatting (terminal only)
        ├── git.lua          # Git integration (Blamer)
        ├── lsp.lua          # LSP configuration (terminal only)
        ├── terminal.lua     # Terminal integration (Floaterm)
        ├── themes.lua       # Themes & appearance
        ├── transparency.lua # Transparent background
        ├── treesitter.lua   # Syntax highlighting
        ├── typescript.lua   # TypeScript tools
        ├── ui.lua           # UI plugins (Which-key, Telescope)
        └── writing.lua      # Writing plugins (Goyo, Pencil)
```

## Plugin Categories

### Core Configuration

- **options.lua**: Global vim settings, UI options, editor behavior
- **keymaps.lua**: Key mappings for navigation, diagnostics, and general use
- **autocmds.lua**: Autocommands for highlighting yanked text and TypeScript formatting
- **lazy.lua**: Lazy.nvim setup and plugin loading configuration

### Plugin Modules

- **essential.lua**: Essential plugins like vim-sleuth for auto-indentation
- **writing.lua**: Writing and focus plugins (Goyo, Pencil, Stay-centered)
- **terminal.lua**: Terminal integration with Floaterm
- **editing.lua**: Editing enhancements (Comment.nvim)
- **ui.lua**: UI and navigation (Which-key, Telescope, Lualine)
- **lsp.lua**: LSP configuration with Mason and multiple language servers
- **formatting.lua**: Code formatting with Conform
- **completion.lua**: Auto-completion with nvim-cmp and LuaSnip
- **themes.lua**: Colorschemes, theme-related plugins, and appearance
- **treesitter.lua**: Syntax highlighting and code parsing
- **dashboard.lua**: Alpha dashboard with custom logo and quotes
- **ai.lua**: AI-powered productivity tools (GitHub Copilot)
- **transparency.lua**: Transparent background support
- **explorer.lua**: File explorer (Neo-tree)
- **typescript.lua**: TypeScript-specific tools
- **autoclose.lua**: Auto-close brackets and quotes
- **git.lua**: Git integration (Blamer)

## Features

- **Modular design**: Each plugin category is in its own file
- **Lazy loading**: Plugins are loaded only when needed
- **Work configuration**: Supports additional work-specific plugins via `workconfig.lua`
- **Comprehensive LSP**: Support for multiple languages including TypeScript, Lua, Tailwind, etc.
- **Writing mode**: Distraction-free writing with Goyo and Pencil
- **Modern UI**: Telescope for fuzzy finding, Which-key for keybinding help

## Usage

The configuration will automatically load all plugin modules. To add new plugins:

1. Add the plugin to the appropriate category file in `lua/plugins/`
2. If creating a new category, create a new file in `lua/plugins/` and return a table of plugin specs
3. The plugin will be automatically discovered by lazy.nvim

## 🛠️ VSCode Setup

### 1. Install VSCode Neovim Extension

Install the [VSCode Neovim extension](https://marketplace.visualstudio.com/items?itemName=asvetliakov.vscode-neovim):

```bash
code --install-extension asvetliakov.vscode-neovim
```

### 2. Configure VSCode Settings

Copy the settings from `vscode-settings.json` to your VSCode `settings.json`:

**Key settings:**

- Path to Neovim executable
- Control key pass-through configuration
- Editor settings optimized for Neovim
- Formatting and linting delegation to VSCode

### 3. VSCode Keymaps

In VSCode with Neovim, these keymaps automatically use VSCode's native features:

| Keymap       | VSCode Action                    | Description      |
| ------------ | -------------------------------- | ---------------- |
| `<leader>f`  | `editor.action.formatDocument`   | Format document  |
| `gd`         | `editor.action.revealDefinition` | Go to definition |
| `gr`         | `editor.action.goToReferences`   | Go to references |
| `<leader>ca` | `editor.action.quickFix`         | Code actions     |
| `<leader>rn` | `editor.action.rename`           | Rename symbol    |
| `K`          | `editor.action.showHover`        | Show hover info  |
| `<leader>sw` | `workbench.action.findInFiles`   | Search word in files |

**Note**: `<leader>sf` (file search) and `<leader>sg` (grep search) use Telescope for enhanced functionality, while other keymaps defer to VSCode.

### 4. What You Keep in VSCode

- ✅ **Telescope**: File picker and search
- ✅ **NeoTree**: File explorer accessible via `\` (backslash)
- ✅ **Which-key**: Keybinding help
- ✅ **Text Objects**: Enhanced text manipulation
- ✅ **Terminal**: Floaterm integration
- ✅ **Writing Mode**: Goyo and Pencil for distraction-free writing
- ✅ **Editing**: Comment.nvim and surround operations

### 5. Troubleshooting VSCode

If you encounter issues:

1. **Check Neovim path**: Ensure `vscode-neovim.neovimExecutablePaths` points to your Neovim installation
2. **Enable logging**: Set VSCode Neovim output to "Debug" level
3. **Disable conflicting extensions**: Temporarily disable other Vim extensions
4. **Test with clean config**: Use `vscode-neovim.neovimClean` setting to test

## Author

Configuration by jcpsimmons
