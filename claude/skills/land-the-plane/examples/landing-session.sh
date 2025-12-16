#!/usr/bin/env bash
#
# landing-session.sh
#
# Complete example of "landing the plane" - a clean session-ending protocol.
# This example demonstrates all seven steps with realistic command output.
#
# This is a demonstration script showing the complete landing workflow.
# In practice, you would run these commands interactively, not as a script.

set -euo pipefail

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Landing the Plane - Complete Example Session${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo ""

# ============================================================================
# STEP 1: File issues for any remaining work
# ============================================================================

echo -e "${YELLOW}STEP 1: File issues for any remaining work${NC}"
echo ""
echo "$ bd create \"Add integration tests for sync\" -t task -p 2 --json"
echo '{
  "id": "bd-156",
  "title": "Add integration tests for sync",
  "type": "task",
  "priority": "P2",
  "status": "todo",
  "created": "2025-12-15T14:32:10Z"
}'
echo ""

echo "$ bd create \"Fix race condition in WebSocket handler\" -t bug -p 1 --json"
echo '{
  "id": "bd-157",
  "title": "Fix race condition in WebSocket handler",
  "type": "bug",
  "priority": "P1",
  "status": "todo",
  "created": "2025-12-15T14:32:45Z"
}'
echo ""

echo "$ bd create \"Refactor authentication middleware\" -t improvement -p 3 --json"
echo '{
  "id": "bd-158",
  "title": "Refactor authentication middleware",
  "type": "improvement",
  "priority": "P3",
  "status": "todo",
  "created": "2025-12-15T14:33:12Z"
}'
echo ""

echo -e "${GREEN}✓ Filed 3 issues for remaining work${NC}"
echo ""
echo "─────────────────────────────────────────────────────────────────"
echo ""

# ============================================================================
# STEP 2: Run quality gates (if code changes were made)
# ============================================================================

echo -e "${YELLOW}STEP 2: Ensure all quality gates pass${NC}"
echo ""
echo "$ ./scripts/run-quality-gates.sh"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Running Quality Gates"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Detected: Node.js project"
echo ""
echo "▶ Running: Tests"
echo "  Command: npm test"
echo ""
echo "> api-server@1.0.0 test"
echo "> jest --coverage"
echo ""
echo " PASS  src/auth/auth.test.js"
echo " PASS  src/sync/sync.test.js"
echo " PASS  src/api/endpoints.test.js"
echo ""
echo "Test Suites: 3 passed, 3 total"
echo "Tests:       42 passed, 42 total"
echo "Coverage:    87.3%"
echo ""
echo "✓ Tests passed"
echo ""
echo "▶ Running: Linter"
echo "  Command: npm run lint"
echo ""
echo "> api-server@1.0.0 lint"
echo "> eslint ."
echo ""
echo "✓ Linter passed"
echo ""
echo "▶ Running: Type Check"
echo "  Command: tsc --noEmit"
echo ""
echo "✓ Type Check passed"
echo ""
echo "▶ Running: Build"
echo "  Command: npm run build"
echo ""
echo "> api-server@1.0.0 build"
echo "> tsc && vite build"
echo ""
echo "vite v5.0.8 building for production..."
echo "✓ 147 modules transformed."
echo "dist/index.js   245.3 kB"
echo "✓ built in 3.42s"
echo ""
echo "✓ Build passed"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Quality Gates Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Gates passed: 4"
echo "Gates failed: 0"
echo ""
echo "✓ All quality gates passed!"
echo ""

echo -e "${GREEN}✓ Quality gates passed - no P0 issues to file${NC}"
echo ""
echo "─────────────────────────────────────────────────────────────────"
echo ""

# ============================================================================
# STEP 3: Update issues - close finished work, update status
# ============================================================================

echo -e "${YELLOW}STEP 3: Update issues${NC}"
echo ""
echo "$ bd list --status in-progress"
echo "bd-142  Implement sync conflict resolution   in-progress  P2"
echo "bd-145  Add user profile API endpoints       in-progress  P2"
echo "bd-150  Update documentation for auth flow   in-progress  P3"
echo ""

