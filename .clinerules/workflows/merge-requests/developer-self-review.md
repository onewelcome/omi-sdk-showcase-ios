# Code Review Workflow

This workflow automates the code review process for GitLab Merge Requests (MRs). It intelligently reviews **only the differences** between commits or full files based on user input, supports reconciliation, and stores all generated files in a dedicated workspace folder.

## Code Review Rules

```
rules:
  - description: "Code Review Rules"
    match: ".*"
    steps:
      - name: "Load Memory Bank"
        do: |
          Always load and reference the following files from /memory-bank/ (if present):
          - code-standards.md
          - security-checklist.md
          - performance-guidelines.md
          - merge-request-review.md
          - activeContext.md
          - progress.md

      - name: "Review Process"
        do: |
          When reviewing code (files or diffs), act as if reviewing a GitLab Merge Request.
          - Apply rules from the memory bank documents.
          - Follow the checklist in merge-request-review.md.
          - Provide structured feedback:
            1. Summary (high-level quality overview)
            2. Major Issues (bugs, security, performance, design flaws — blocking)
            3. Minor Issues (naming, formatting, readability, tests — non-blocking)
            4. Suggestions (optional improvements, refactorings)
            5. Verdict (Approve / Request Changes / Needs Discussion)
          - Analyze the Changes
            For each modified file, understand:

            1. What was changed
            2. Why it was changed (based on MR description)
            3. How it affects the codebase
            4. Potential side effects
          - Look for:

            1. Code quality issues
            2. Potential bugs
            3. Performance implications
            4. Security concerns
            5. Test coverage

      - name: "Output Style"
        do: |
          - Use clear, concise language.
          - **MANDATORY**: Include specific line numbers for each comment using the format: `| File | Line | Priority | Comment |`
          - Reference specific lines or methods when possible.
          - Give actionable recommendations (with code snippets if useful).
          - Avoid rewriting entire files unless explicitly asked.
```

## Workflow Instructions

### Step 1: Setup and Input Gathering

All temporary and workflow-generated files will be stored in a folder named `workflow_workspace`.

```cmd
:: Ensure workspace folder exists
if not exist workflow_workspace mkdir workflow_workspace
cd workflow_workspace
```

First, determine the source of files to review:

```xml
<ask_followup_question>
<question>Please provide the GitLab MR number to review, or leave blank if you already have a changed_files.txt file ready.</question>
</ask_followup_question>
```

---

## If an MR number is provided

Replace `MR_NUMBER` with the number of the Merge Request (e.g., `42`).

```cmd
:: Fetch MR diff and extract only changed file paths
(for /f "tokens=1* delims= " %i in ('glab mr diff %MR_NUMBER% ^| findstr "^+++ b/" ^| findstr /V "Binary files"') do @echo %j) > changed_files.txt

:: Create a backup for reconciliation
copy changed_files.txt changed_files.original.txt
```

---

## If no MR number is provided

```cmd
:: Verify that changed_files.txt exists
if exist changed_files.txt (
    copy changed_files.txt changed_files.original.txt
) else (
    echo "changed_files.txt not found. Please provide an MR number or existing file."
    exit /b 1
)
```

---

## Initialize the review file

```cmd
:: Create change_review.txt if it does not exist
if not exist change_review.txt (
    echo ^| File ^| Line ^| Priority ^| Comment ^| > change_review.txt
    echo ^|---^|---^|---^|---^| >> change_review.txt
)
```

---

### Step 2: Diff vs Full File Review Prompt

```xml
<ask_followup_question>
<question>Do you want to review only the differences or the full files?</question>
<options>["Only Differences", "Full Files"]</options>
</ask_followup_question>
```

If **Only Differences** is selected, the workflow will review only the diff sections retrieved by:

```cmd
glab mr diff %MR_NUMBER% > diffs.txt
```

Each diff block will be extracted and analyzed individually instead of loading the entire file.

If **Full Files** is selected, it will load the entire file content using the `read_file` directive for review.

---

### Step 3: Review and Reconciliation Loop

For each entry in `changed_files.txt` or diff block:

1. **Check if already reviewed** — skip if file path is already listed in `change_review.txt`.
2. **Load the target** — file content or diff section.
3. **Extract line numbers** — Parse diff hunks to identify specific line numbers for each change:
   - Use `@@ -old_line_range +new_line_range @@` format to map line numbers
   - For added lines: use the `+` line number from the diff hunk
   - For modified lines: use the line number where the change occurs
   - For deleted lines: use the `-` line number from the diff hunk
4. **Analyze** — apply the rule set and record structured feedback with line numbers.
5. **Append results** to the review table in format: `| File | Line | Priority | Comment |`
6. **Skip irrelevant files** — ignore items under `docs/` or `example/`.

#### Line Number Extraction Guide

When reviewing diffs, extract line numbers using this approach:

```bash
# Example diff hunk:
@@ -50,7 +50,8 @@
 context line
-removed line
+added line
 context line

# Maps to:
# - Line 51: removed line (from -old_line_range)
# - Line 51: added line (from +new_line_range)
```

For complex changes, use the first line number of the changed block when multiple lines are affected.

#### Reconciliation Handling

The workflow looks for `reconcile.py` in the current working directory (where the workflow was invoked).

* If **found**, it uses the existing file.
* If **missing**, it auto-generates a new one with standard reconciliation logic:

```python
#!/usr/bin/env python3
import sys, os

def read_lines(f):
    return [l.strip() for l in open(f)] if os.path.exists(f) else []

all_files = set(read_lines('changed_files.original.txt'))
reviewed_files = set()

for line in read_lines('change_review.txt'):
    if line.startswith('|') and not line.startswith('|---'):
        # Handle both old format (File|Priority|Comment) and new format (File|Line|Priority|Comment)
        parts = [p.strip() for p in line.split('|')]
        if len(parts) >= 4:  # New format with line numbers
            reviewed_files.add(parts[0])  # File is at index 0
        elif len(parts) >= 3:  # Old format for backward compatibility
            reviewed_files.add(parts[0])  # File is at index 0

missing = all_files - reviewed_files

if missing:
    print("Missing reviews:")
    for f in missing:
        print(f)
    sys.exit(1)
else:
    print("All files reviewed.")
    sys.exit(0)
```

Run reconciliation:

```bash
python reconcile.py
```

If reconciliation fails, the workflow retries only the missing files until completion.

---

### Step 4: Finalization and Reporting

Once reconciliation passes:

1. Generate summary statistics (total reviewed, priority counts, etc.)
2. Ask user whether to post results to MR
3. Post comments to GitLab MR if approved:

```bash
cat << EOF | glab mr note %MR_NUMBER% --body-file -
## Code Review Summary
$(cat change_review.txt)
Review completed successfully.
EOF
```

---

### Step 5: Completion and Learning

```xml
<attempt_completion>
<result>
Code review workflow completed successfully.

- All files or diffs have been reviewed
- Review comments saved to workflow_workspace/change_review.txt
- Reconciliation verified 100% completion

The workflow self-adjusts and logs any failures or retries in workflow_workspace/logs/ for adaptive improvements.
</result>
</attempt_completion>
```

---

## Context Awareness and Self-Learning

* Each run logs all commands, errors, and retry actions into `workflow_workspace/logs/`.
* Failures trigger adaptive rule adjustments for future runs.
* Review metadata (like skipped files, time taken, errors) are persisted to help the workflow improve its reliability and context sensitivity over time.

---

## Usage

To run this workflow:

1. Type `/gitlab-code-review-workflow.md` in the Cline chat.
2. When prompted:

   * Enter the **GitLab MR number** to review, or
   * Press **Enter** to use an existing `changed_files.txt` file.
3. The workflow will automatically:

   * Review all changed files or diffs.
   * Verify review completeness using reconciliation.
   * Retry missing files until all are reviewed.
   * Optionally post summarized results to the GitLab MR.

### Notes

* **Resumable execution:** If interrupted, re-run the workflow; already-reviewed files will be skipped.
* **Reconciliation loop:** Guarantees 100% file coverage even with partial runs or network/API issues.
* **Output consistency:** All review comments follow table format for easy parsing and integration into reports or dashboards.
