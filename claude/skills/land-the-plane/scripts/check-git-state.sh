#!/usr/bin/env bash
#
# check-git-state.sh
#
# Validates that the git repository is in a clean state before ending a session.
# Checks for uncommitted changes, unpushed commits, and untracked files.
#
# Exit codes:
#   0 - Repository is clean
#   1 - Repository has uncommitted changes, unpushed commits, or untracked files
#
# Usage:
#   ./check-git-state.sh [--ignore-untracked]
#
# Options:
#   --ignore-untracked  Don't fail on untracked files (useful for .env, etc.)

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
IGNORE_UNTRACKED=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --ignore-untracked)
            IGNORE_UNTRACKED=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--ignore-untracked]"
            exit 1
            ;;
    esac
done

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}✗${NC} Not in a git repository"
    exit 1
fi

echo "Checking git repository state..."
echo ""

# Track whether any checks failed
CLEAN=true

# 1. Check for uncommitted changes (staged or unstaged)
echo -n "Checking for uncommitted changes... "
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    echo -e "${RED}✗ Found uncommitted changes${NC}"
    CLEAN=false
    echo ""
    echo "Modified files:"
    git status --short
    echo ""
else
    echo -e "${GREEN}✓ No uncommitted changes${NC}"
fi

# 2. Check for staged but uncommitted changes
echo -n "Checking for staged changes... "
if ! git diff-index --cached --quiet HEAD -- 2>/dev/null; then
    echo -e "${RED}✗ Found staged but uncommitted changes${NC}"
    CLEAN=false
    echo ""
    echo "Staged files:"
    git diff --cached --name-status
    echo ""
else
    echo -e "${GREEN}✓ No staged changes${NC}"
fi

# 3. Check for untracked files (unless --ignore-untracked is set)
if [ "$IGNORE_UNTRACKED" = false ]; then
    echo -n "Checking for untracked files... "
    UNTRACKED=$(git ls-files --others --exclude-standard)
    if [ -n "$UNTRACKED" ]; then
        echo -e "${YELLOW}⚠ Found untracked files${NC}"
        CLEAN=false
        echo ""
        echo "Untracked files:"
        echo "$UNTRACKED"
        echo ""
        echo "Tip: Use --ignore-untracked to skip this check if these files are expected (e.g., .env)"
    else
        echo -e "${GREEN}✓ No untracked files${NC}"
    fi
else
    echo -e "${YELLOW}⊘ Skipping untracked files check${NC}"
fi

# 4. Check for unpushed commits
echo -n "Checking for unpushed commits... "

# Get the current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Check if the branch has an upstream
if git rev-parse --abbrev-ref --symbolic-full-name @{u} > /dev/null 2>&1; then
    UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name @{u})

    # Check for unpushed commits
    UNPUSHED=$(git log "$UPSTREAM..HEAD" --oneline 2>/dev/null || true)

    if [ -n "$UNPUSHED" ]; then
        echo -e "${RED}✗ Found unpushed commits${NC}"
        CLEAN=false
        echo ""
        echo "Unpushed commits on $CURRENT_BRANCH:"
        git log "$UPSTREAM..HEAD" --oneline --decorate
        echo ""
    else
        echo -e "${GREEN}✓ No unpushed commits${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Branch '$CURRENT_BRANCH' has no upstream${NC}"
    CLEAN=false
    echo ""
    echo "This branch is not tracking a remote branch."
    echo "Push with: git push -u origin $CURRENT_BRANCH"
    echo ""
fi

# 5. Summary
echo "─────────────────────────────────────"
if [ "$CLEAN" = true ]; then
    echo -e "${GREEN}✓ Repository is in a clean state${NC}"
    echo ""
    echo "All checks passed:"
    echo "  • No uncommitted changes"
    echo "  • No staged changes"
    if [ "$IGNORE_UNTRACKED" = false ]; then
        echo "  • No untracked files"
    fi
    echo "  • No unpushed commits"
    echo ""
    exit 0
else
    echo -e "${RED}✗ Repository is NOT in a clean state${NC}"
    echo ""
    echo "Please resolve the issues above before landing the plane."
    echo ""
    echo "Common fixes:"
    echo "  • Commit changes: git add -A && git commit -m 'message'"
    echo "  • Push commits: git push"
    echo "  • Remove untracked files: git clean -fd (use with caution!)"
    echo "  • Stash changes: git stash push -m 'message'"
    echo ""
    exit 1
fi
