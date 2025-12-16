#!/usr/bin/env bash
#
# cleanup-git.sh
#
# Performs safe git cleanup operations to maintain repository hygiene.
# Clears stashes, prunes remote branches, and optionally removes merged local branches.
#
# Exit codes:
#   0 - Cleanup completed successfully
#   1 - Cleanup failed or was cancelled
#
# Usage:
#   ./cleanup-git.sh [--no-confirm] [--prune-merged]
#
# Options:
#   --no-confirm     Skip confirmation prompts (use with caution!)
#   --prune-merged   Also remove local branches that have been merged

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NO_CONFIRM=false
PRUNE_MERGED=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-confirm)
            NO_CONFIRM=true
            shift
            ;;
        --prune-merged)
            PRUNE_MERGED=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--no-confirm] [--prune-merged]"
            exit 1
            ;;
    esac
done

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}✗${NC} Not in a git repository"
    exit 1
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Git Cleanup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Helper function for confirmation
confirm() {
    local prompt=$1
    local default=${2:-n}

    if [ "$NO_CONFIRM" = true ]; then
        return 0
    fi

    if [ "$default" = "y" ]; then
        read -p "$prompt [Y/n] " -n 1 -r
    else
        read -p "$prompt [y/N] " -n 1 -r
    fi
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY && "$default" = "y" ]]; then
        return 0
    else
        return 1
    fi
}

# 1. Clear git stashes
echo -e "${YELLOW}1. Clearing git stashes${NC}"
echo ""

STASH_COUNT=$(git stash list | wc -l | tr -d ' ')

if [ "$STASH_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✓ No stashes to clear${NC}"
    echo ""
else
    echo "Found $STASH_COUNT stash(es):"
    git stash list
    echo ""
    echo -e "${YELLOW}⚠ Warning: This will permanently delete all stashed changes!${NC}"
    echo ""

    if confirm "Clear all stashes?" "n"; then
        git stash clear
        echo -e "${GREEN}✓ Cleared $STASH_COUNT stash(es)${NC}"
        echo ""
    else
        echo -e "${YELLOW}⊘ Skipped stash clearing${NC}"
        echo ""
    fi
fi

# 2. Prune remote branches
echo -e "${YELLOW}2. Pruning deleted remote branches${NC}"
echo ""

# Get list of remote branches that will be pruned
PRUNE_LIST=$(git remote prune origin --dry-run 2>&1 || true)

if echo "$PRUNE_LIST" | grep -q "prune"; then
    echo "Remote branches that will be pruned:"
    echo "$PRUNE_LIST"
    echo ""

    if confirm "Prune deleted remote branches?" "y"; then
        git remote prune origin
        echo -e "${GREEN}✓ Pruned deleted remote branches${NC}"
        echo ""
    else
        echo -e "${YELLOW}⊘ Skipped remote pruning${NC}"
        echo ""
    fi
else
    echo -e "${GREEN}✓ No remote branches to prune${NC}"
    echo ""
fi

# 3. Remove merged local branches (if --prune-merged flag is set)
if [ "$PRUNE_MERGED" = true ]; then
    echo -e "${YELLOW}3. Removing merged local branches${NC}"
    echo ""

    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

    # Find merged branches (excluding current branch and default branch)
    MERGED_BRANCHES=$(git branch --merged "$DEFAULT_BRANCH" | grep -v "^\*" | grep -v "^  $DEFAULT_BRANCH$" | grep -v "^  master$" | sed 's/^  //' || true)

    if [ -n "$MERGED_BRANCHES" ]; then
        echo "Merged branches that can be removed:"
        echo "$MERGED_BRANCHES"
        echo ""
        echo "Current branch: $CURRENT_BRANCH (will not be removed)"
        echo "Default branch: $DEFAULT_BRANCH (will not be removed)"
        echo ""

        if confirm "Remove these merged branches?" "n"; then
            echo "$MERGED_BRANCHES" | while read -r branch; do
                if [ -n "$branch" ]; then
                    git branch -d "$branch"
                    echo -e "${GREEN}✓ Removed branch: $branch${NC}"
                fi
            done
            echo ""
        else
            echo -e "${YELLOW}⊘ Skipped removing merged branches${NC}"
            echo ""
        fi
    else
        echo -e "${GREEN}✓ No merged branches to remove${NC}"
        echo ""
    fi
fi

# 4. Show repository size (optional info)
echo -e "${YELLOW}4. Repository information${NC}"
echo ""

REPO_SIZE=$(du -sh .git 2>/dev/null | cut -f1 || echo "unknown")
echo "Repository size: $REPO_SIZE"

# Count objects
OBJECT_COUNT=$(git count-objects -v 2>/dev/null | grep '^count:' | awk '{print $2}' || echo "unknown")
echo "Loose objects: $OBJECT_COUNT"

echo ""

# 5. Suggest git gc if repository is large
if [ "$OBJECT_COUNT" != "unknown" ] && [ "$OBJECT_COUNT" -gt 1000 ]; then
    echo -e "${YELLOW}💡 Tip: Repository has many loose objects. Consider running 'git gc' to optimize.${NC}"
    echo ""

    if confirm "Run git gc to optimize the repository?" "n"; then
        echo "Running git gc..."
        git gc --auto
        echo -e "${GREEN}✓ Repository optimized${NC}"
        echo ""
    fi
fi

# Summary
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Git cleanup completed${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

exit 0