echo "$ bd close bd-142 -m \"Implemented conflict resolution with merge strategy. Added unit tests. Coverage at 85%.\""
echo "✓ Closed bd-142"
echo ""

echo "$ bd close bd-145 -m \"Added all CRUD endpoints for user profiles. Integrated with auth middleware. Tests passing.\""
echo "✓ Closed bd-145"
echo ""

echo "$ bd comment bd-150 \"Updated auth flow docs in docs/auth.md. Still need to add sequence diagrams.\""
echo "✓ Added comment to bd-150"
echo ""

echo "$ bd update bd-150 --status todo -m \"Returning to backlog, diagrams needed later\""
echo "✓ Updated bd-150"
echo ""

echo -e "${GREEN}✓ Updated issue status for all session work${NC}"
echo ""
echo "─────────────────────────────────────────────────────────────────"
echo ""

# ============================================================================
# STEP 4: Sync the issue tracker carefully
# ============================================================================

echo -e "${YELLOW}STEP 4: Sync the issue tracker${NC}"
echo ""
echo "$ bd status"
echo "Local changes:"
echo "  Created: 3 issues (bd-156, bd-157, bd-158)"
echo "  Closed:  2 issues (bd-142, bd-145)"
echo "  Updated: 1 issue (bd-150)"
echo ""

echo "$ bd sync --dry-run"
echo "Sync preview:"
echo "  → Will push to remote: bd-156, bd-157, bd-158 (new)"
echo "  → Will push to remote: bd-142, bd-145 (closed)"
echo "  → Will push to remote: bd-150 (updated)"
echo "  ← Will pull from remote: bd-148 (updated by teammate)"
echo "  ⚠ Potential conflict: bd-150 (modified both locally and remotely)"
echo ""

echo "$ bd sync --verbose"
echo "Syncing with remote..."
echo "  ↑ Pushing bd-156... done"
echo "  ↑ Pushing bd-157... done"
echo "  ↑ Pushing bd-158... done"
echo "  ↑ Pushing bd-142 (closed)... done"
echo "  ↑ Pushing bd-145 (closed)... done"
echo "  ↓ Pulling bd-148... done"
echo "  ⚠ Conflict detected on bd-150"
echo ""

echo "$ bd show bd-150 --conflict"
echo "Issue: bd-150 - Update documentation for auth flow"
echo ""
echo "LOCAL version:"
echo "  Status: todo"
echo "  Comment: \"Updated auth flow docs in docs/auth.md. Still need sequence diagrams.\""
echo "  Modified: 2025-12-15 14:35:22"
echo ""
echo "REMOTE version:"
echo "  Status: in-progress"
echo "  Comment (by teammate): \"Taking over this issue, will add diagrams today.\""
echo "  Modified: 2025-12-15 14:40:15"
echo ""

echo "$ bd resolve bd-150 --keep-remote -m \"Teammate is actively working on this, using their version\""
echo "✓ Resolved bd-150 (kept remote version)"
echo ""

echo "$ bd sync --verify"
echo "Verifying sync consistency..."
echo "✓ Local and remote are in sync"
echo "✓ No pending changes"
echo "✓ No unresolved conflicts"
echo ""

echo -e "${GREEN}✓ Issue tracker synced successfully${NC}"
echo ""
echo "─────────────────────────────────────────────────────────────────"
echo ""

# ============================================================================
# STEP 5: Clean up git state
# ============================================================================

