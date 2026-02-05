# MR Review Request Workflow

**Trigger Commands:**
- `mr review`
- `request review`
- `request mr review`
- `review request`

**Description:**
Streamlined workflow for creating MRs on GitLab/GitHub, running pipelines, and requesting reviews via Slack.

## CRITICAL: Project Structure and Repository Information

**IMPORTANT: Before starting the workflow, Cline MUST determine the correct project ID from configuration:**

### Determining the Correct Project ID

**Step 1: Load repository configuration from workflow config**
```bash
# File: /Users/[USER_TGI]/Documents/Cline/Settings/cline_workflow_config.json
# Extract: gitlabConfig.repositories
```

**Step 2: Check current git remote**
```bash
git remote -v
# Extract the git URL from the output
```

**Step 3: Match git URL to repository configuration**
```
Compare git remote URL with gitlabConfig.repositories[*].gitUrl
If match found → Use that repository's projectId
If no match → Use gitlabConfig.projectId (default)
```

**Example matching process:**
- Git URL from `git remote -v`: `git@gitlab.example.com:team/project/repo.git`
- Compare with each entry in `gitlabConfig.repositories`
- If match found → Use that repository's `projectId`
- If no match → Use default `gitlabConfig.projectId`

### CI/CD Pipeline Information

**Pipeline Configuration:**
- Pipeline configuration is stored in `cline_workflow_config.json` under `pipelineConfig`
- The workflow automatically loads default variables from this configuration
- Some repositories may have CI/CD configuration files (e.g., `.gitlab-ci.yml`), others may not
- Check `gitlabConfig.repositories` to understand your repository structure

**Pipeline Behavior:**
- **Repositories without CI config**: Pipeline may fail or not trigger
- **Repositories with CI config**: Pipeline will run normally
- The workflow detects the correct project ID and pipeline configuration automatically

**Determining Pipeline Project:**
- The workflow automatically detects the correct project ID from workflow config
- Pipeline triggers use the project ID from the matched repository configuration
- If no match found, uses the default `gitlabConfig.projectId`

## Workflow Configuration

**IMPORTANT: Cline workflow configurations are stored in the Cline extension's settings directory.**

### Configuration File Location

```
/Users/[USER_TGI]/Documents/Cline/Settings/cline_workflow_config.json
```

### What Cline Looks For

Cline automatically reads from this file to find:

1. **GitLab Configuration** (`gitlabConfig`)
   - `GITLAB_PERSONAL_TOKEN` - Your GitLab API token
   - `GITLAB_API_URL` - GitLab API endpoint
   - `projectId` - Default project ID for MR operations
   - `defaultTargetBranch` - Default target branch for MRs
   - `repositories` - Repository-specific configurations with project IDs

2. **Slack Bot Configuration** (`mcpServers.slack.env`)
   - `SLACK_BOT_TOKEN` - Slack bot token for Slack Web API calls (`chat.postMessage`, etc.)

3. **Reviewer Mapping** (`reviewers`)
   - Maps reviewer keys to Slack/GitLab usernames and IDs
   - Each reviewer has: `slackUsername`, `slackUserId`, `gitlabUsername`, `gitlabUserId`, `name`

4. **Channel Mapping** (`channels`)
   - Maps channel keys to Slack channel names and IDs
   - Includes `defaultChannel` and `defaultChannelId`

5. **Pipeline Configuration** (`pipelineConfig`)
   - `defaultVariables` - Default pipeline variables
   - `variableOptions` - Valid options for each variable
   - `variableDescriptions` - Descriptions of what each variable does

### Example Configuration Structure

```json
{
  "mcpServers": {
    "slack": { ... },
    "gitlab": { ... }
  },
  "gitlabConfig": {
    "personalToken": "glpat-xxxxxxxxxxxxx",
    "apiUrl": "https://gitlab.example.com/api/v4",
    "projectId": "123",
    "defaultTargetBranch": "develop",
    "repositories": {
      "repo-name": {
        "projectId": "456",
        "path": "team/project/repo",
        "gitUrl": "git@gitlab.example.com:team/project/repo.git"
      }
    }
  },
  "slackConfig": {
    "webhookUrl": "https://hooks.slack.com/triggers/..." // NEVER USE THIS WEBHOOK URL UNLESS EXPLICITLY REQUESTED BY USER - workflow uses Slack bot token instead
  },
  "reviewers": {
    "reviewer-key": {
      "slackUsername": "@Reviewer Name",
      "slackUserId": "U123456",
      "gitlabUsername": "reviewer.name",
      "gitlabUserId": 100,
      "name": "Reviewer Full Name"
    }
  },
  "channels": {
    "channel-key": "#channel-name",
    "channel-keyChannelId": "C123456"
  },
  "pipelineConfig": {
    "projectId": 456,
    "apiUrl": "https://gitlab.example.com/api/v4",
    "defaultVariables": { ... },
    "variableOptions": { ... },
    "variableDescriptions": { ... }
  }
}
```

### How to Access This File

**Option 1: Via VS Code**
1. Open VS Code
2. Press `Cmd + Shift + P` (Mac) or `Ctrl + Shift + P` (Windows/Linux)
3. Type: `Open User Settings (JSON)`
4. Navigate to the Cline settings folder in the file explorer

**Option 2: Via Terminal**
```bash
# Mac/Linux
open "/Users/[USER_TGI]/Documents/Cline/Settings/"

# Windows
explorer "C:\Users\[USER_TGI]\Documents\Cline\Settings\"
```

