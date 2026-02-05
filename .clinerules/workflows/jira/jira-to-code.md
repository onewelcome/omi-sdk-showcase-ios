# Jira to Code Workflow

**Trigger Commands:**
- `start jira to code workflow`
- `jira to code`
- `start jira workflow`
- `jira sprint workflow`

**Description:**
Automated end-to-end workflow that takes a Jira story from the current sprint, creates sub-tasks, updates statuses, creates appropriate Git branches, and starts development work. This workflow eliminates the manual process of managing Jira tickets and Git branches during development.

## Overview

This workflow automates the complete development cycle by:
1. Fetching stories assigned to developer in current sprint
2. Creating sub-tasks based on story description
3. Updating Jira statuses (story and sub-task to "In Progress")
4. Creating story branch from develop
5. Creating sub-task branch from story branch
6. Starting code changes for the sub-task

## Prerequisites

### 1. Jira Access via Atlassian MCP Server

**IMPORTANT: This workflow uses the Atlassian MCP Server for all Jira operations.**

**MCP Server Configuration:**
- The Atlassian MCP Server must be configured and running
- It provides tools for Jira operations (searching, creating issues, updating status, etc.)
- Handles authentication and API communication automatically
- See MCP server documentation for setup details

**Available MCP Tools:**
- `jira_search` - Search for Jira issues using JQL
- `jira_get_issue` - Get details of specific issues
- `jira_create_issue` - Create new issues and sub-tasks
- `jira_update_issue` - Update issue fields
- `jira_transition_issue` - Change issue status
- `jira_get_sprints_from_board` - Get sprints from a board
- `jira_get_sprint_issues` - Get issues in a sprint
- And more...

**Note:** All Jira API calls in this workflow should use the Atlassian MCP Server tools instead of direct curl commands.

**How to Get Board ID:**
```bash
# List all boards
curl -H "Authorization: Bearer $JIRA_API_TOKEN" \
  "$JIRA_BASE_URL/rest/agile/1.0/board"

# Find your board and note the "id" field
```

### 2. Git Configuration

**Requirements:**
- Git repository initialized
- `develop` branch exists
- Working directory is clean (no uncommitted changes)
- Git user configured

**Verify Git setup:**
```bash
# Check current branch
git branch --show-current

# Check for develop branch
git branch -a | grep develop

# Check git status
git status
```

### 3. Required Permissions

Your Jira account must have:
- Permission to view sprint issues
- Permission to create sub-tasks
- Permission to update issue status
- Permission to assign issues

## Workflow Steps

### Step 0: Fetch Current Sprint Stories

**Cline will:**
1. Get current date and determine active sprint
2. Fetch stories assigned to you in current sprint
3. Display list of available stories
4. Ask you to select which story to work on

**API Call:**
```bash
# ALWAYS unset proxy first
unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY

# Get current sprint
SPRINT_ID=$(curl -H "Authorization: Bearer $JIRA_API_TOKEN" \
  "$JIRA_BASE_URL/rest/agile/1.0/board/$BOARD_ID/sprint?state=active" | \
  jq -r '.values[0].id')

# Get stories assigned to current user in sprint
curl -H "Authorization: Bearer $JIRA_API_TOKEN" \
  "$JIRA_BASE_URL/rest/agile/1.0/sprint/$SPRINT_ID/issue?jql=assignee=currentUser() AND type=Story"
```

**Display Format:**
```
Found 5 stories in current sprint (Sprint 23):

1. PROJ-123 - Implement OAuth authentication [To Do]
   Description: Add OAuth 2.0 support for Google and Facebook
   Story Points: 8

2. PROJ-145 - Add biometric authentication [To Do]
   Description: Implement Face ID and Touch ID for iOS
   Story Points: 5

3. PROJ-167 - Fix login crash on iOS [In Progress]
   Description: App crashes when invalid credentials entered
   Story Points: 3

4. PROJ-189 - Update API documentation [To Do]
   Description: Document new authentication endpoints
   Story Points: 2

5. PROJ-201 - Performance optimization [To Do]
   Description: Optimize authentication flow performance
   Story Points: 5

Which story would you like to work on? (1-5)
```

