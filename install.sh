#!/bin/bash

# Dotfiles Installation Script
# This script creates symlinks from the dotfiles repository to ~/.config

set -e  # Exit on error

DOTFILES_DIR="$HOME/personal-projects/dotfiles"
CONFIG_DIR="$HOME/.config"

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "=========================================="
echo "  Dotfiles Installation"
echo "=========================================="
echo ""

# Check if dotfiles directory exists
if [ ! -d "$DOTFILES_DIR" ]; then
    echo -e "${RED}Error: Dotfiles directory not found at $DOTFILES_DIR${NC}"
    exit 1
fi

# Create ~/.config if it doesn't exist
if [ ! -d "$CONFIG_DIR" ]; then
    echo -e "${YELLOW}Creating $CONFIG_DIR directory...${NC}"
    mkdir -p "$CONFIG_DIR"
fi

# Function to backup and symlink a config
backup_and_link() {
    local config_name=$1
    local source_path="$DOTFILES_DIR/.config/$config_name"
    local target_path="$CONFIG_DIR/$config_name"
    local backup_path="$CONFIG_DIR/${config_name}.bak"

    echo ""
    echo "Processing $config_name..."

    # Check if source exists
    if [ ! -d "$source_path" ]; then
        echo -e "${RED}  Error: Source directory not found: $source_path${NC}"
        return 1
    fi

    # Check if target exists and is not a symlink
    if [ -e "$target_path" ] && [ ! -L "$target_path" ]; then
        echo -e "${YELLOW}  Existing config found at $target_path${NC}"
        read -p "  Create backup? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Remove old backup if it exists
            if [ -e "$backup_path" ]; then
                echo -e "${YELLOW}  Removing old backup at $backup_path${NC}"
                rm -rf "$backup_path"
            fi
            echo -e "${GREEN}  Backing up to $backup_path${NC}"
            mv "$target_path" "$backup_path"
        else
            echo -e "${RED}  Skipping $config_name (user declined backup)${NC}"
            return 0
        fi
    fi

    # Remove target if it's a broken symlink
    if [ -L "$target_path" ] && [ ! -e "$target_path" ]; then
        echo -e "${YELLOW}  Removing broken symlink at $target_path${NC}"
        rm "$target_path"
    fi

    # Remove target if it's already a symlink to our dotfiles
    if [ -L "$target_path" ]; then
        existing_link=$(readlink "$target_path")
        if [ "$existing_link" = "$source_path" ]; then
            echo -e "${GREEN}  Symlink already exists and is correct${NC}"
            return 0
        else
            echo -e "${YELLOW}  Removing existing symlink to $existing_link${NC}"
            rm "$target_path"
        fi
    fi

    # Create symlink
    echo -e "${GREEN}  Creating symlink: $target_path -> $source_path${NC}"
    ln -s "$source_path" "$target_path"
}

# Process each configuration
echo ""
echo "Starting installation..."

backup_and_link "nvim"
backup_and_link "ghostty"
backup_and_link "zellij"

# Verify symlinks
echo ""
echo "=========================================="
echo "  Verification"
echo "=========================================="
echo ""

verify_link() {
    local config_name=$1
    local target_path="$CONFIG_DIR/$config_name"

    if [ -L "$target_path" ]; then
        local link_target=$(readlink "$target_path")
        echo -e "${GREEN}✓${NC} $config_name -> $link_target"
    else
        echo -e "${RED}✗${NC} $config_name (not a symlink or doesn't exist)"
    fi
}

verify_link "nvim"
verify_link "ghostty"
verify_link "zellij"

echo ""
echo "=========================================="
echo -e "${GREEN}Installation complete!${NC}"
echo "=========================================="
echo ""
echo "Your configurations are now symlinked to the dotfiles repository."
echo "Any changes you make in ~/.config will automatically be reflected in the repo."
echo ""
echo "To push your changes to git:"
echo "  cd $DOTFILES_DIR"
echo "  git add ."
echo "  git commit -m \"Update configurations\""
echo "  git push"
echo ""