**Option 3: Via File Manager**
1. Open Finder (Mac) or File Explorer (Windows)
2. Navigate to: `Documents/Cline/Settings/`
3. Open `cline_workflow_config.json`

### Important Notes

- **Cline automatically reads this file** - No additional setup needed
- **This is separate from VS Code settings** - Don't confuse with general VS Code settings
- **Keep tokens secure** - Never commit this file to Git
- **Reload Cline** - If you modify this file, reload VS Code for changes to take effect

## Important Configuration Loading

**CRITICAL: Cline MUST load the workflow configuration file at the START of the workflow to avoid back-and-forth:**

### Configuration File to Load

**File:** `/Users/[USER_TGI]/Documents/Cline/Settings/cline_workflow_config.json`

**Purpose:** Contains all workflow configurations including GitLab, Slack, reviewers, channels, and pipeline settings

**What to extract:**
```json
{
  "mcpServers": {
    "slack": {
      "env": {
        "SLACK_BOT_TOKEN": "xoxb-...",  // For Slack API calls (if needed)
        "SLACK_TEAM_ID": "T..."
      }
    },
    "gitlab": {
      "env": {
        "GITLAB_PERSONAL_TOKEN": "glpat-...",
        "GITLAB_API_URL": "https://gitlab.example.com/api/v4"
      }
    }
  },
  "gitlabConfig": {
    "projectId": "123",  // Default project ID
    "repositories": { ... }  // Repository-specific configs
  },
  "reviewers": { ... },  // Reviewer mappings
  "channels": { ... },  // Channel mappings
  "pipelineConfig": {
    "defaultVariables": { ... },  // Default pipeline variables
    "variableOptions": { ... },  // Valid options
    "variableDescriptions": { ... }  // Variable descriptions
  }
}
```

**Important for Slack bot messaging:**
- Mention the reviewer using Slack user IDs, not display names.
- Use: `<@U123456>` where the ID comes from `reviewers[key].slackUserId`.

**Cline's Workflow Process:**
1. **Load workflow config** → Get all configurations from single file
2. **Determine project ID** → Check git remote to identify correct project
3. **Resolve reviewer keys** → Map keys to IDs and usernames
4. **Load pipeline defaults** → Get default variables (if pipeline will run)
5. **Execute workflow** → Create MR, trigger pipeline (if applicable), send Slack message

## Workflow Steps (Detailed)

### Step 0: Pre-Flight Checks (CRITICAL - Do this FIRST)

**Before doing anything else, Cline MUST:**

1. **Check current working directory:**
   ```bash
   pwd
   ```

2. **Verify git repository:**
   ```bash
   git remote -v
   ```
   Extract the git URL to match against `gitlabConfig.repositories`

3. **Get current branch:**
   ```bash
   git branch --show-current
   ```
   This is the SOURCE branch for the MR

4. **Get latest commit:**
   ```bash
   git log -1 --pretty=format:"%H %s"
   ```
   This provides commit hash and message for MR description

5. **Check for existing MR (CRITICAL):**
   ```bash
   # ALWAYS unset proxy before GitLab curl requests
   unset http_proxy && unset https_proxy && unset HTTP_PROXY && unset HTTPS_PROXY && \
   curl "https://gitlab.example.com/api/v4/projects/[PROJECT_ID]/merge_requests?source_branch=[CURRENT_BRANCH]&state=opened" \
     -H "PRIVATE-TOKEN: [GITLAB_TOKEN]"
   ```
   
   **If MR exists:**
   - Extract: `iid` (MR number), `target_branch`, `web_url`
   - **WORKFLOW CHANGES TO: Update Existing MR** (see Step 0a below)
   
   **If no MR exists:**
   - **WORKFLOW CONTINUES TO: Create New MR** (proceed to Step 1)

### Step 0a: Update Existing MR Workflow (If MR Already Exists)

**When an existing MR is found, the workflow switches to updating it (NOT creating a new MR):**

1. **Push the latest changes to update the existing MR**

   GitLab MRs track branches; pushing to the MR source branch updates the MR automatically.

   ```bash
   git push origin [CURRENT_BRANCH]
   ```

2. **Summarize what changed since the last remote state (for the Slack thread update)**

   Prefer a short commit list; fall back to changed files if needed.

   ```bash
   # New commits (most useful for a review update)
   git log origin/[CURRENT_BRANCH]..HEAD --oneline

   # Or: changed files
   git diff --name-only origin/[CURRENT_BRANCH]..HEAD
   ```

3. **(Optional) Create/trigger a pipeline for the MR and gate the review request on its result**

   The pipeline step is **optional** (user may request `pipeline` / `skip pipeline`).

   - If pipeline is **triggered/created**:
     - If final status is `success` → proceed to Slack thread update + Jira transition.
     - If final status is anything else (`failed`, `canceled`, `skipped`, etc.) → **STOP** and **inform the developer**. **Do NOT** proceed with Slack review request update and **do NOT** transition Jira.
   - If pipeline is **skipped** → proceed directly to Slack thread update + Jira transition.

   **Option A: Rely on automatic pipeline on push**
   - Many repos auto-trigger CI on push.
   - In this case, determine the pipeline for the branch/MR and monitor it using the same polling strategy as in **Step 4c**.

   **Option B: Manually trigger a pipeline via API (when custom variables are required)**

   ```bash
   # ALWAYS unset proxy before GitLab curl requests
   unset http_proxy && unset https_proxy && unset HTTP_PROXY && unset HTTPS_PROXY && \
   curl -X POST "https://gitlab.example.com/api/v4/projects/[PROJECT_ID]/pipeline" \
     -H "PRIVATE-TOKEN: [GITLAB_TOKEN]" \
     -H "Content-Type: application/json" \
     -d '{
       "ref": "[CURRENT_BRANCH]",
       "variables": [
         {"key": "VARIABLE_NAME", "value": "VARIABLE_VALUE"}
       ]
     }'
   ```

   **Monitoring / decision point (mandatory if pipeline was triggered):**
   - Reuse the polling loop in **Step 4c**.
   - Apply the **Step 4d** decision rule (only proceed on `success`, unless user explicitly forces otherwise).

