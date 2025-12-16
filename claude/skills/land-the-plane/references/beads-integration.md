# Beads Integration Reference

This document provides comprehensive guidance for working with the Beads issue tracking system during the "landing the plane" protocol.

## About Beads

Beads (`bd`) is a local-first issue tracking system that maintains a local database of issues and syncs with a remote backend. The local-first architecture means you can work with issues offline and sync when connected.

## Core Beads Commands

### Creating Issues

```bash
# Basic issue creation
bd create "Issue title"

# With type and priority
bd create "Issue title" -t task -p 2

# With JSON output (useful for capturing issue ID)
bd create "Issue title" -t task -p 2 --json

# With description
bd create "Issue title" -d "Detailed description here"

# With labels
bd create "Issue title" -l bug -l urgent
```

**Issue Types:**
- `task` - Standard task or work item
- `bug` - Bug or defect
- `feature` - New feature request
- `improvement` - Enhancement to existing functionality
- `question` - Question or discussion item

**Priority Levels:**
- `P0` - Critical, blocking work
- `P1` - High priority, should be done soon
- `P2` - Medium priority, normal work
- `P3` - Low priority, nice to have
- `P4` - Very low priority, backlog

### Updating Issues

```bash
# Update issue status
bd update bd-123 --status in-progress
bd update bd-123 --status done

# Update priority
bd update bd-123 -p 0

# Add a comment
bd comment bd-123 "Added tests, ready for review"

# Update multiple fields
bd update bd-123 --status done --priority 2 -l completed
```

**Issue Statuses:**
- `todo` - Not started
- `in-progress` - Currently being worked on
- `blocked` - Blocked by dependency
- `review` - Ready for review
- `done` - Completed

### Viewing Issues

```bash
# List all open issues
bd list

# List with specific status
bd list --status in-progress

# Show issue details
bd show bd-123

# List issues by priority
bd list -p 0  # Show all P0 issues

# Search issues
bd search "authentication"
```

### Closing Issues

```bash
# Close an issue
bd close bd-123

# Close with comment
bd close bd-123 -m "Fixed in commit abc123"

# Reopen an issue
bd reopen bd-123
```

## Syncing with Remote

The sync process is the most critical and delicate part of using Beads during the landing protocol.

### Basic Sync

```bash
# Sync local and remote databases
bd sync

# Sync with verbose output
bd sync --verbose

# Dry run (preview changes without applying)
bd sync --dry-run
```

### Sync Strategies

#### Strategy 1: Pull-First Sync (Recommended)

This strategy minimizes conflicts by pulling remote changes first:

```bash
# 1. Review local changes
bd status

# 2. Pull remote changes (if bd supports this)
bd pull

# 3. Review potential conflicts
bd diff

# 4. Resolve conflicts manually
bd resolve bd-123 --keep-local   # or --keep-remote

# 5. Push local changes
bd push
```

#### Strategy 2: Full Sync with Conflict Resolution

Let sync handle conflicts and review the results:

```bash
# 1. Check sync status
bd sync --dry-run

# 2. Perform sync with conflict strategy
bd sync --on-conflict ask  # Prompt for each conflict

# 3. Verify sync result
bd list --recently-synced
```

#### Strategy 3: Conservative Sync

When you're unsure, use this careful approach:

```bash
# 1. Backup local database
cp ~/.beads/db.sqlite ~/.beads/db.sqlite.backup

# 2. Sync with dry run first
bd sync --dry-run > sync-preview.txt

# 3. Review sync preview
cat sync-preview.txt

# 4. If safe, perform actual sync
bd sync

# 5. If something goes wrong, restore backup
# cp ~/.beads/db.sqlite.backup ~/.beads/db.sqlite
```

## Conflict Resolution

Conflicts occur when the same issue is modified both locally and remotely since the last sync.

### Types of Conflicts

1. **Status conflicts**: Issue status changed in both places
2. **Priority conflicts**: Priority changed differently
3. **Content conflicts**: Description or title modified in both
4. **Deletion conflicts**: Issue deleted locally but modified remotely (or vice versa)

### Resolution Approaches

#### Manual Conflict Resolution

```bash
# Show conflicts
bd conflicts

# For each conflict, decide which version to keep
bd resolve bd-123 --keep-local    # Keep local version
bd resolve bd-123 --keep-remote   # Keep remote version
bd resolve bd-123 --merge         # Attempt to merge both

# For complex conflicts, show both versions
bd show bd-123 --local
bd show bd-123 --remote

# Manually edit to combine both
bd edit bd-123
```

#### Automatic Conflict Resolution

```bash
# Use conflict resolution strategy
bd sync --on-conflict local     # Always prefer local
bd sync --on-conflict remote    # Always prefer remote
bd sync --on-conflict newer     # Prefer most recently modified
bd sync --on-conflict ask       # Ask for each conflict
```

### Conflict Resolution Best Practices