### Step 1: Generate and Select Sub-tasks

**Cline will:**
1. Analyze story description
2. Generate appropriate sub-tasks based on analysis
3. **Display generated sub-tasks to user**
4. **Ask user to select which sub-tasks to create**
5. Create selected sub-tasks via Jira API
6. Display created sub-tasks with Jira ticket IDs

**Sub-task Generation Logic:**

Cline analyzes the story description and generates sub-tasks based on:
- Technical requirements mentioned
- Acceptance criteria
- Implementation steps
- Testing requirements

**Example Sub-task Generation Display:**
```
Story: [STORY-KEY] - [Story Title]

Description:
[Story description from Jira]

Analyzing story requirements...

Generated Sub-tasks:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. [ ] [Sub-task 1 Summary]
2. [ ] [Sub-task 2 Summary]
3. [ ] [Sub-task 3 Summary]
4. [ ] [Sub-task 4 Summary]
5. [ ] [Sub-task 5 Summary]
6. [ ] [Sub-task 6 Summary]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Which sub-tasks would you like to create in Jira?
(Enter numbers separated by commas, e.g., "1,2,3" or "all" for all sub-tasks)
```

**User Selection:**
```
User: 1,2,3,4,5

Cline: You selected 5 sub-tasks to create:
       1. [Sub-task 1 Summary]
       2. [Sub-task 2 Summary]
       3. [Sub-task 3 Summary]
       4. [Sub-task 4 Summary]
       5. [Sub-task 5 Summary]

       Skipping:
       6. [Sub-task 6 Summary]

       Creating selected sub-tasks in Jira...
```

**Creating Selected Sub-tasks**

The Atlassian MCP Server can create multiple sub-tasks efficiently using the `jira_create_issue` tool.

**Using MCP Server to Create Sub-tasks:**

For each selected sub-task, use the `jira_create_issue` MCP tool:

```
use_mcp_tool:
  server_name: mcp-atlassian
  tool_name: jira_create_issue
  arguments:
    project_key: PROJ
    summary: [Sub-task 1 Summary]
    issue_type: Sub-task
    additional_fields:
      parent: STORY-123
```

**Batch Creation Approach:**

All selected sub-tasks can be created in sequence using the MCP server. The workflow:

1. For each selected sub-task (e.g., sub-tasks 1, 2, 3, 4, 5)
2. Call `jira_create_issue` with the sub-task details
3. The MCP server handles authentication and API communication
4. Track created sub-task keys for later use

**Example MCP Tool Usage:**
```
# Create sub-task 1
use_mcp_tool with jira_create_issue:
  - project_key: PROJ
  - summary: "Set up OAuth provider configuration"
  - issue_type: "Sub-task"
  - parent: "PROJ-123"

# Create sub-task 2
use_mcp_tool with jira_create_issue:
  - project_key: PROJ
  - summary: "Implement OAuth login flow"
  - issue_type: "Sub-task"
  - parent: "PROJ-123"

# Continue for all selected sub-tasks...
```

**Note:** The MCP server automatically handles:
- Issue type ID detection (finds the correct sub-task type)
- Authentication (no need to manage tokens manually)
- Error handling and retries

**Display After Creation:**
```
✅ Created [N] sub-tasks in Jira:

1. [SUBTASK-1] - [Sub-task 1 Summary] [To Do]
2. [SUBTASK-2] - [Sub-task 2 Summary] [To Do]
3. [SUBTASK-3] - [Sub-task 3 Summary] [To Do]
4. [SUBTASK-4] - [Sub-task 4 Summary] [To Do]
5. [SUBTASK-5] - [Sub-task 5 Summary] [To Do]

Skipped: [Sub-task 6 Summary] (can be added manually later if needed)
```