4. **Update the existing Slack review request by replying in the SAME thread**

   Requirement: update the request for review **in the reply thread of the same message** (not a new standalone message).

   **How to find the original thread:**
   - Fetch recent messages in the selected channel and locate the message whose `text` contains the MR URL.
   - Use that message’s `ts` as `thread_ts`.

   ```bash
   # COMPULSORY: Set proxy before ALL Slack API calls
   export http_proxy=http://proxy-sg-singapore.gemalto.com:8080 && \
   export https_proxy=http://proxy-sg-singapore.gemalto.com:8080 && \
   curl -s -X GET "https://slack.com/api/conversations.history?channel=[SLACK_CHANNEL_ID]&limit=200" \
     -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
     -H "Content-Type: application/json; charset=utf-8"
   ```

   **Update Message Format:**
   ```
   Message from: <@[DEVELEPER_NAME_SLACK_USER_ID]>
   Hello <@[REVIEWER_SLACK_USER_ID]>, I have made changes to the MR to include [CHANGES_MADE] for your review.
   CI: ([PIPELINE_STATUS]) [PIPELINE_URL]
   ```

   **Where [CHANGES_MADE] is:**
   - Summary of new commits (from git log)
   - Or list of changed files (from git diff)
   - Or user-provided description of changes

   **If the thread cannot be found:**
   - Ask the developer for the Slack `thread_ts` OR the original message link.
   - As a fallback (only if developer agrees), post a new message and clearly state the original thread could not be resolved.

   **Post the update reply in the original thread:**

   ```bash
   export http_proxy=http://proxy-sg-singapore.gemalto.com:8080 && \
   export https_proxy=http://proxy-sg-singapore.gemalto.com:8080 && \
   curl -s -X POST "https://slack.com/api/chat.postMessage" \
     -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
     -H "Content-Type: application/json; charset=utf-8" \
     -d '{
       "channel": "[SLACK_CHANNEL_ID]",
       "thread_ts": "[ORIGINAL_MESSAGE_TS]",
       "text": "Message from: <@[DEVELEPER_NAME_SLACK_USER_ID]>\nHello <@[REVIEWER_SLACK_USER_ID]>, I have made changes to the MR to include [CHANGES_MADE] for your review.\nCI: ([PIPELINE_STATUS]) [PIPELINE_URL]"
     }'
   ```

   **Pin the original MR review request message (recommended):**

   The original thread root message should already be pinned by this workflow for new MRs.
   For older threads (created before pinning was added), pinning the thread root keeps the request visible.

   ```bash
   export http_proxy=http://proxy-sg-singapore.gemalto.com:8080 && \
   export https_proxy=http://proxy-sg-singapore.gemalto.com:8080 && \
   curl -s -X POST "https://slack.com/api/pins.add" \
     -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
     -H "Content-Type: application/json; charset=utf-8" \
     -d '{
       "channel": "[SLACK_CHANNEL_ID]",
       "timestamp": "[ORIGINAL_MESSAGE_TS]"
     }'
   ```

5. **Mark the Jira sub-task as "Needs Review"**

   After the Slack thread update is posted (and pipeline gating passes if pipeline was run), proceed to **Step 6** to transition the matching Jira sub-task to **Needs Review**.

**Update message guidance:**
- `[CHANGES_MADE]`: prefer a short bullet list of new commits from `git log origin/[branch]..HEAD --oneline`.
- Mention reviewers using Slack user IDs: `<@U123456>`.

### Step 1: Load Workflow Configuration

**CRITICAL: Cline MUST use the read_file tool to load the configuration file directly:**

```
Use read_file tool:
  path: /Users/[USER_TGI]/Documents/Cline/Settings/cline_workflow_config.json

Extract all sections from the loaded file:
- mcpServers → Slack and GitLab tokens (especially `mcpServers.slack.env.SLACK_BOT_TOKEN`)
- gitlabConfig → Project IDs and repository mappings
- reviewers → Reviewer mappings
- channels → Channel mappings
- pipelineConfig → Pipeline defaults and options
```

**Why use read_file tool:**
- Direct file access eliminates back-and-forth
- Ensures complete configuration is loaded at once
- Reduces workflow execution time
- Provides immediate access to all required values

### Step 2: Determine Project ID

**Use the generic project ID detection from workflow config (already loaded in Step 1):**

1. **Get current git remote URL:**
   ```bash
   git remote -v
   ```
   
2. **Extract the git URL from output:**
   ```bash
   # Parse the output to get the fetch URL
   # Example: git@gitlab.example.com:team/project/repo.git
   ```

