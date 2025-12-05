# Dotfiles

Neovim (AstroNvim), Ghostty, and Zellij configs. Symlinked from `~/.config` for automatic tracking.

## Key Changes

### Neovim
- `scrolloff = 0` + remapped `Ctrl-D`/`Ctrl-U` for viewport-relative cursor movement
- Flash.nvim (`s` to jump)
- System clipboard enabled
- Language packs: TypeScript, Python, Go, Lua, Tailwind, Docker, YAML

### Ghostty
- Auto-launches zellij
- Option key = Alt
- Ayu Mirage theme

### Zellij
- Disabled startup tips

## Installation

```bash
git clone <repo-url> ~/personal-projects/dotfiles
cd ~/personal-projects/dotfiles
./install.sh
```

Backs up existing configs to `*.bak` and symlinks the repo to `~/.config`.

Requires: AstroNvim (which itself requires a few other pre-req packages), Ghostty, Zellij, Nerd Font

## Usage

Edit files in `~/.config` as usual. Changes auto-sync to repo.
