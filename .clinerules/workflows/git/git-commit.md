# Git Commit Workflow

## Trigger Commands
- `commit code changes`
- `commit changes`
- `git commit`

## Description
Automatically analyzes code changes and generates an appropriate commit message following conventional commit format, then commits the changes to the current branch.

## Purpose

Automate the commit process by:
- Analyzing code changes intelligently
- Generating descriptive commit messages automatically
- Following conventional commit format
- Committing to the current branch without manual input

## Prerequisites

- Git installed and configured
- Working directory is a Git repository
- Changes to commit exist

## Automated Workflow

When triggered with `commit code changes`, Cline will:

1. **Check Git Status**
   ```bash
   git status
   ```

2. **Analyze Changes**
   - Read `git diff` output to understand what changed
   - Identify file types and patterns
   - Determine the nature of changes (new feature, bug fix, refactor, etc.)

3. **Generate Commit Message**
   - Analyze the code changes using AI
   - Determine appropriate commit type (feat, fix, refactor, etc.)
   - Create a clear, descriptive commit message
   - Follow conventional commit format

4. **Stage and Commit**
   ```bash
   git add .
   git commit -m "generated message"
   ```

5. **Confirm Commit**
   - Show the commit message used
   - Display commit hash
   - Confirm successful commit

## Commit Message Generation Logic

The workflow analyzes changes to determine the commit type:

| Change Pattern | Commit Type | Example Message |
|----------------|-------------|-----------------|
| New files/features | `feat:` | `feat: add user authentication module` |
| Bug fixes | `fix:` | `fix: resolve null pointer in login flow` |
| Code restructuring | `refactor:` | `refactor: simplify database query logic` |
| Documentation | `docs:` | `docs: update API documentation` |
| Code formatting | `style:` | `style: format code with prettier` |
| Tests | `test:` | `test: add unit tests for auth service` |
| Dependencies | `chore:` | `chore: update gradle dependencies` |
| Performance | `perf:` | `perf: optimize image loading` |

## Analysis Process

1. **Read Git Diff**
   ```bash
   git diff --cached
   # or if nothing staged:
   git diff
   ```

2. **Analyze Changes**
   - Count files changed
   - Identify file types (Java, Kotlin, XML, etc.)
   - Detect patterns:
     - New files → likely `feat:`
     - Modified existing files → analyze content
     - Deleted files → likely `refactor:` or `chore:`
   - Look for keywords in changes:
     - "fix", "bug", "issue" → `fix:`
     - "add", "new", "implement" → `feat:`
     - "update", "improve" → `refactor:` or `feat:`
     - "test" → `test:`

3. **Generate Message**
   - Combine type with clear description
   - Keep message concise but descriptive
   - Include scope if applicable (e.g., `feat(auth):`)

## Example Scenarios

### Scenario 1: New Feature
```
Changes detected:
- New file: LoginActivity.java
- New file: AuthService.java
- Modified: AndroidManifest.xml

Generated message:
"feat: implement user login functionality"
```

### Scenario 2: Bug Fix
```
Changes detected:
- Modified: UserRepository.java (fixed null check)
- Modified: LoginViewModel.java (added error handling)

Generated message:
"fix: resolve crash when user data is null"
```

### Scenario 3: Refactoring
```
Changes detected:
- Modified: DatabaseHelper.java (simplified queries)
- Modified: UserDao.java (removed duplicate code)
- Deleted: OldHelper.java

Generated message:
"refactor: simplify database access layer"
```

### Scenario 4: Multiple File Types
```
Changes detected:
- Modified: MainActivity.java
- Modified: activity_main.xml
- Modified: strings.xml
- New file: UserProfileFragment.java

Generated message:
"feat: add user profile screen with UI components"
```

## Command Execution

```bash
# 1. Check status
git status

# 2. Get diff for analysis
git diff

# 3. Stage all changes
git add .

# 4. Commit with generated message
git commit -m "feat: add user authentication module"

# 5. Show commit confirmation
git log -1 --oneline
```

## When to Use

| Scenario | Use This Workflow? |
|----------|-------------------|
| Quick commits during development | ✅ Yes |
| End of work session | ✅ Yes |
| After completing a feature | ✅ Yes |
| After fixing a bug | ✅ Yes |
| Before switching branches | ✅ Yes |
| Complex changes needing detailed message | ⚠️ Consider manual message |

## Troubleshooting

### No Changes Detected
```
Cline: No changes detected to commit.
       Run 'git status' to verify.
```

### Unable to Determine Commit Type
```
Cline: Changes detected but type unclear.
       Defaulting to: "chore: update project files"
       
       Would you like to provide a custom message instead?
```

### Commit Failed
```bash
# Check for errors
git status

# Verify repository state
git log -1
```

## Advanced Features

### Scope Detection
If changes are isolated to a specific module:
```
Changes in: app/src/main/java/com/example/auth/
Generated: "feat(auth): implement OAuth login flow"
```

### Multi-line Messages
For complex changes:
```
feat: implement user authentication

- Add login screen with email/password
- Implement JWT token handling
- Add biometric authentication option
- Update security configuration
```

## Related Workflows

- `git-sync` - Pull and push changes after committing
- `git-branch` - Create and switch branches
- `mr-review-request` - Request review after committing

## Best Practices

1. **Review Before Commit** - Check `git status` to verify changes
2. **Logical Grouping** - Commit related changes together
3. **Frequent Commits** - Commit often with focused changes
4. **Trust the Analysis** - The AI analyzes patterns to generate appropriate messages
5. **Override When Needed** - You can still provide manual messages if needed

## Example Usage

```
User: commit code changes

Cline: Analyzing changes in current branch...
       
       Files changed: 3
       - LoginActivity.java (new)
       - AuthService.java (new)
       - AndroidManifest.xml (modified)
       
       Detected: New authentication feature
       
       Staging all changes...
       ✓ Staged 3 files
       
       Committing with message:
       "feat: implement user login functionality"
       
       ✓ Committed successfully
       Commit: a1b2c3d feat: implement user login functionality
       
       Your changes are now committed to branch: feature/auth
```

## Notes

- Commits are local until pushed (use `git-sync` to push)
- Generated messages follow conventional commit format
- AI analyzes code context to determine appropriate message
- You can always amend the commit if needed: `git commit --amend`
- The workflow stages ALL changes - review with `git status` first if needed