3. **Match URL to repository configuration:**
   - Compare git remote URL with each `gitlabConfig.repositories[*].gitUrl` (from loaded config)
   - If match found → Use that repository's `projectId`
   - If no match → Use `gitlabConfig.projectId` (default fallback)

**Example:**
- Git URL: `git@gitlab.example.com:team/project/repo.git`
- Matches: `gitlabConfig.repositories.repo-key.gitUrl`
- **Project ID:** Use `gitlabConfig.repositories.repo-key.projectId`

### Step 3: Create Merge Request (If MR Does Not Exist)

**Goal:** Create a new MR.

**CRITICAL: Before executing GitLab curl requests, ALWAYS unset proxy environment variables:**

```bash
unset http_proxy
unset https_proxy
unset HTTP_PROXY
unset HTTPS_PROXY
```

These unset commands are **COMPULSORY for all GitLab API requests** due to corporate network configuration.

#### Step 3a: Create the MR

**IMPORTANT: Break down into smaller commands to reduce waiting time:**

**Command 1: Unset proxy variables**
```bash
unset http_proxy
```

**Command 2: Unset https proxy**
```bash
unset https_proxy
```

**Command 3: Unset HTTP_PROXY**
```bash
unset HTTP_PROXY
```

**Command 4: Unset HTTPS_PROXY**
```bash
unset HTTPS_PROXY
```

**Command 5: Create the MR via API**
```bash
curl -X POST "https://gitlab.example.com/api/v4/projects/[PROJECT_ID]/merge_requests" \
  -H "PRIVATE-TOKEN: [GITLAB_TOKEN]" \
  -H "Content-Type: application/json" \
  -d '{
    "source_branch": "[CURRENT_BRANCH]",
    "target_branch": "[TARGET_BRANCH]",
    "title": "[BRANCH_NAME]: [COMMIT_MESSAGE]",
    "description": "[USER_NOTE]\n\nLatest commit: [COMMIT_MESSAGE]",
    "assignee_id": [GITLAB_DEVELOPER_USER_ID],
    "reviewer_ids": [[GITLAB_REVIEWER_USER_ID]],
    "remove_source_branch": true
  }'
```

**Where:**
- `[GITLAB_DEVELOPER_USER_ID]` - From `reviewers[developer-key].gitlabUserId` (auto-detected developer from GitLab API `/api/v4/user`)
- `[GITLAB_REVIEWER_USER_ID]` - From `reviewers[reviewer-key].gitlabUserId` (user-specified reviewer)

**How to get developer GitLab User ID:**
1. Call GitLab API to get authenticated user's name: `GET /api/v4/user`
2. Match the returned `name` field with `reviewers[*].name` in config
3. Extract the matching reviewer's `gitlabUserId`

**Extract from response:**
- `iid` → MR number
- `web_url` → MR URL
- `sha` → Commit hash

### Step 4: (Optional) Trigger Pipeline and Monitor Status

**Pipeline step is optional** (user may request `pipeline` / `skip pipeline`).

- If pipeline is **triggered/created**:
  - If final status is `success` → proceed to Slack notification + Jira transition.
  - If final status is anything else (`failed`, `canceled`, `skipped`, etc.) → **STOP** and **inform the developer**. **Do NOT** send Slack review request and **do NOT** transition Jira.
- If pipeline is **skipped** → proceed directly to Slack notification + Jira transition.

**IMPORTANT: Pipeline configuration is read directly from `.gitlab-ci.yml` file in the repository, NOT from workflow config.**

#### Step 4a: Read Pipeline Configuration from .gitlab-ci.yml

**IMPORTANT: File Path for .gitlab-ci.yml**

Cline will look for the `.gitlab-ci.yml` file in the **root directory of the current repository**.

**File Path:** `./.gitlab-ci.yml` (relative to current working directory)

**Example:**
- If current working directory is: `/Users/t0320661/Documents/repos/my-project`
- Cline will read: `/Users/t0320661/Documents/repos/my-project/.gitlab-ci.yml`

**Before triggering pipeline, Cline MUST read the .gitlab-ci.yml file:**

```bash
# Check if .gitlab-ci.yml exists in current repository root
if [ -f ".gitlab-ci.yml" ]; then
  echo "✅ Found .gitlab-ci.yml in repository root"
else
  echo "❌ No .gitlab-ci.yml found in repository root - pipeline cannot be triggered"
  exit 1
fi
```

**Read and parse .gitlab-ci.yml:**

```bash
# Use read_file tool to read .gitlab-ci.yml from repository root
# File path: ./.gitlab-ci.yml (relative to current working directory)
# Parse YAML to extract variables section
```

**What to extract from .gitlab-ci.yml:**
1. **Default Variables** - All variables defined in the `variables:` section
2. **Variable Options** - Inferred from comments (e.g., `# Options: all, android, ios`)
3. **Variable Descriptions** - Extracted from comments above variable definitions

**Example .gitlab-ci.yml:**
```yaml
variables:
  # Target platform for build
  PLATFORM: "all"  # Options: all, android, ios
  STAGE_TEST: "YES"  # Options: YES, NO
  VERSION: "1.0.0"
  dev_branch: "develop"
  libs_branch: "main"
  tools_branch: "main"
```

**Extracted configuration:**
- Variable: `PLATFORM`, Default: `all`, Options: `[all, android, ios]`
- Variable: `STAGE_TEST`, Default: `YES`, Options: `[YES, NO]`
- Variable: `VERSION`, Default: `1.0.0`
- Variable: `dev_branch`, Default: `develop`
- Variable: `libs_branch`, Default: `main`
- Variable: `tools_branch`, Default: `main`

