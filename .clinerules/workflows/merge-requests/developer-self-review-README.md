# GitLab Code Review Workflow - Quick Start

**Workflow File:** `developer-self-review.md`  
**Purpose:** Automated code review for GitLab Merge Requests with reconciliation and line number tracking

---

## Overview

This workflow automates the code review process for GitLab MRs by:
- ✅ Fetching changed files from GitLab MR or local file list
- ✅ Reviewing code with intelligent diff-focused analysis
- ✅ Ensuring 100% completion through automatic reconciliation
- ✅ Optionally posting results directly to GitLab MR
- ✅ Storing all files in dedicated `workflow_workspace/` folder

---

## Quick Start

### Option 1: Review a GitLab MR

```
Type: /developer-self-review.md

When prompted:
- Enter MR number (e.g., 42)
- Choose review mode: "Only Differences" or "Full Files"
```

### Option 2: Review from File List

```
1. Create changed_files.txt with file paths
2. Type: /developer-self-review.md  
3. Press Enter when prompted for MR number
4. Choose review mode
```

---

## Key Features

- **GitLab Integration:** Native support for GitLab MRs using `glab` CLI
- **Dual Review Modes:** Choose between "Only Differences" or "Full Files"
- **Line Number Tracking:** Mandatory line numbers for precise issue location
- **Automatic Reconciliation:** Ensures 100% completion with retry logic
- **Dedicated Workspace:** All generated files in `workflow_workspace/`
- **Resumable:** Automatically resumes from where it left off if interrupted

---

## Prerequisites

- **GitLab CLI (`glab`)**: Required for MR reviews ([Install](https://gitlab.com/gitlab-org/cli))
- **Python 3**: Required for reconciliation script
- **Git**: Required for diff operations

---

## Output Files

All generated in `workflow_workspace/`:
- `changed_files.txt` - Current review list
- `changed_files.original.txt` - Source of truth
- `change_review.txt` - Review comments with line numbers (table format)
- `diffs.txt` - Raw diff content (diff mode only)
- `reconcile.py` - Auto-generated reconciliation script
- `logs/` - Execution logs

---

## Review Output Format

```markdown
| File | Line | Priority | Comment |
|---|---|---|----|
| src/auth/Login.java | 45 | High | **Bug Risk**: Null check missing |
| src/api/Auth.java | 67 | Medium | **Code Quality**: Add JSDoc |
```

**Priority Levels:**
- **High**: Blocking (bugs, security, critical design flaws)
- **Medium**: Important but non-blocking (code quality, maintainability)
- **Low**: Informational (suggestions, minor improvements)

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `glab: command not found` | Install GitLab CLI and authenticate with `glab auth login` |
| Missing files after review | Reconciliation will retry until all files reviewed |
| Python encoding error | Auto-generated script handles multiple encodings |

---

## For Full Documentation

See **`developer-self-review.md`** for:
- Complete workflow logic and steps
- Code review rules and criteria
- Reconciliation process details
- Advanced usage and customization
- Memory bank integration
- Example workflow runs

---

**Last Updated:** 2026-01-26  
**Type:** Cline Markdown Workflow  
**Platform:** GitLab MRs  
**Mode Required:** ACT MODE