**Note:** This dynamically retrieves the correct sub-task issue type ID for your Jira project. In SASMOB, the sub-task type is "Technical Task" (ID: 10105), but this may vary by project.

### Step 2: Update Story Status to "In Progress"

**Cline will:**
1. Get available transitions for the story
2. Find "In Progress" transition ID
3. Execute transition

**API Call:**
```bash
# ALWAYS unset proxy first
unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY

# Get available transitions
TRANSITIONS=$(curl -H "Authorization: Bearer $JIRA_API_TOKEN" \
  "$JIRA_BASE_URL/rest/api/2/issue/$STORY_KEY/transitions")

# Find "In Progress" transition ID
TRANSITION_ID=$(echo $TRANSITIONS | jq -r '.transitions[] | select(.name=="In Progress") | .id')

# Execute transition
curl -X POST "$JIRA_BASE_URL/rest/api/2/issue/$STORY_KEY/transitions" \
  -H "Authorization: Bearer $JIRA_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "transition": {
      "id": "'"$TRANSITION_ID"'"
    }
  }'
```

### Step 3: Update Sub-task Status to "In Progress"

**Cline will:**
1. Ask which sub-task to start with (or default to first one)
2. Update selected sub-task status to "In Progress"

**Display:**
```
Created [N] sub-tasks for [STORY-KEY]:

1. [SUBTASK-1] - [Sub-task 1 Summary] [To Do]
2. [SUBTASK-2] - [Sub-task 2 Summary] [To Do]
3. [SUBTASK-3] - [Sub-task 3 Summary] [To Do]
4. [SUBTASK-4] - [Sub-task 4 Summary] [To Do]
5. [SUBTASK-5] - [Sub-task 5 Summary] [To Do]
6. [SUBTASK-6] - [Sub-task 6 Summary] [To Do]

Which sub-task would you like to start with? (1-[N], default: 1)
```

**API Call:**
```bash
# ALWAYS unset proxy first
unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY

# Update sub-task status
curl -X POST "$JIRA_BASE_URL/rest/api/2/issue/$SUBTASK_KEY/transitions" \
  -H "Authorization: Bearer $JIRA_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "transition": {
      "id": "'"$TRANSITION_ID"'"
    }
  }'
```

### Step 4: Create Git Branches

**Cline will:**
1. Check if story branch exists
   - If exists: Switch to story branch
   - If not exists: Create story branch from develop
2. Create sub-task branch from story branch
3. Checkout sub-task branch

**Branch Naming Convention:**
- Story branch: `PROJ-123` (just the Jira story ticket ID)
- Sub-task branch: `PROJ-124` (just the Jira sub-task ticket ID)

**Git Commands:**
```bash
# Ensure we're on develop and it's up to date
git checkout develop
git pull origin develop

# Use story ticket ID as branch name (e.g., PROJ-123)
STORY_BRANCH="$STORY_KEY"

# Check if story branch exists (locally or remotely)
if git show-ref --verify --quiet refs/heads/$STORY_BRANCH; then
  # Story branch exists locally
  echo "Story branch exists locally, switching to it..."
  git checkout "$STORY_BRANCH"
  git pull origin "$STORY_BRANCH" 2>/dev/null || true
elif git ls-remote --heads origin "$STORY_BRANCH" | grep -q "$STORY_BRANCH"; then
  # Story branch exists remotely
  echo "Story branch exists remotely, checking it out..."
  git checkout -b "$STORY_BRANCH" origin/"$STORY_BRANCH"
else
  # Story branch doesn't exist, create it
  echo "Story branch doesn't exist, creating from develop..."
  git checkout -b "$STORY_BRANCH"
fi

# Use sub-task ticket ID as branch name (e.g., PROJ-124)
SUBTASK_BRANCH="$SUBTASK_KEY"
git checkout -b "$SUBTASK_BRANCH"

# Verify
git branch --show-current
```