**IMPORTANT: Default Branch Variable Overrides**

If the .gitlab-ci.yml file does NOT specify these branch variables, Cline MUST use these defaults:
- `dev_branch` → **Current branch** (from `git branch --show-current`)
- `libs_branch` → **main**
- `tools_branch` → **main**

**Merge with user-provided variables:**
- If user specified custom variables in their prompt, override the defaults
- Otherwise, use the defaults from .gitlab-ci.yml
- If branch variables are not in .gitlab-ci.yml, use the default overrides above

#### Step 4b: Trigger Pipeline

**IMPORTANT: Break down into smaller commands to reduce waiting time:**

**Command 1-4: Unset proxy variables**
```bash
unset http_proxy
```
```bash
unset https_proxy
```
```bash
unset HTTP_PROXY
```
```bash
unset HTTPS_PROXY
```

**Command 5: Trigger pipeline with variables**
```bash
curl -X POST "https://gitlab.example.com/api/v4/projects/[PROJECT_ID]/pipeline" \
  -H "PRIVATE-TOKEN: [GITLAB_TOKEN]" \
  -H "Content-Type: application/json" \
  -d '{
    "ref": "[CURRENT_BRANCH]",
    "variables": [
      {"key": "VARIABLE_NAME", "value": "VARIABLE_VALUE"},
      ...
    ]
  }'
```

**Where:**
- `[PROJECT_ID]` - From repository configuration (detected in Step 2)
- `[CURRENT_BRANCH]` - Current branch (from Step 0)
- Variables - From .gitlab-ci.yml merged with user-provided custom variables

**Extract from response:**
- `id` → Pipeline ID
- `web_url` → Pipeline URL
- `status` → Initial status

#### Step 4c: Monitor Pipeline Status

**IMPORTANT: Break down polling into smaller commands to reduce waiting time:**

**Command 1-4: Unset proxy for each poll iteration**
```bash
unset http_proxy
```
```bash
unset https_proxy
```
```bash
unset HTTP_PROXY
```
```bash
unset HTTPS_PROXY
```

**Command 5: Check pipeline status**
```bash
curl -s "https://gitlab.example.com/api/v4/projects/[PIPELINE_PROJECT_ID]/pipelines/[PIPELINE_ID]" \
  -H "PRIVATE-TOKEN: [GITLAB_TOKEN]"
```

**Command 6: Extract status from response**
```bash
echo '[RESPONSE]' | jq -r '.status'
```

**Polling Strategy:**
- Poll every 5 minutes with 2-hour timeout
- Break each poll iteration into separate commands
- Check status after each poll
- If status is `success`, `failed`, `canceled`, or `skipped` → stop polling
- If status is `created`, `pending`, `preparing`, or `running` → continue polling

**Pipeline Status Values:**
- `created`, `pending`, `preparing`, `running` - In progress
- `success` - ✅ Completed successfully
- `failed` - ❌ Failed
- `canceled` - Canceled by user
- `skipped` - Skipped

#### Step 4d: Decision Point (Required)

- If `status = "success"` → Proceed to Step 5 (send Slack notification) and then Step 6 (transition Jira to **Needs Review**)
- If `status != "success"` → **STOP**. Do **NOT** send the Slack review request, and do **NOT** transition Jira. Inform the developer that the pipeline did not succeed.

### Step 5: Send Slack Notification (Slack Bot)

**CRITICAL WARNING: NEVER USE THE SLACK WEBHOOK URL UNLESS EXPLICITLY REQUESTED BY USER.**

**Do NOT use Slack webhooks (`slackConfig.webhookUrl`).** Post the review request using Slack Web API (`chat.postMessage`) with the bot token stored in:
- `cline_workflow_config.json → mcpServers.slack.env.SLACK_BOT_TOKEN`

**Why use Slack Bot API instead of webhooks:**
- Bot API allows threading (required for MR updates)
- Bot API allows pinning messages
- Bot API provides better control and error handling
- Webhooks are legacy and should only be used if user explicitly requests it

**CRITICAL: ALWAYS set proxy environment variables IMMEDIATELY before Slack API curl requests:**

```bash
# COMPULSORY: Set proxy before ALL Slack API calls
export http_proxy=http://proxy-sg-singapore.gemalto.com:8080
export https_proxy=http://proxy-sg-singapore.gemalto.com:8080
```

#### Step 5a: Post the review request message

**IMPORTANT: Break down into smaller commands to reduce waiting time:**

**Inputs:**
- SLACK_BOT_TOKEN: from loaded config → mcpServers.slack.env.SLACK_BOT_TOKEN
- SLACK_CHANNEL_ID: from loaded config → channels.*ChannelId
- REVIEWER_SLACK_USER_ID: from loaded config → reviewers[key].slackUserId

**Command 1: Set http proxy**
```bash
export http_proxy=http://proxy-sg-singapore.gemalto.com:8080
```

**Command 2: Set https proxy**
```bash
export https_proxy=http://proxy-sg-singapore.gemalto.com:8080
```