1. **Preserve information**: When in doubt, prefer merging over choosing one version
2. **Document decisions**: Add comments explaining why you resolved conflicts a certain way
3. **Don't skip conflicts**: Address every conflict explicitly rather than auto-resolving
4. **Verify after sync**: Review the final state of conflicted issues to ensure correctness

## Landing Protocol Integration

### Step 1: File Remaining Work Issues

```bash
# Create issues for incomplete work
bd create "Implement user profile page" -t task -p 2 --json
bd create "Fix race condition in sync logic" -t bug -p 1 --json
bd create "Add integration tests for API endpoints" -t task -p 2 --json

# Create issues for follow-up questions
bd create "Should we use Redis for caching?" -t question -p 2 --json

# Create technical debt issues
bd create "Refactor authentication middleware" -t improvement -p 3 --json
```

**Tips:**
- Use `--json` to capture the created issue ID for reference
- Set appropriate priority (P0 for blockers, P1 for important, P2 for normal)
- Include enough context in the title to be self-explanatory
- Add descriptions for complex issues

### Step 3: Update Issue Status

```bash
# Get list of issues worked on this session
bd list --status in-progress

# Close completed issues
bd close bd-142 -m "Implemented sync logic with conflict resolution"
bd close bd-138 -m "Added unit tests, coverage at 85%"

# Update status for partially completed issues
bd update bd-145 --status blocked -m "Waiting for API changes from backend team"
bd comment bd-147 "Completed initial implementation, needs integration tests"

# Update priorities if they changed
bd update bd-150 -p 1 -m "Increased priority due to customer escalation"
```