**Display (Story Branch Exists):**
```
✅ Story branch exists: PROJ-123
✅ Switched to story branch
✅ Created sub-task branch: PROJ-124

✅ Currently on: PROJ-124
```

**Display (Story Branch Created):**
```
✅ Created branches:
   Story branch: PROJ-123 (new)
   Sub-task branch: PROJ-124

✅ Currently on: PROJ-124
```

### Step 5: Start Code Changes

**Cline will:**
1. Analyze sub-task requirements
2. Identify files that need changes
3. Propose implementation approach
4. Request approval before making changes
5. Implement changes with user approval

**Interactive Flow:**
```
Sub-task: [SUBTASK-KEY] - [Sub-task Summary]

Analysis:
- [Analysis point 1]
- [Analysis point 2]
- [Analysis point 3]
- [Analysis point 4]

Proposed changes:
1. Create: [file path 1]
2. Modify: [file path 2]
3. Create: [file path 3]
4. Add: [file path 4]

Would you like me to proceed with these changes? (yes/no)
```

**After Approval:**
```
Creating files for [Sub-task Summary]...

✅ Created: [file path 1]
✅ Created: [file path 2]
✅ Modified: [file path 3]
✅ Created: [file path 4]

Changes complete! Ready to commit?
```

## Complete Workflow Example

### Example: Feature Implementation Story

```
User: start jira to code workflow

Cline: Fetching stories from current sprint...
      
      Found [N] stories in Sprint [N]:
      
      1. [STORY-1] - [Story 1 Title] [To Do, [N] points]
      2. [STORY-2] - [Story 2 Title] [To Do, [N] points]
      3. [STORY-3] - [Story 3 Title] [In Progress, [N] points]
      4. [STORY-4] - [Story 4 Title] [To Do, [N] points]
      5. [STORY-5] - [Story 5 Title] [To Do, [N] points]
      
      Which story would you like to work on?

User: 1

Cline: Selected: [STORY-1] - [Story Title]
      
      Story Description:
      [Story description from Jira]
      
      Analyzing story and generating sub-tasks...
      
      Generated Sub-tasks:
      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      
      1. [ ] [Sub-task 1 Summary]
      2. [ ] [Sub-task 2 Summary]
      3. [ ] [Sub-task 3 Summary]
      4. [ ] [Sub-task 4 Summary]
      5. [ ] [Sub-task 5 Summary]
      6. [ ] [Sub-task 6 Summary]
      
      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      
      Which sub-tasks would you like to create? (1,2,3,4,5,6 or "all")

User: 1,2,3,4,5

Cline: Creating 5 selected sub-tasks in Jira...
      
      ✅ Created [SUBTASK-1] - [Sub-task 1 Summary] [To Do]
      ✅ Created [SUBTASK-2] - [Sub-task 2 Summary] [To Do]
      ✅ Created [SUBTASK-3] - [Sub-task 3 Summary] [To Do]
      ✅ Created [SUBTASK-4] - [Sub-task 4 Summary] [To Do]
      ✅ Created [SUBTASK-5] - [Sub-task 5 Summary] [To Do]
      
      Skipped: [Sub-task 6 Summary]
      
      ✅ Updated [STORY-1] status: To Do → In Progress
      
      Which sub-task would you like to start with? (default: 1)

User: 1

Cline: Starting with: [SUBTASK-1] - [Sub-task 1 Summary]
      
      ✅ Updated [SUBTASK-1] status: To Do → In Progress
      
      Creating Git branches...
      
      ✅ Created story branch: [STORY-1]
      ✅ Created sub-task branch: [SUBTASK-1]
      ✅ Checked out: [SUBTASK-1]
      
      Analyzing sub-task requirements...
      
      Sub-task: [Sub-task 1 Summary]
      
      I'll implement [feature description]. Here's what I'll create:
      
      📄 File 1: [file path 1]
      ------- CODE PROPOSAL -------
      [Code content for file 1]
      
      📄 File 2: [file path 2]
      ------- CODE PROPOSAL -------
      [Code content for file 2]
      
      📄 File 3: [file path 3] (MODIFY)
      ------- CODE PROPOSAL -------
      [Code content for file 3]
      
      📄 File 4: [file path 4]
      ------- CODE PROPOSAL -------
      [Code content for file 4]
      
      Would you like to APPROVE or REJECT these changes?
      Type 'approve' to apply all changes, or 'reject' to cancel.

User: approve

Cline: Applying code changes...
      
      ✅ Created: [file path 1]
      ✅ Created: [file path 2]
      ✅ Modified: [file path 3]
      ✅ Created: [file path 4]
      
      Implementation complete!
      
      Summary:
      - Story: [STORY-1] [In Progress]
      - Sub-task: [SUBTASK-1] [In Progress]
      - Branch: [SUBTASK-1]
      - Files changed: [N] files ([N] new, [N] modified)
      
      Next steps:
      1. Review the changes
      2. Run tests
      3. Commit changes
      4. Continue with next sub-task or push changes
      
      Would you like to:
      1. Review changes
      2. Run tests
      3. Commit changes
      4. Continue to next sub-task
      5. Push changes
```