**Command 3: Send Slack message**
```bash
curl -s -X POST "https://slack.com/api/chat.postMessage" \
  -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d '{
    "channel": "[SLACK_CHANNEL_ID]",
    "text": "Message from: <@[DEVELEPER_NAME_SLACK_USER_ID]>\nHello <@[REVIEWER_SLACK_USER_ID]>, please help me to review my MR for [DESCRIPTION]\nMR: [MR_URL]#[COMMIT_HASH]\nCI: ([PIPELINE_STATUS]) [PIPELINE_URL]\nNote: [NOTE]"
  }'
```

**Command 4: Extract message timestamp for pinning**
```bash
echo '[RESPONSE]' | jq -r '.ts'
```

#### Step 5b: Pin the Slack message in the channel (NEW)

**IMPORTANT: Break down into smaller commands to reduce waiting time:**

**Command 1: Set http proxy**
```bash
export http_proxy=http://proxy-sg-singapore.gemalto.com:8080
```

**Command 2: Set https proxy**
```bash
export https_proxy=http://proxy-sg-singapore.gemalto.com:8080
```

**Command 3: Pin the message using timestamp from Step 5a**
```bash
curl -s -X POST "https://slack.com/api/pins.add" \
  -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d '{
    "channel": "[SLACK_CHANNEL_ID]",
    "timestamp": "'"$MESSAGE_TS"'"
  }'
```

**Notes:**
- The bot must be a member of the target channel.
- Required scopes: `chat:write`, `pins:write` (and `conversations:read` only if you also search history / resolve channel IDs).
- If Slack returns `already_pinned`, treat it as success and continue.

### Step 6: Update Jira Sub-task Status to "Needs Review"

**IMPORTANT: Use the Atlassian MCP Server for Jira operations**

The workflow should use the Atlassian MCP Server tools instead of direct API calls for better reliability and authentication handling.

#### Step 6a: Get Current Branch Name

```bash
# Get current branch name (this will be used to match Jira sub-task)
CURRENT_BRANCH=$(git branch --show-current)
```

#### Step 6b: Search for Jira Sub-task

**Use the MCP server tool to search for sub-task:**

```
Use MCP tool: cYvCIC0mcp0jira_search
Parameters:
  - jql: "summary ~ \"${CURRENT_BRANCH}\" AND issuetype = Sub-task"
  - fields: "key,summary,status"
  - limit: 1
```

**Extract from response:**
- `issues[0].key` → Jira issue key (e.g., "PROJ-123")
- `issues[0].fields.summary` → Issue summary (should match branch name)
- `issues[0].fields.status.name` → Current status

**Validation:**
- If no issues found → Log warning and skip status update
- If multiple issues found → Use the first match
- If issue found → Proceed to status update

#### Step 6c: Get "Needs Review" Transition ID

**Use the MCP server tool to get available transitions:**

```
Use MCP tool: cYvCIC0mcp0jira_get_transitions
Parameters:
  - issue_key: "${JIRA_ISSUE_KEY}"
```

**Extract from response:**
- Find transition where `name` = "Needs Review" (or similar)
- Extract `id` → Transition ID

**Common transition names to look for:**
- "Needs Review"
- "Ready for Review"
- "In Review"
- "Review"

#### Step 6d: Update Sub-task Status

**Use the MCP server tool to transition the sub-task:**

```
Use MCP tool: cYvCIC0mcp0jira_transition_issue
Parameters:
  - issue_key: "${JIRA_ISSUE_KEY}"
  - transition_id: "${TRANSITION_ID}"
  - comment: "MR created and review requested"
```

**Success criteria:**
- Tool returns success → Status updated successfully
- Tool returns error → Log error and continue

**Where variables come from:**
- `CURRENT_BRANCH` - From git branch --show-current
- `JIRA_ISSUE_KEY` - From MCP search response (Step 6b)
- `TRANSITION_ID` - From MCP transitions response (Step 6c)

**Example workflow:**
1. Get branch name: `hotfix_add_global_workflows`
2. Search Jira: `cYvCIC0mcp0jira_search` with JQL `summary ~ "hotfix_add_global_workflows" AND issuetype = Sub-task`
3. Extract issue key: `PROJ-123`
4. Get transitions: `cYvCIC0mcp0jira_get_transitions` for `PROJ-123`
5. Find "Needs Review" transition ID: `31`
6. Transition issue: `cYvCIC0mcp0jira_transition_issue` with issue_key=`PROJ-123`, transition_id=`31`

**CRITICAL: Slack mentions**
- Mention the reviewer using Slack user IDs: `<@U123456>`
- Use `reviewers[key].slackUserId` (not display names) to ensure reliable @mentions

**Where variables come from:**
- `SLACK_BOT_TOKEN` - From `mcpServers.slack.env.SLACK_BOT_TOKEN`
- `SLACK_CHANNEL_ID` - From `channels.*ChannelId` (e.g., `defaultChannelId`, `mobileChannelId`, etc.)
- `DEVELOPER_NAME` - Auto-detected from GitLab user profile via `/api/v4/user` endpoint using the personal token (e.g., "Jolyn Leow")
- `DEVELOPER_SLACK_USER_ID` - Auto-matched by finding the developer's name in `reviewers[*].name` and extracting their `slackUserId`
  - **How it works:** Cline calls GitLab API to get the authenticated user's name, then searches through all reviewers in the config to find a matching `name` field
  - **Example:** If GitLab returns name "Jolyn Leow", Cline matches it with:
    ```json
    "jolyn": {
      "slackUsername": "@Jolyn Leow",
      "slackUserId": "U099MQ972PJ",  // <-- This is used as DEVELOPER_SLACK_USER_ID
      "gitlabUsername": "jolyn.leow",
      "gitlabUserId": 200,  // <-- This is used as GITLAB_DEVELOPER_USER_ID (assignee_id)
      "name": "Jolyn Leow"  // <-- Matched against GitLab user name
    }
    ```
  - **Important:** The developer must be listed in the `reviewers` configuration for auto-detection to work
