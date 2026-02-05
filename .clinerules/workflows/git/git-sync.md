# Git Sync

**Workflow Name:** `git-sync` or `sync changes`  
**Description:** Pull remote changes and push local commits  
**Platform:** Cross-platform  
**Type:** Version Control

## Purpose

Synchronize local repository with remote:
- Pull latest changes from remote
- Push local commits to remote
- Handle merge conflicts if needed
- Keep branches up to date

## Prerequisites

- Git installed and configured
- Remote repository configured (origin)
- Network connection available
- Git credentials configured

## Command

```bash
# Pull latest changes
git pull origin <branch-name>

# Push local commits
git push origin <branch-name>
```

## What This Does

1. Fetches changes from remote repository
2. Merges remote changes into local branch
3. Pushes local commits to remote
4. Updates remote tracking branches

## Interactive Flow

When triggered, Cline will:

1. **Check Current Branch**
   ```bash
   git branch --show-current
   ```

2. **Check Status**
   ```bash
   git status
   ```

3. **Pull Changes**
   ```bash
   git pull origin <branch-name>
   ```

4. **Handle Conflicts** (if any)
   - Show conflicted files
   - Ask user to resolve conflicts
   - Stage resolved files
   - Complete merge

5. **Push Changes**
   ```bash
   git push origin <branch-name>
   ```

## Sync Strategies

### Strategy 1: Simple Sync (Default)
```bash
# Pull and push current branch
git pull origin $(git branch --show-current)
git push origin $(git branch --show-current)
```

### Strategy 2: Rebase Sync
```bash
# Pull with rebase to keep linear history
git pull --rebase origin $(git branch --show-current)
git push origin $(git branch --show-current)
```

### Strategy 3: Force Push (Dangerous)
```bash
# Force push (use with caution!)
git push --force origin $(git branch --show-current)
```

## When to Use

| Scenario | Use This Workflow? |
|----------|-------------------|
| Start of work day | ✅ Yes |
| After committing changes | ✅ Yes |
| Before switching branches | ✅ Yes |
| Sharing work with team | ✅ Yes |
| End of work session | ✅ Yes |
| During active development | ⚠️ Pull frequently |

## Troubleshooting

### Merge Conflicts
```bash
# View conflicted files
git status

# After resolving conflicts
git add .
git commit -m "fix: resolve merge conflicts"
git push origin <branch-name>
```

### Diverged Branches
```bash
# If local and remote have diverged
git pull --rebase origin <branch-name>

# Or merge instead of rebase
git pull origin <branch-name>
```

### Push Rejected
```bash
# Pull first, then push
git pull origin <branch-name>
git push origin <branch-name>

# If you're sure (dangerous!)
git push --force-with-lease origin <branch-name>
```

### Authentication Failed
```bash
# Check remote URL
git remote -v

# Update credentials
git config --global credential.helper store

# Or use SSH instead of HTTPS
git remote set-url origin git@github.com:user/repo.git
```

### Behind Remote
```bash
# Pull to catch up
git pull origin <branch-name>

# View what's different
git log HEAD..origin/<branch-name>
```

## Advanced Options

### Sync All Branches
```bash
# Fetch all branches
git fetch --all

# Pull current branch
git pull origin $(git branch --show-current)
```

### Sync with Prune
```bash
# Remove deleted remote branches
git fetch --prune
git pull origin $(git branch --show-current)
```

### Sync Specific Branch
```bash
# Sync a different branch
git fetch origin
git checkout <branch-name>
git pull origin <branch-name>
git push origin <branch-name>
```

### Dry Run
```bash
# See what would be pushed
git push --dry-run origin <branch-name>

# See what would be pulled
git fetch --dry-run origin
```

## Complete Sync Workflow

```bash
# 1. Check current status
git status

# 2. Commit any pending changes
git add .
git commit -m "feat: your changes"

# 3. Pull latest changes
git pull origin $(git branch --show-current)

# 4. Resolve conflicts if any
# (manual step)

# 5. Push your changes
git push origin $(git branch --show-current)

# 6. Verify sync
git status
```

## Related Workflows

- `git-commit` - Commit changes before syncing
- `git-branch` - Switch branches before syncing
- `git-status` - Check repository status

## Best Practices

1. **Commit Before Pull** - Always commit local changes first
2. **Pull Frequently** - Stay up to date with remote
3. **Resolve Conflicts Carefully** - Test after resolving
4. **Push After Testing** - Ensure code works before pushing
5. **Use Descriptive Messages** - Clear commit messages help team

## Safety Checks

Before syncing, Cline will verify:
- ✅ No uncommitted changes (or ask to commit)
- ✅ On correct branch
- ✅ Remote is accessible
- ✅ No unresolved conflicts

## Example Scenarios

### Scenario 1: Daily Sync
```bash
# Morning: Pull latest
git pull origin main

# Work on features...

# Evening: Push changes
git add .
git commit -m "feat: implement new feature"
git push origin main
```

### Scenario 2: Collaborative Work
```bash
# Before starting work
git pull origin develop

# After completing feature
git add .
git commit -m "feat: add user profile"
git pull origin develop  # Get any new changes
git push origin develop
```

### Scenario 3: Conflict Resolution
```bash
# Pull changes
git pull origin main
# CONFLICT detected

# Resolve conflicts in files
# Then:
git add .
git commit -m "fix: resolve merge conflicts"
git push origin main
```

## Notes

- Always pull before push to avoid conflicts
- Use `--rebase` for cleaner history
- Never force push to shared branches
- Communicate with team about force pushes
- Keep commits small for easier conflict resolution