## Advanced Features

### 1. Smart Sub-task Generation

**Cline analyzes story description for:**
- Technical requirements
- Acceptance criteria
- Implementation steps
- Testing needs
- Documentation needs

**Example Analysis:**
```
Story: "Implement OAuth with Google and Facebook. Include error handling and tests."

Generated Sub-tasks:
1. Set up OAuth provider configuration (Google, Facebook)
2. Implement OAuth login flow
3. Add error handling for OAuth failures
4. Add unit tests for OAuth flow
5. Add integration tests
6. Update documentation
```

### 2. Dependency Detection

**Cline identifies sub-task dependencies:**
```
Sub-task Dependencies:
1. PROJ-124 - OAuth configuration (no dependencies)
2. PROJ-125 - OAuth login flow (depends on PROJ-124)
3. PROJ-126 - Token storage (depends on PROJ-125)
4. PROJ-127 - Error handling (depends on PROJ-125)
5. PROJ-128 - Unit tests (depends on PROJ-125, PROJ-126, PROJ-127)
6. PROJ-129 - Documentation (depends on all above)

Recommended order: 1 → 2 → 3 → 4 → 5 → 6
```

### 3. Automatic Story Point Distribution

**Cline distributes story points across sub-tasks:**
```
Story: PROJ-123 (8 points)

Sub-task Point Distribution:
1. PROJ-124 - OAuth configuration (1 point)
2. PROJ-125 - OAuth login flow (3 points)
3. PROJ-126 - Token storage (2 points)
4. PROJ-127 - Error handling (1 point)
5. PROJ-128 - Unit tests (1 point)
6. PROJ-129 - Documentation (0 points)

Total: 8 points
```

### 4. Multi-Sub-task Workflow

**Continue to next sub-task after completing current one:**
```
User: next sub-task

Cline: Current sub-task PROJ-124 complete!
      
      Moving to next sub-task: PROJ-125 - Implement OAuth login flow
      
      ✅ Updated PROJ-125 status: To Do → In Progress
      ✅ Created branch: subtask/proj-125-implement-oauth-login-flow
      ✅ Checked out: subtask/proj-125-implement-oauth-login-flow
      
      Analyzing requirements...
```

### 5. Branch Management

