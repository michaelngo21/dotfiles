# Configuration Customizations

This document details all customizations made to the default configurations for Neovim (AstroNvim), Ghostty, and Zellij.

---

## Neovim (AstroNvim)

### Core Configuration

#### `init.lua` (Line 30)
**Customization:** `vim.opt.clipboard = "unnamedplus"`

**Reasoning:** Enables seamless system clipboard integration. All yank/paste operations automatically use the system clipboard, allowing easy copy/paste between Neovim and other applications without needing explicit register commands.

---

### Plugin Configurations

#### `lua/plugins/astrocore.lua` - **ENABLED**

**Status:** Enabled by commenting out the guard line (`if true then return {} end`)

**Customizations:**

1. **Scrolloff Setting** (Line 48)
   - `scrolloff = 0`
   - **Reasoning:** Allows cursor to move freely to the top and bottom of the screen without forced centering. Default AstroNvim sets this to 999, which keeps the cursor centered at all times. Setting to 0 provides more screen real estate and cursor freedom.

2. **Custom Half-Page Movement Keybindings** (Lines 78-91)
   - `<C-d>`: Move cursor down by half window height without scrolling viewport
   - `<C-u>`: Move cursor up by half window height without scrolling viewport
   - **Reasoning:** Changes the behavior of Ctrl-D and Ctrl-U from scrolling the entire viewport to moving just the cursor within the visible screen. This keeps the viewport static while the cursor jumps, providing a different navigation feel that complements the scrolloff=0 setting.

#### `lua/plugins/flash.lua` - **ENABLED**

**Status:** Fully enabled with custom navigation settings

**Customizations:**

1. **Disabled Char Mode**
   - `modes.char.enabled = false`
   - **Reasoning:** Preserves the default behavior of f/F/t/T keys for character finding. Flash.nvim can override these, but keeping them standard maintains muscle memory for basic Vim navigation.

2. **Custom Keybindings**
   - `s` (normal/visual/operator modes): Flash jump
   - `S` (normal/visual/operator modes): Flash Treesitter jump
   - `r` (operator mode): Remote Flash
   - **Reasoning:** Adds enhanced motion capabilities via Flash.nvim for quickly jumping to any visible location on screen. The `s` key is a good choice as the default substitute command can be replaced with `cl`. Treesitter integration (`S`) allows semantic code navigation.

#### `lua/community.lua` - **ENABLED**

**Imported Language Packs:**
- Lua (`pack.lua`)
- TypeScript/JavaScript (`pack.typescript`)
- JSON (`pack.json`)
- HTML/CSS (`pack.html-css`)
- Tailwind CSS (`pack.tailwind`)
- Python (`pack.python`)
- Docker (`pack.docker`)
- YAML (`pack.yaml`)
- Go (`pack.go`)

**Imported Utilities:**
- `auto-save.nvim` - Automatic file saving
- `todo-comments.nvim` - Highlight TODO/FIXME/NOTE comments
- `diffview.nvim` - Advanced git diff and merge tool integration

**Reasoning:** These community packs provide comprehensive language support and productivity utilities for modern full-stack development. The selection covers both frontend (TypeScript, Tailwind, HTML/CSS) and backend (Python, Go) development, along with DevOps tooling (Docker, YAML).

#### Template Files (Disabled)

The following plugin configuration files exist as templates but are currently disabled with guard clauses:
- `astrolsp.lua` - LSP configuration template
- `astroui.lua` - UI/theme configuration template
- `mason.lua` - Tool installer configuration template
- `none-ls.lua` - Linter/formatter configuration template
- `treesitter.lua` - Treesitter parser configuration template
- `user.lua` - Custom plugin configuration template
- `polish.lua` - Final customization hook template

**Reasoning:** These templates are kept for future reference but remain disabled to maintain a minimal configuration footprint. They can be enabled as needed when specific customizations are required.

---

## Ghostty

Configuration file: `config`

### Customizations:

1. **Startup Command**
   - `command = /bin/zsh -l -c "zellij"`
   - **Reasoning:** Automatically launches zellij (terminal multiplexer) on Ghostty startup. This provides immediate access to session management, panes, and tabs without manual invocation. The `-l` flag ensures zsh runs as a login shell, loading the full environment.

2. **Mouse Behavior**
   - `mouse-hide-while-typing = true`
   - **Reasoning:** Hides the mouse cursor while typing to reduce visual clutter and maintain focus on the text. The cursor reappears on mouse movement.

3. **Copy Behavior**
   - `copy-on-select = false`
   - **Reasoning:** Requires explicit copy action (Cmd+C) rather than automatically copying selected text. This prevents accidental clipboard pollution and provides more control over copy operations.