echo -e "${YELLOW}STEP 5: Clean up git state${NC}"
echo ""
echo "$ ./scripts/cleanup-git.sh"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Git Cleanup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Clearing git stashes"
echo ""
echo "Found 2 stash(es):"
echo "stash@{0}: WIP on feat/sync: abc1234 Add conflict resolution"
echo "stash@{1}: On main: def5678 Experiment with caching"
echo ""
echo "⚠ Warning: This will permanently delete all stashed changes!"
echo ""
echo "Clear all stashes? [y/N] y"
echo "✓ Cleared 2 stash(es)"
echo ""
echo "2. Pruning deleted remote branches"
echo ""
echo "Remote branches that will be pruned:"
echo " * [pruned] origin/feat/old-feature"
echo " * [pruned] origin/fix/deprecated-bug"
echo ""
echo "Prune deleted remote branches? [Y/n] y"
echo "✓ Pruned deleted remote branches"
echo ""
echo "4. Repository information"
echo ""
echo "Repository size: 45M"
echo "Loose objects: 234"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Git cleanup completed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo -e "${GREEN}✓ Git repository cleaned${NC}"
echo ""
echo "─────────────────────────────────────────────────────────────────"
echo ""

# ============================================================================
# STEP 6: Verify clean state
# ============================================================================

echo -e "${YELLOW}STEP 6: Verify clean state${NC}"
echo ""
echo "$ ./scripts/check-git-state.sh"
echo ""
echo "Checking git repository state..."
echo ""
echo "Checking for uncommitted changes... ✓ No uncommitted changes"
echo "Checking for staged changes... ✓ No staged changes"
echo "Checking for untracked files... ✓ No untracked files"
echo "Checking for unpushed commits... ✓ No unpushed commits"
echo "─────────────────────────────────────"
echo "✓ Repository is in a clean state"
echo ""
echo "All checks passed:"
echo "  • No uncommitted changes"
echo "  • No staged changes"
echo "  • No untracked files"
echo "  • No unpushed commits"
echo ""

echo -e "${GREEN}✓ Repository state is clean${NC}"
echo ""
echo "─────────────────────────────────────────────────────────────────"
echo ""

# ============================================================================
# STEP 7: Choose a follow-up issue for next session
# ============================================================================

echo -e "${YELLOW}STEP 7: Choose a follow-up issue for next session${NC}"
echo ""
echo "$ bd list --status todo -p 1,2 | head -5"
echo "bd-156  Add integration tests for sync           todo  P2"
echo "bd-157  Fix race condition in WebSocket handler  todo  P1"
echo "bd-135  Implement rate limiting for API          todo  P2"
echo "bd-128  Add caching layer for database queries   todo  P2"
echo ""

echo "Selected follow-up issue: bd-157 (highest priority)"
echo ""
echo "$ bd show bd-157"
echo "ID:       bd-157"
echo "Title:    Fix race condition in WebSocket handler"
echo "Type:     bug"
echo "Priority: P1"
echo "Status:   todo"
echo "Created:  2025-12-15T14:32:45Z"
echo ""
echo "Description:"
echo "  Race condition occurs when multiple clients connect simultaneously."
echo "  Need to add proper locking around connection state updates."
echo ""

echo -e "${GREEN}✓ Next session prompt prepared${NC}"
echo ""
echo "─────────────────────────────────────────────────────────────────"
echo ""

# ============================================================================
# SUMMARY
# ============================================================================

echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Landing Complete${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}✓ All 7 steps completed successfully${NC}"
echo ""
echo "Session summary:"
echo "  • Filed 3 new issues for remaining work"
echo "  • All quality gates passed (4/4)"
echo "  • Closed 2 completed issues, updated 1"
echo "  • Synced issue tracker (resolved 1 conflict)"
echo "  • Cleaned git state (removed 2 stashes, pruned 2 branches)"
echo "  • Verified clean repository state"
echo "  • Selected follow-up issue for next session"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${YELLOW}Continuation prompt for next session:${NC}"
echo ""
echo "Continue work on bd-157: Fix race condition in WebSocket handler."
echo "Race condition occurs when multiple clients connect simultaneously."
echo "Previous session: Implemented sync conflict resolution and user profile"
echo "API endpoints. All tests passing, code is in clean state."
echo "Next: Add proper locking around WebSocket connection state updates."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo -e "${GREEN}The plane has landed safely. ✈️${NC}"
echo ""