**Automatic branch cleanup and merging:**
```
User: complete sub-task

Cline: Sub-task PROJ-124 complete!
      
      Would you like to:
      1. Merge sub-task branch to story branch
      2. Keep sub-task branch for review
      3. Delete sub-task branch
      
User: 1

Cline: Merging subtask/proj-124-setup-oauth-provider-config → story/proj-123-implement-oauth-authentication
      
      ✅ Merged successfully
      ✅ Switched to story branch
      
      Ready for next sub-task!
```

## Workflow Variations

### Variation 1: Start from Specific Story

```
User: start jira to code workflow for PROJ-123

Cline: Loading story PROJ-123...
      
      Story: Implement OAuth authentication [To Do, 8 points]
      
      Creating sub-tasks...
      [Continues with workflow]
```

### Variation 2: Resume Existing Story

```
User: resume jira workflow

Cline: Found stories in progress:
      
      1. PROJ-123 - Implement OAuth authentication
         - 3 of 6 sub-tasks complete
         - Current: PROJ-127 - Error handling [In Progress]
      
      2. PROJ-167 - Fix login crash
         - 1 of 3 sub-tasks complete
         - Current: PROJ-169 - Add error logging [In Progress]
      
      Which story would you like to resume?

User: 1

Cline: Resuming PROJ-123...
      
      Current sub-task: PROJ-127 - Implement error handling
      Current branch: subtask/proj-127-implement-error-handling
      
      Ready to continue!
```

### Variation 3: Skip Sub-task Creation

```
User: start jira to code workflow without sub-tasks

Cline: Fetching stories...
      
      [Shows stories]
      
User: 1

Cline: Selected: PROJ-123
      
      ✅ Updated status: In Progress
      ✅ Created branch: story/proj-123-implement-oauth-authentication
      
      Ready to start coding!
```

## Integration with Other Workflows

### With Git Commit Workflow

```
User: commit sub-task changes

Cline: Committing changes for PROJ-124...
      
      Files changed:
      - src/config/oauth-config.ts
      - src/config/oauth-providers.json
      - src/config/index.ts
      - tests/config/oauth-config.test.ts
      
      Commit message: "feat(PROJ-124): set up OAuth provider configuration"
      
      ✅ Changes committed
```

### With Git Sync Workflow

```
User: sync sub-task branch

Cline: Syncing subtask/proj-124-setup-oauth-provider-config...
      
      ✅ Pulled latest from story branch
      ✅ Pushed sub-task branch to remote
      
      Branch is up to date!
```

### With MR Review Request

```
User: request review for sub-task

Cline: Creating MR for PROJ-124...
      
      MR: subtask/proj-124-setup-oauth-provider-config → story/proj-123-implement-oauth-authentication
      
      Title: PROJ-124: Set up OAuth provider configuration
      Description: Implements OAuth configuration for Google and Facebook providers
      
      ✅ MR created: !456
      
      Requesting review...
```

## Troubleshooting

### Issue 1: No Stories in Current Sprint

**Error:** No stories found in current sprint

**Solution:**
```bash
# Verify sprint is active
curl -H "Authorization: Bearer $JIRA_API_TOKEN" \
  "$JIRA_BASE_URL/rest/agile/1.0/board/$BOARD_ID/sprint?state=active"

# Check if stories are assigned to you
curl -H "Authorization: Bearer $JIRA_API_TOKEN" \
  "$JIRA_BASE_URL/rest/agile/1.0/sprint/$SPRINT_ID/issue?jql=assignee=currentUser()"

# Verify board ID is correct
echo $BOARD_ID
```

### Issue 2: Cannot Create Sub-tasks

**Error:** Permission denied or invalid parent

**Solution:**
- Verify you have permission to create sub-tasks
- Ensure parent issue is a Story (not a sub-task)
- Check that sub-task issue type exists in project

### Issue 3: Branch Already Exists

**Error:** Branch already exists

**Solution:**
```bash
# List existing branches
git branch -a

# Delete old branch if needed
git branch -D story/proj-123-implement-oauth-authentication

# Or switch to existing branch
git checkout story/proj-123-implement-oauth-authentication
```