4. **Text Styling**
   - `bold-is-bright = true`
   - **Reasoning:** Renders bold text in brighter colors, improving visual distinction in syntax highlighting and terminal output. This is especially helpful for distinguishing emphasis in shell prompts and colored output.

5. **Theme**
   - `theme = Ayu Mirage`
   - **Reasoning:** Uses the Ayu Mirage dark theme for comfortable long-term viewing. Ayu Mirage offers good contrast without being harsh, with a slightly purple-tinted dark background that's easy on the eyes.

6. **macOS-Specific Settings**
   - `macos-option-as-alt = true`
   - **Reasoning:** Makes the Option key function as Alt for terminal keybindings (e.g., Alt+arrow for word movement in bash/zsh). macOS typically uses Option for special characters, but terminal users often prefer Alt functionality for shell navigation.

7. **Custom Keybindings**
   - `keybind = alt+left=unbind` - Unbind Alt+Left
   - `keybind = alt+right=unbind` - Unbind Alt+Right
   - **Reasoning:** Prevents conflicts with macOS system shortcuts and allows these key combinations to pass through to the shell or zellij for word-based navigation.

   - `keybind = shift+enter=text:\n`
   - **Reasoning:** Makes Shift+Enter send a literal newline character, useful for multiline input in shells or REPLs without executing the command immediately.

---

## Zellij

Configuration file: `config.kdl`

### Core Philosophy

This configuration represents a complete keybinding overhaul with `clear-defaults=true`, replacing all default zellij keybindings with a vim-centric, modal navigation system.

**Reasoning:** The default zellij keybindings don't align well with vim muscle memory. By clearing defaults and rebuilding with vim-style navigation (hjkl), the terminal multiplexer becomes a natural extension of the vim editing environment. This creates a consistent navigation experience across both the editor and terminal sessions.

### Major Customizations:

#### 1. Modal Navigation System
- **Pane Mode** (`Ctrl+P`): Vim-style pane navigation and management
- **Tab Mode** (`Ctrl+T`): Tab navigation with hjkl and numbered access
- **Resize Mode** (`Ctrl+N`): Resize panes using hjkl movements
- **Move Mode** (`Ctrl+H`): Move panes with hjkl directions
- **Scroll Mode** (`Ctrl+S`): Scrollback with vim keybindings
- **Session Mode** (`Ctrl+O`): Plugin launcher and session management
- **TMux Mode** (`Ctrl+B`): TMux-compatible keybindings for familiarity

**Reasoning:** Modal operation separates concerns - you're either navigating, resizing, or scrolling, not trying to remember complex modifier combinations. Each mode provides context-specific vim-style commands.

#### 2. Global Shortcuts
- `Alt+hjkl`: Quick navigation across panes/tabs without entering a mode
- `Alt+±=`: Resize operations
- `Alt+[]`: Swap layouts
- `Ctrl+Q`: Quit
- `Ctrl+G`: Toggle locked mode

**Reasoning:** Frequently-used operations should be accessible without mode switching. Alt+hjkl provides instant pane navigation, similar to tmux prefix-free navigation or vim window commands.

#### 3. Vim-Style Movement
Every mode that involves directional operations uses hjkl:
- `h` = left
- `j` = down
- `k` = up
- `l` = right

**Reasoning:** Consistency with vim navigation eliminates mental context switching. If you know vim, you know how to navigate zellij.

#### 4. Plugin Configuration
Standard zellij plugins are enabled:
- Status bar, tab bar, compact bar for UI
- Session manager for session persistence
- File picker (strider) for file navigation
- About, configuration, and plugin manager for maintenance

**Reasoning:** These plugins provide essential zellij functionality without bloat. The defaults are well-designed and don't need customization for most use cases.

### Commented/Disabled Settings
- Theme customization (using defaults)
- Custom shell configuration (using system default)
- Scroll buffer limits (using defaults)
- Simplified UI (keeping standard UI)

**Reasoning:** The default settings for these options are sensible. Customization was focused on keybindings where defaults conflicted with vim muscle memory, not on aesthetic changes for their own sake.

---

## Summary

These customizations reflect a consistent philosophy:

1. **Vim-First:** Maximize vim-style navigation across all tools (hjkl everywhere)
2. **Minimal Bloat:** Only enable/customize what's necessary; keep defaults when they work well
3. **System Integration:** Clipboard sharing, shell integration, and native macOS behaviors
4. **Modal Efficiency:** Separate contexts (editing, navigating, resizing) through modes rather than complex key combos
5. **Documentation:** Keep disabled template files for future reference without cluttering active config

The result is a highly personalized but maintainable development environment that prioritizes keyboard efficiency and muscle memory consistency.
