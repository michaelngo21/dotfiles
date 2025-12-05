# Dotfiles

My personal configuration files for Neovim (AstroNvim), Ghostty, and Zellij.

## Philosophy

This configuration prioritizes:
- **Vim-first navigation** - hjkl everywhere across all tools
- **Minimal bloat** - Only enable what's necessary
- **System integration** - Seamless clipboard and shell integration
- **Modal efficiency** - Separate contexts through modes rather than complex key combinations
- **Maintainability** - Clear documentation and organized structure

## What's Included

### Neovim (AstroNvim)
- **System clipboard integration** for seamless copy/paste
- **Custom scrolling behavior** - cursor moves freely without forced centering
- **Flash.nvim** for enhanced motion and navigation
- **Language support** via AstroCommunity packs:
  - Frontend: TypeScript, HTML/CSS, Tailwind
  - Backend: Python, Go, Lua
  - DevOps: Docker, YAML, JSON
- **Productivity utilities**: auto-save, todo-comments, diffview

### Ghostty
- **Automatic zellij launch** on terminal startup
- **Ayu Mirage theme** for comfortable viewing
- **macOS-optimized** keybindings and Option-as-Alt
- **Clean interface** with mouse hiding while typing

### Zellij
- **Complete vim-style keybinding overhaul** - hjkl navigation throughout
- **Modal operation** similar to tmux with vim muscle memory
- **Efficient pane/tab management** with intuitive shortcuts
- **Session persistence** and plugin support

For detailed information about all customizations and the reasoning behind them, see [CUSTOMIZATIONS.md](CUSTOMIZATIONS.md).

## Prerequisites

Before installing, ensure you have:

- **Neovim** (>= 0.9.0) - [Installation guide](https://github.com/neovim/neovim/wiki/Installing-Neovim)
- **AstroNvim** - [Installation guide](https://docs.astronvim.com/)
- **Ghostty** - [Installation guide](https://ghostty.org/)
- **Zellij** - [Installation guide](https://zellij.dev/documentation/installation.html)
- **Nerd Font** - Required for icons in Neovim and terminal
  - Recommended: [JetBrains Mono Nerd Font](https://www.nerdfonts.com/font-downloads)

## Installation

### First Time Setup

1. **Clone this repository:**
   ```bash
   git clone <your-repo-url> ~/personal-projects/dotfiles
   cd ~/personal-projects/dotfiles
   ```

2. **Run the install script:**
   ```bash
   ./install.sh
   ```

   The script will:
   - Check for existing configurations in `~/.config`
   - Offer to backup any existing configs
   - Create symlinks from the dotfiles repo to `~/.config`
   - Verify all symlinks were created successfully

3. **Restart your terminal** or run:
   ```bash
   # Reload zsh configuration
   source ~/.zshrc

   # Open nvim to let AstroNvim install plugins
   nvim
   ```

### Installing on a New Machine

1. Clone this repository to `~/personal-projects/dotfiles`
2. Install the prerequisites listed above
3. Run `./install.sh`
4. Restart your terminal

## Usage

### Making Changes

Since your configurations are symlinked to this repository, any changes you make in `~/.config` will automatically be reflected in the dotfiles repo.

**Workflow:**
```bash
# Make changes to your configs in ~/.config/nvim, ~/.config/ghostty, or ~/.config/zellij
# The changes are immediately visible in the dotfiles repo

cd ~/personal-projects/dotfiles
git status                          # See what changed
git diff                            # Review changes
git add .                           # Stage changes
git commit -m "Update keybindings"  # Commit with descriptive message
git push                            # Push to remote
```

### Updating Configurations

To pull updates from the remote repository:

```bash
cd ~/personal-projects/dotfiles
git pull
```

Changes will immediately be reflected in your `~/.config` since everything is symlinked.

### Reverting to Original Configs

If you want to revert to your original configurations:

```bash
# Remove symlinks
rm ~/.config/nvim ~/.config/ghostty ~/.config/zellij

# Restore backups (if you created them during install)
mv ~/.config/nvim.bak ~/.config/nvim
mv ~/.config/ghostty.bak ~/.config/ghostty
mv ~/.config/zellij.bak ~/.config/zellij
```

## Repository Structure

```
dotfiles/
├── README.md              # This file
├── CUSTOMIZATIONS.md      # Detailed documentation of all customizations
├── install.sh             # Symlink installation script
├── .gitignore             # Git ignore rules
├── nvim/                  # Neovim (AstroNvim) configuration
│   ├── init.lua
│   └── lua/
│       ├── community.lua  # AstroCommunity imports
│       ├── lazy_setup.lua # Lazy.nvim setup
│       ├── polish.lua     # Final customizations (disabled template)
│       └── plugins/       # Plugin configurations
│           ├── astrocore.lua   # CUSTOM: Core options and keymaps
│           ├── flash.lua       # CUSTOM: Enhanced navigation
│           └── ...             # Other templates (disabled)
├── ghostty/
│   └── config             # Ghostty terminal configuration
└── zellij/
    ├── config.kdl         # Zellij multiplexer configuration
    └── config.kdl.bak     # Backup of previous config
```

## Key Customizations

### Neovim
- `scrolloff = 0` - Cursor moves freely without centering
- `Ctrl-D`/`Ctrl-U` - Move cursor within viewport without scrolling
- `s`/`S` - Flash navigation for quick jumping
- System clipboard integration enabled

### Ghostty
- Auto-launches zellij on startup
- Option key acts as Alt for terminal keybindings
- Ayu Mirage theme
- Mouse hides while typing

### Zellij
- All keybindings rebuilt with vim-style hjkl navigation
- `Ctrl+P` - Pane mode
- `Ctrl+T` - Tab mode
- `Alt+hjkl` - Quick navigation without mode switching

See [CUSTOMIZATIONS.md](CUSTOMIZATIONS.md) for complete details and reasoning.

## Troubleshooting

### Neovim plugins not loading
```bash
# Open nvim and run:
:Lazy sync
# Then restart nvim
```

### Symlinks not working
```bash
# Verify symlinks exist:
ls -la ~/.config/nvim ~/.config/ghostty ~/.config/zellij

# Should show something like:
# ~/.config/nvim -> /Users/username/personal-projects/dotfiles/nvim
```

### Zellij not launching in Ghostty
Check that zellij is installed and in your PATH:
```bash
which zellij
```

### Icons not showing in Neovim
Ensure you have a Nerd Font installed and configured in your terminal.

## Contributing

This is a personal configuration repository, but feel free to:
- Fork it and adapt it to your needs
- Submit issues if you find problems
- Suggest improvements via pull requests

## License

MIT License - Feel free to use and modify as you wish.

## Acknowledgments

- [AstroNvim](https://astronvim.com/) - Amazing Neovim distribution
- [Ghostty](https://ghostty.org/) - Fast, native terminal emulator
- [Zellij](https://zellij.dev/) - Modern terminal multiplexer
- [AstroCommunity](https://github.com/AstroNvim/astrocommunity) - Curated plugin configurations