### Issue 4: Develop Branch Not Found

**Error:** develop branch does not exist

**Solution:**
```bash
# Create develop branch from main
git checkout main
git checkout -b develop
git push -u origin develop

# Or use different base branch
# Cline will ask: "Which branch should I use as base? (main/master/develop)"
```

### Issue 5: Status Transition Not Available

**Error:** Cannot transition to "In Progress"

**Solution:**
```bash
# Check available transitions
curl -H "Authorization: Bearer $JIRA_API_TOKEN" \
  "$JIRA_BASE_URL/rest/api/2/issue/$STORY_KEY/transitions"

# Use correct transition name from your workflow
# Common alternatives: "Start Progress", "Start Work", "Begin"
```

## Configuration

**Complete configuration example:**

```json
{
  "jiraConfig": {
    "baseUrl": "https://your-jira-domain.com",
    "email": "your-email@company.com",
    "apiToken": "your-api-token",
    "projectKey": "PROJ",
    "boardId": "123",
    "workflow": {
      "baseBranch": "develop",
      "storyBranchPrefix": "story",
      "subtaskBranchPrefix": "subtask",
      "autoCreateSubtasks": true,
      "autoUpdateStatus": true,
      "subtaskEstimation": "auto"
    },
    "statusNames": {
      "toDo": "To Do",
      "inProgress": "In Progress",
      "done": "Done"
    }
  }
}
```

## Best Practices

1. **Clear Story Descriptions** - Write detailed story descriptions for better sub-task generation
2. **Acceptance Criteria** - Include clear acceptance criteria in stories
3. **Small Sub-tasks** - Keep sub-tasks focused and small (1-3 points)
4. **Regular Commits** - Commit after completing each sub-task
5. **Branch Cleanup** - Merge and delete sub-task branches after completion
6. **Status Updates** - Keep Jira statuses current
7. **Code Review** - Request reviews for each sub-task or story
8. **Documentation** - Include documentation sub-tasks

## Quick Reference

### Trigger Commands
```
start jira to code workflow
jira to code
start jira workflow
jira sprint workflow
```

### Workflow Steps
```
1. Fetch sprint stories → Select story
2. Create sub-tasks → Update story status
3. Select sub-task → Update sub-task status
4. Create branches → Start coding
5. Implement changes → Commit
6. Next sub-task or complete story
```

### Branch Naming
```
Story: PROJ-123
Sub-task: PROJ-124
```

### Common Commands During Workflow
```
next sub-task          - Move to next sub-task
complete sub-task      - Mark current sub-task done
commit changes         - Commit current work
push changes           - Push to remote
request review         - Create MR and request review
resume workflow        - Resume in-progress story
```

## Related Workflows

- `jira-ticket-search` - Search for Jira tickets
- `jira-ticket-creation` - Create new Jira tickets
- `git-branch` - Manage Git branches
- `git-commit` - Commit changes
- `git-sync` - Sync with remote
- `mr-review-request` - Request code reviews

## Notes

- Workflow requires active sprint with assigned stories
- Sub-tasks are automatically assigned to current user
- **Branch names use Jira ticket IDs directly** (e.g., `PROJ-123`, `PROJ-124`)
- Status transitions must exist in your Jira workflow
- **All API calls use Bearer token authentication** (not Basic auth)
- Always unset proxy before making Jira API calls
- **Code changes are presented as proposals** - user must approve or reject before implementation
- Cline provides actual code content in proposals, not just placeholders
- **Sub-task issue type detection**: The workflow dynamically detects the correct sub-task issue type for your Jira project
  - Standard Jira uses "Sub-task" issue type
  - Some instances (like SASMOB) use "Technical Task" (ID: 10105)
  - The workflow automatically queries your project's issue types to use the correct one

---

**Last Updated:** 2025-11-20
**Version:** 2.0
**Maintainer:** Development Team
