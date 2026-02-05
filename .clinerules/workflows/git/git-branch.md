# Git Branch

**Workflow Name:** `git-branch` or `create branch` or `switch branch`  
**Description:** Create, switch, and manage Git branches  
**Platform:** Cross-platform  
**Type:** Version Control

## Purpose

Manage Git branches for:
- Creating feature branches
- Switching between branches
- Listing available branches
- Deleting old branches
- Following branching strategies

## Prerequisites

- Git installed and configured
- Working directory is a Git repository
- Understanding of branch naming conventions

## Command

```bash
# Create and switch to new branch
git checkout -b <branch-name>

# Switch to existing branch
git checkout <branch-name>

# List all branches
git branch -a
```

## What This Does

1. Creates a new branch from current HEAD
2. Switches working directory to the branch
3. Allows isolated development
4. Enables parallel feature development

## Interactive Flow

When triggered, Cline will:

1. **Check Current Branch**
   ```bash
   git branch --show-current
   ```

2. **Ask User Intent**
   - Create new branch?
   - Switch to existing branch?
   - List branches?
   - Delete branch?

3. **Execute Action**
   ```bash
   # Create new branch
   git checkout -b <branch-name>
   
   # Or switch to existing
   git checkout <branch-name>
   ```

4. **Verify**
   ```bash
   git status
   ```

## Branch Naming Conventions

Follow consistent naming patterns:

| Type | Pattern | Example |
|------|---------|---------|
| Feature | `feature/<description>` | `feature/user-authentication` |
| Bug Fix | `fix/<description>` | `fix/login-crash` |
| Hotfix | `hotfix/<description>` | `hotfix/security-patch` |
| Release | `release/<version>` | `release/v1.2.0` |
| Development | `develop` or `dev` | `develop` |
| Main | `main` or `master` | `main` |

## When to Use

| Scenario | Use This Workflow? |
|----------|-------------------|
| Starting new feature | ✅ Yes |
| Fixing a bug | ✅ Yes |
| Experimenting | ✅ Yes |
| Code review | ✅ Yes |
| Switching context | ✅ Yes |
| Hotfix needed | ✅ Yes |

## Common Operations

### Create New Branch
```bash
# From current branch
git checkout -b feature/new-feature

# From specific branch
git checkout -b feature/new-feature main
```

### Switch Branch
```bash
# Switch to existing branch
git checkout develop

# Switch and create if doesn't exist
git checkout -b feature/my-feature
```

### List Branches
```bash
# Local branches
git branch

# All branches (including remote)
git branch -a

# Remote branches only
git branch -r
```

### Delete Branch
```bash
# Delete local branch (safe)
git branch -d feature/old-feature

# Force delete local branch
git branch -D feature/old-feature

# Delete remote branch
git push origin --delete feature/old-feature
```

### Rename Branch
```bash
# Rename current branch
git branch -m new-branch-name

# Rename specific branch
git branch -m old-name new-name
```

## Troubleshooting

### Uncommitted Changes
```bash
# Stash changes before switching
git stash
git checkout <branch-name>
git stash pop
```

### Branch Already Exists
```bash
# Switch to existing branch instead
git checkout <branch-name>

# Or delete and recreate
git branch -D <branch-name>
git checkout -b <branch-name>
```

### Branch Not Found
```bash
# Fetch from remote
git fetch origin

# List remote branches
git branch -r

# Create from remote
git checkout -b <branch-name> origin/<branch-name>
```

### Can't Delete Current Branch
```bash
# Switch to different branch first
git checkout main
git branch -d <branch-to-delete>
```

### Diverged from Remote
```bash
# Reset to remote state
git fetch origin
git reset --hard origin/<branch-name>
```

## Advanced Options

### Create Branch from Specific Commit
```bash
git checkout -b <branch-name> <commit-hash>
```

### Create Branch from Tag
```bash
git checkout -b <branch-name> <tag-name>
```

### Track Remote Branch
```bash
# Set upstream for current branch
git branch --set-upstream-to=origin/<branch-name>

# Or when pushing
git push -u origin <branch-name>
```

### Compare Branches
```bash
# See commits in branch1 not in branch2
git log branch1..branch2

# See file differences
git diff branch1..branch2
```

### Merge Branch
```bash
# Merge feature into current branch
git merge feature/my-feature

# Merge with no fast-forward
git merge --no-ff feature/my-feature
```

## Branch Workflows

### Feature Branch Workflow
```bash
# 1. Create feature branch from develop
git checkout develop
git pull origin develop
git checkout -b feature/new-feature

# 2. Work on feature
git add .
git commit -m "feat: implement new feature"

# 3. Push feature branch
git push -u origin feature/new-feature

# 4. Create pull request (on GitHub/GitLab)

# 5. After merge, delete branch
git checkout develop
git pull origin develop
git branch -d feature/new-feature
```

### Hotfix Workflow
```bash
# 1. Create hotfix from main
git checkout main
git pull origin main
git checkout -b hotfix/critical-fix

# 2. Fix the issue
git add .
git commit -m "fix: resolve critical bug"

# 3. Push and merge to main
git push -u origin hotfix/critical-fix

# 4. Also merge to develop
git checkout develop
git merge hotfix/critical-fix
git push origin develop

# 5. Delete hotfix branch
git branch -d hotfix/critical-fix
```

### Release Branch Workflow
```bash
# 1. Create release branch
git checkout develop
git checkout -b release/v1.2.0

# 2. Prepare release (version bumps, etc.)
git add .
git commit -m "chore: prepare v1.2.0 release"

# 3. Merge to main
git checkout main
git merge release/v1.2.0
git tag -a v1.2.0 -m "Release v1.2.0"

# 4. Merge back to develop
git checkout develop
git merge release/v1.2.0

# 5. Delete release branch
git branch -d release/v1.2.0
```

## Related Workflows

- `git-commit` - Commit changes on branch
- `git-sync` - Sync branch with remote
- `git-status` - Check branch status

## Best Practices

1. **Descriptive Names** - Use clear, meaningful branch names
2. **Small Branches** - Keep branches focused on single features
3. **Regular Updates** - Sync with main branch frequently
4. **Clean Up** - Delete merged branches
5. **Naming Convention** - Follow team's naming standards

## Safety Checks

Before creating/switching branches, Cline will verify:
- ✅ No uncommitted changes (or offer to stash)
- ✅ Branch name follows conventions
- ✅ Not overwriting existing branch
- ✅ Base branch is up to date

## Example Scenarios

### Scenario 1: New Feature
```bash
# Start new feature
git checkout main
git pull origin main
git checkout -b feature/user-profile

# Work on feature...
git add .
git commit -m "feat: add user profile page"

# Push to remote
git push -u origin feature/user-profile
```

### Scenario 2: Quick Bug Fix
```bash
# Create fix branch
git checkout -b fix/button-alignment

# Fix the bug
git add .
git commit -m "fix: correct button alignment"

# Push and create PR
git push -u origin fix/button-alignment
```

### Scenario 3: Switch Context
```bash
# Save current work
git stash

# Switch to different branch
git checkout feature/other-feature

# Work on it...

# Return to original branch
git checkout feature/my-feature
git stash pop
```

## Notes

- Branch names are case-sensitive
- Use hyphens, not spaces in branch names
- Keep branch names short but descriptive
- Delete branches after merging
- Communicate branch strategy with team