**Tips:**
- Close issues with descriptive messages explaining what was done
- Update status accurately (don't leave issues as in-progress if you stopped working on them)
- Add comments with context about current state
- Update priorities if you discovered new information during work

### Step 4: Sync Issue Tracker

This is the most critical and delicate step. Work methodically.

```bash
# 1. Check local state
bd status
bd list --recently-modified

# 2. Preview sync
bd sync --dry-run

# 3. Review what will be synced
# Look for:
# - Issues that will be created remotely
# - Issues that will be updated locally
# - Potential conflicts

# 4. Perform sync
bd sync --verbose

# 5. Handle conflicts if any
bd conflicts  # List any conflicts that occurred

# For each conflict:
bd show bd-123 --conflict  # Show both versions
bd resolve bd-123 --merge  # Resolve appropriately

# 6. Verify sync completed successfully
bd sync --verify

# 7. Check that remote is up to date
bd list --remote-status
```

**Conflict Scenarios:**

**Scenario A: Simple status conflict**
- Local: status=done
- Remote: status=in-progress
- Resolution: Keep local (done), add comment explaining completion

**Scenario B: Deleted vs modified**
- Local: deleted issue bd-150
- Remote: updated issue bd-150 with new comments
- Resolution: Un-delete locally, add comment about why deletion was considered, leave open

**Scenario C: Competing updates**
- Local: Changed priority to P1, added comment "Found critical bug"
- Remote: Changed status to done, added comment "Deployed to prod"
- Resolution: Merge both changes - status=done, priority=P1, both comments preserved

### Sync Troubleshooting

**Problem**: Sync hangs or times out
```bash
# Check network connectivity
bd ping

# Try syncing with smaller batches
bd sync --batch-size 10

# Check for corrupted local database
bd verify --local
```

**Problem**: Sync reports conflicts but none appear
```bash
# Clear sync cache and retry
bd sync --clear-cache

# Rebuild local index
bd reindex
```

**Problem**: Remote shows issues that aren't local
```bash
# Force pull to get remote state
bd pull --force

# Compare local and remote
bd diff --local-remote
```

## Common Workflows

### Workflow 1: End of Day

```bash
# 1. Create issues for incomplete work
bd create "Continue implementing feature X" -t task -p 2

# 2. Update all in-progress issues
for issue in $(bd list --status in-progress --format ids); do
    bd comment "$issue" "End of day status: [describe current state]"
done

# 3. Sync everything
bd sync

# 4. Verify clean state
bd status
```

### Workflow 2: Context Switch

```bash
# 1. Document current context
bd comment bd-current "Pausing work, current state: [description]"

# 2. Create issue for resumption
bd create "Resume work on bd-current: [next steps]" -t task -p 2

# 3. Update status
bd update bd-current --status blocked

# 4. Sync
bd sync
```

### Workflow 3: Session Handoff

```bash
# 1. File any remaining work
bd create "Remaining work for feature X" -t task -p 2

# 2. Close completed issues with detailed comments
bd close bd-142 -m "Completed: [what was done]. Tests: [status]. Docs: [status]"

# 3. Update in-progress issues with clear status
bd comment bd-145 "Handoff status: [what's done, what's next, any blockers]"

# 4. Sync twice to ensure consistency
bd sync
bd sync --verify

# 5. Capture follow-up issue
bd list --status todo -p 1 --format "Continue work on %id: %title. %description"
```

## Advanced Patterns

### Pattern 1: Branching Strategy Integration

Link issues to git branches:

```bash
# Create branch from issue
ISSUE_ID="bd-142"
BRANCH_NAME="feat/$ISSUE_ID-implement-feature"
git checkout -b "$BRANCH_NAME"

# Update issue with branch info
bd comment "$ISSUE_ID" "Working on branch: $BRANCH_NAME"

# When landing, close issue with commit reference
bd close "$ISSUE_ID" -m "Completed in commit $(git rev-parse HEAD)"
```

### Pattern 2: Dependency Tracking

Track issue dependencies:

```bash
# Mark issue as blocked by another
bd update bd-145 --blocked-by bd-142
bd update bd-145 --status blocked

# When blocker is resolved
bd close bd-142
bd update bd-145 --status todo --remove-blocker bd-142
```

### Pattern 3: Batch Issue Operations

Process multiple issues efficiently:

```bash
# Close all completed issues from this session
bd list --status in-progress --label "session-123" | \
  xargs -I {} bd close {} -m "Completed in session"

# Update priority for all bugs
bd list -t bug | xargs -I {} bd update {} -p 1
```

## Configuration

### Sync Settings

Configure sync behavior in `~/.beads/config.yaml`:

```yaml
sync:
  auto: false  # Don't auto-sync on every command
  conflict_resolution: ask  # Prompt for conflict resolution
  batch_size: 50  # Sync in batches of 50 issues

remote:
  url: https://beads.example.com
  timeout: 30  # 30 second timeout

local:
  database: ~/.beads/db.sqlite
  backup_on_sync: true  # Auto-backup before sync
```

### Useful Aliases

Add to `~/.bashrc` or `~/.zshrc`:

```bash
# Quick issue creation
alias bdc='bd create'
alias bdct='bd create -t task -p 2'
alias bdcb='bd create -t bug -p 1'

# Issue management
alias bdl='bd list'
alias bds='bd show'
alias bdu='bd update'

# Sync operations
alias bdsync='bd sync --verbose'
alias bdsync-dry='bd sync --dry-run'

# Landing specific
alias bd-land-status='bd list --status in-progress'
alias bd-land-sync='bd sync --verbose && bd sync --verify'
```

## Troubleshooting

### Issue: "Sync conflict cannot be resolved"

This happens when structural conflicts occur (e.g., issue deleted locally but has dependencies remotely).

**Solution:**
```bash
# Show full conflict details
bd conflicts --verbose

# Manually resolve by recreating
bd show bd-123 --remote > issue-123.txt
bd create --from-file issue-123.txt
bd resolve bd-123 --skip
```

### Issue: "Local database corrupted"

**Solution:**
```bash
# Verify database integrity
bd verify

# If corrupted, restore from backup
cp ~/.beads/db.sqlite.backup ~/.beads/db.sqlite

# Or rebuild from remote
bd reset --from-remote
```

### Issue: "Sync shows no changes but remote has updates"

**Solution:**
```bash
# Force refresh remote state
bd refresh --remote

# Clear sync metadata
bd sync --reset-metadata

# Try sync again
bd sync
```

## Best Practices Summary

✅ **DO:**
- Preview sync with `--dry-run` before actual sync
- Back up local database before major syncs
- Add descriptive comments when updating issues
- Resolve conflicts explicitly rather than auto-resolving
- Verify sync completed with `--verify` flag
- Document conflict resolution decisions
- Sync twice during landing to ensure consistency

❌ **DON'T:**
- Skip conflict resolution - address every conflict
- Auto-resolve conflicts without reviewing (avoid `--on-conflict local/remote`)
- Forget to sync after creating/updating issues
- Leave issues in incorrect states (status not matching reality)
- Delete issues without checking for dependencies
- Sync during ongoing work - sync at session boundaries

## Quick Reference Card

```bash
# Essential commands for landing
bd create "title" -t task -p 2         # File new issue
bd close bd-123 -m "message"           # Close completed
bd update bd-123 --status done         # Update status
bd comment bd-123 "message"            # Add comment
bd list --status in-progress           # Review current work
bd sync --dry-run                      # Preview sync
bd sync --verbose                      # Perform sync
bd conflicts                           # Show conflicts
bd resolve bd-123 --merge              # Resolve conflict
bd sync --verify                       # Verify sync succeeded
```

## Additional Resources

- Beads documentation: https://beads-docs.example.com (replace with actual docs)
- Conflict resolution guide: https://beads-docs.example.com/conflicts
- Sync strategies: https://beads-docs.example.com/sync

## Notes

This reference assumes Beads CLI version 1.x. Command syntax may vary for different versions. Check your version with `bd --version` and refer to the official documentation for version-specific details.

The sync strategies described here are general patterns. Your team may have specific conventions or automated tools that supplement these approaches. Adapt the patterns to fit your workflow.