- `GITLAB_DEVELOPER_USER_ID` - From the same matched reviewer entry as `DEVELOPER_SLACK_USER_ID`, using `gitlabUserId` field (e.g., 200)
- `REVIEWER_SLACK_USER_ID` - From `reviewers[key].slackUserId` (e.g., "U123456")
- `GITLAB_REVIEWER_USER_ID` - From `reviewers[key].gitlabUserId` (e.g., 100)
- `MR_URL` - From MR creation response
- `COMMIT_HASH` - From git log
- `PIPELINE_URL` - From pipeline trigger response (or "N/A" if not triggered)
- `PIPELINE_STATUS` - From pipeline monitoring (or "not triggered")
- `DESCRIPTION` - **Default:** MR description from GitLab (same as what was set in Step 3). **Override:** If user specifies description in their prompt, use the user-specified description instead.
- `NOTE` - **Default:** "N/A". **Override:** If user specifies note in their prompt, use the user-specified note instead.

**Important for Description and Note fields:**
- **Description field:**
  - By default, uses the MR description that was created in GitLab (Step 3)
  - If user provides description in their prompt (e.g., "description added global workflows"), use that instead
  - This allows users to provide a different description for Slack than what's in GitLab if needed
  
- **Note field:**
  - By default, set to "N/A" if user doesn't specify
  - If user provides note in their prompt (e.g., "note Updated authentication logic"), use that value
  - This is for additional context that may not be in the MR description

**Example with actual values:**
```bash
# ALWAYS set proxy before Slack curl requests
export http_proxy=http://proxy-sg-singapore.gemalto.com:8080 && \
export https_proxy=http://proxy-sg-singapore.gemalto.com:8080 && \
curl -s -X POST "https://slack.com/api/chat.postMessage" \
  -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d '{
    "channel": "C09RFR3CVGF",
    "text": "Message from: <@U099MQ972PJ>\nHello <@U09PCCM40JW>, please help me to review my MR for Add authentication feature\nMR: https://gitlab.example.com/project/repo/-/merge_requests/123#abc1234\nCI: (not triggered) N/A\nNote: Added OAuth integration"
  }'
```

**Note:** The `$SLACK_BOT_TOKEN` comes from `mcpServers.slack.env.SLACK_BOT_TOKEN` in the workflow configuration file.

**Jira Configuration:**
- Atlassian MCP Server handles authentication automatically
- The workflow will automatically find and update the sub-task matching the current branch name
- MCP server configuration is in `cline_workflow_config.json` under `mcpServers.mcp-atlassian`

## Usage Examples

### Example 1: Basic Interactive Mode

```
User: request review

Cline: Loading configuration from cline_workflow_config.json...
      ✅ Configuration loaded
      
      Current branch: feature/auth-update
      Detected project ID: 456 (from repository config)
      
      What's the target branch?

User: develop

Cline: Who should review this MR? (Available: john, sarah, mike)

User: john

Cline: Which Slack channel? (Available: mobile, backend, test)

User: mobile

Cline: Creating MR...
      ✅ MR #123 created
      
      Triggering pipeline with default variables...
      ✅ Pipeline #456 running
      
      Monitoring pipeline status...
      Status: running (checking every 5 minutes)
      
      [After completion...]
      ✅ Pipeline succeeded!
      
      Sending Slack notification...
      ✅ Message sent to #mobile-reviews!
      
      Updating Jira sub-task status...
      ✅ Found sub-task: PROJ-123 (feature/auth-update)
      ✅ Status updated to "Needs Review"
```

### Example 2: All Details Upfront

```
User: request review to develop reviewer john channel mobile note "Updated authentication logic"

Cline: Loading configuration...
      ✅ Config loaded
      
      Detected project ID: 456
      Resolved reviewer: John Doe (GitLab ID: 100, Slack: @John Doe)
      Resolved channel: #mobile-reviews (ID: C123456)
      
      Creating MR...
      ✅ MR #123 created
      
      Triggering pipeline...
      ✅ Pipeline #456 running
      
      Monitoring...
      ✅ Pipeline succeeded!
      
      Sending Slack notification...
      ✅ Complete!
      
      Updating Jira sub-task status...
      ✅ Found sub-task: PROJ-456 (feature/auth-update)
      ✅ Status updated to "Needs Review"
```

### Example 3: Custom Pipeline Variables

```
User: request review to develop reviewer john channel mobile pipeline PLATFORM=android STAGE_TEST=YES STAGE_COVERAGE=NO

Cline: Loading configuration...
      ✅ Config loaded
      
      Loading pipeline defaults from pipelineConfig.defaultVariables...
      Merging with custom variables:
      - PLATFORM=android
      - STAGE_TEST=YES
      - STAGE_COVERAGE=NO
      
      Validating against pipelineConfig.variableOptions...
      ✅ All variables valid
      
      Creating MR...
      ✅ MR #123 created
      
      Triggering pipeline with custom variables...
      ✅ Pipeline #456 running (Android only, TEST stage only)
      
      Monitoring...
      ✅ Pipeline succeeded!
      
      Sending Slack notification...
      ✅ Complete!
      
      Updating Jira sub-task status...
      ✅ Found sub-task: PROJ-789 (feature/auth-update)
      ✅ Status updated to "Needs Review"
```

### Example 4: Updating Existing MR

```
User: request review

Cline: Loading configuration...
      ✅ Config loaded
      
      Checking for existing MR...
      ✅ Found existing MR #123: feature/auth-update → develop
      
      Detecting new changes...
      New commits:
      - abc1234 Fix memory leak
      - def5678 Add unit tests
      
      Pushing changes...
      ✅ Changes pushed
      
      Pipeline triggered automatically...
      ✅ Pipeline #457 running
      
      Monitoring...
      ✅ Pipeline succeeded!
      
      Finding original Slack message...
      ✅ Found in #mobile-reviews
      
      Posting update in thread...
      ✅ Thread reply sent!
      
      "Hello @John Doe, I have made changes to the MR to include:
      - Fix memory leak
      - Add unit tests
      
      for your review.
      
      MR: https://gitlab.example.com/.../merge_requests/123#abc1234
      CI: (success) https://gitlab.example.com/.../pipelines/457"
      
      Updating Jira sub-task status...
      ✅ Found sub-task: PROJ-123 (feature/auth-update)
      ✅ Status updated to "Needs Review"
```

## Configuration File Structure

**Complete structure of `cline_workflow_config.json`:**

```json
{
  "mcpServers": {
    "slack": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-slack"],
      "env": {
        "SLACK_BOT_TOKEN": "xoxb-...",
        "SLACK_TEAM_ID": "T..."
      }
    },
    "gitlab": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-gitlab"],
      "env": {
        "GITLAB_PERSONAL_TOKEN": "glpat-...",
        "GITLAB_API_URL": "https://gitlab.example.com/api/v4"
      }
    }
  },
  "gitlabConfig": {
    "personalToken": "glpat-...",
    "apiUrl": "https://gitlab.example.com/api/v4",
    "projectId": "123",
    "defaultTargetBranch": "develop",
    "repositories": {
      "repo-key": {
        "projectId": "456",
        "path": "team/project/repo",
        "gitUrl": "git@gitlab.example.com:team/project/repo.git"
      }
    }
  },
  "slackConfig": {
    "webhookUrl": "https://hooks.slack.com/triggers/..."
  },
  "reviewers": {
    "reviewer-key": {
      "slackUsername": "@Reviewer Name",
      "slackUserId": "U123456",
      "gitlabUsername": "reviewer.name",
      "gitlabUserId": 100,
      "name": "Reviewer Full Name"
    }
  },
  "channels": {
    "defaultChannel": "#default-channel",
    "defaultChannelId": "C789012",

    "channel-key": "#channel-name",
    "channel-keyChannelId": "C123456"
  },
  "pipelineConfig": {
    "projectId": 456,
    "apiUrl": "https://gitlab.example.com/api/v4",
    "defaultVariables": {
      "VARIABLE_NAME": "default_value"
    },
    "variableOptions": {
      "VARIABLE_NAME": ["option1", "option2", "option3"]
    },
    "variableDescriptions": {
      "VARIABLE_NAME": "Description of what this variable does"
    }
  }
}
```

## Important Notes

1. **Configuration Loading** - Always load `cline_workflow_config.json` at the start
2. **Generic Paths** - Use `/Users/[USER_TGI]/Library/Application Support/...` format
3. **Project ID Detection** - Match git remote URL to repository config
4. **Proxy Handling for GitLab** - Always unset proxy for GitLab API calls
5. **Proxy Handling for Slack** - **ALWAYS set proxy IMMEDIATELY before Slack API curl requests**
6. **Slack Mentions** - Use Slack user IDs (`<@U123456>`), not display names
7. **Pipeline Monitoring** - Wait for completion before sending Slack notification
8. **Configuration Updates** - Reload VS Code after modifying config file

## Troubleshooting

**Issue: Configuration not found**
- Check file path: `/Users/[USER_TGI]/Documents/Cline/Settings/cline_workflow_config.json`
- Verify file exists and is readable

**Issue: Project ID not detected**
- Check `git remote -v` output
- Verify git URL matches an entry in `gitlabConfig.repositories[*].gitUrl`
- If no match, default `gitlabConfig.projectId` will be used

**Issue: Reviewer not found**
- Check reviewer key exists in `reviewers` section
- Verify key spelling matches exactly

**Issue: Pipeline fails to trigger**
- Check `pipelineConfig.projectId` is correct
- Verify repository has CI/CD configuration
- Check GitLab token has pipeline trigger permissions

**Issue: Slack message not sent**
- Verify `mcpServers.slack.env.SLACK_BOT_TOKEN` is set
- Ensure the bot has `chat:write` scope
- Ensure the bot is invited to the target channel
- Ensure pipeline succeeded (or use "force send" to override)

**Issue: Jira sub-task not found**
- Verify branch name matches Jira sub-task summary exactly
- Check Jira bearer token is valid and has read permissions
- Verify sub-task exists in Jira (not a regular task or story)
- Check JQL query syntax is correct
- Ensure proxy is unset before Jira API calls

**Issue: Jira status not updated**
- Verify bearer token has write permissions
- Check "Needs Review" transition exists for the sub-task
- Verify transition ID is correct
- Check sub-task workflow allows transition to "Needs Review"
- Ensure proxy is unset before Jira API calls
- Verify current status allows transition to "Needs Review"
