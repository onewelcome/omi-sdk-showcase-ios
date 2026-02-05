# Jira Ticket to Codebase Analysis Workflow

## Overview

This workflow automates the process of analyzing customer Jira tickets and identifying potential areas in the codebase that need work to resolve the issue. It processes tickets from Jira, analyzes the issue description, and directs developers to specific files, modules, or components that may need attention.

## Trigger Commands

**Primary Command Format:**
```
Analyze Jira ticket [TICKET-ID] and identify improvements in [PROJECT-NAME]
```

**Alternative Commands:**
- `analyze jira [TICKET-ID] in [PROJECT-NAME]`
- `jira codebase analysis [TICKET-ID] for [PROJECT-NAME]`
- `find code for jira [TICKET-ID] in [PROJECT-NAME]`

**Examples:**
```
Analyze Jira ticket SASMOB-11163 and identify improvements in idpoath
analyze jira MOBILE-456 in mobile-app
jira codebase analysis BACKEND-789 for backend-api
```

## Workflow Steps

### 0. Determine Target Repository

**Cline determines the target repository from the project name specified in your command.**

**Command Format:**
```
Analyze Jira ticket [TICKET-ID] and identify improvements in [PROJECT-NAME]
```

**How It Works:**

1. **User specifies project name** in the command (e.g., "idpoath", "mobile-app")
2. **Cline looks up the project** in `cline_workflow_config.json` under `jiraConfig.projects`
3. **Cline uses the repository path** configured for that project
4. **If project not found**, Cline asks for the repository path

**Configuration Location:**

Project configurations are stored in: `~/.cline/Settings/cline_workflow_config.json`

Under the `jiraConfig.projects` section, add repository information for each project.

**Configuration Format:**

```json
{
  "jiraConfig": {
    "baseUrl": "https://jira.gemalto.com",
    "email": "your.email@company.com",
    "apiToken": "your-api-token",
    "defaultProject": "SASMOB",
    "projects": {
      "SASMOB": {
        "projectKey": "SASMOB",
        "name": "EZIO SDK",
        "repositoryPath": "/Users/username/dev/idpoath",
        "sourceDirectory": "src/main/java"
      },
      "MSIL": {
        "projectKey": "MSIL",
        "name": "MSIL",
        "repositoryPath": "/Users/username/dev/mobile-app",
        "sourceDirectory": "app/src"
      }
    }
  }
}
```

**Repository Detection Flow:**

```
User: Analyze Jira ticket SASMOB-11163 and identify improvements in SASMOB

Cline: Analyzing Jira ticket SASMOB-11163...
      
      Step 1: Looking up project 'SASMOB' in cline_workflow_config.json...
      ✅ Found project configuration
      ✅ Project: EZIO SDK
      ✅ Repository: /Users/username/dev/idpoath
      ✅ Source directory: src/main/java
      
      Step 2: Fetching ticket information from Jira...
      [Continues with analysis...]
      
      OR (if repository path not configured):
      
      ⚠️  Project 'SASMOB' found but no repository path configured
      
      Please provide the repository path for 'SASMOB':
      
      User: /Users/username/dev/idpoath
      
      Cline: ✅ Using repository: /Users/username/dev/idpoath
            Would you like me to update the configuration? (yes/no)
      
      User: yes
      
      Cline: ✅ Configuration updated in cline_workflow_config.json
            You can now use: "Analyze Jira ticket [ID] in SASMOB"
```

**Example Usage:**

```bash
# Using Jira project key from config
Analyze Jira ticket SASMOB-11163 and identify improvements in SASMOB

# Using another project
analyze jira MSIL-456 in MSIL

# Short form
jira SASMOB-789 for SASMOB
```

### 1. Fetch Jira Ticket Information

**Input Required:**
- Jira ticket URL or ticket ID (e.g., `PROJECT-123`)
- Jira filter URL (optional, e.g., `https://your-jira.com/browse/PROJECT-123?filter=12345`)

**Actions:**
1. Extract ticket ID from URL or use provided ID
2. **Fetch ticket details using Atlassian MCP server tools** (e.g., `jira_get_issue`)
3. Extract key information:
   - Title/Summary
   - Description
   - Issue Type (Bug, Feature, Task, etc.)
   - Priority
   - Components affected
   - Labels/Tags
   - Comments (especially from customers)
   - Attachments (logs, screenshots)

**Example Using Atlassian MCP Server:**

```
<use_mcp_tool>
<server_name>mcp-atlassian</server_name>
<tool_name>jira_get_issue</tool_name>
<arguments>
{
  "issue_key": "PROJECT-123",
  "fields": "summary,description,issuetype,priority,components,labels,comment"
}
</arguments>
</use_mcp_tool>
```

**Note:** The Atlassian MCP server handles authentication automatically through its configuration. No need to manually manage tokens or API calls.

### 2. Analyze Ticket Content

**Analysis Focus:**
- **Keywords Extraction:** Identify technical terms, error messages, feature names
- **Component Identification:** Determine which modules/components are mentioned
- **Error Patterns:** Look for stack traces, error codes, exception messages
- **Feature Context:** Understand what functionality is affected
- **Platform/Environment:** Identify if it's iOS, Android, specific SDK version, etc.

**Example Analysis:**
```
Ticket: PROJECT-123
Title: "Feature X fails under condition Y"
Keywords: Feature X, condition Y, failure, error message
Components: Module A, Component B
Error Pattern: "ExceptionType: Error message"
Platform/Environment: Specific platform or version
```

### 3. Map to Codebase Areas

**Mapping Strategy:**

1. **Search by Keywords:**
   - Use `search_files` tool to find files containing ticket keywords
   - Search for error messages in code
   - Look for component/module names

2. **Analyze File Structure:**
   - Use `list_code_definition_names` to understand code organization
   - Identify relevant classes, functions, methods

3. **Check Related Files:**
   - Find files that import/use identified components
   - Look for test files related to the issue
   - Check configuration files

**Example Search:**
```bash
# Search for feature-related code
search_files path="src" regex="FeatureName|KeywordFromTicket" file_pattern="*.<ext>"

# Search for error patterns
search_files path="src" regex="ExceptionType|ErrorMessage"

# Search for component/module code
search_files path="src" regex="ComponentName|ModuleName"
```

### 4. Prioritize Code Areas

**Prioritization Criteria:**

1. **Direct Matches:** Files that directly match ticket keywords (highest priority)
2. **Component Files:** Files in the affected component/module
3. **Related Functionality:** Files that implement related features
4. **Test Files:** Corresponding test files for the affected areas
5. **Configuration:** Relevant configuration or manifest files

**Priority Levels:**
- 🔴 **Critical:** Direct match with error/feature mentioned in ticket
- 🟡 **High:** Component/module files that likely need changes
- 🟢 **Medium:** Related functionality that might be affected
- ⚪ **Low:** Peripheral files for context/reference

### 5. Generate Developer Guidance

**Output Format:**

```markdown
## Jira Ticket Analysis: <TICKET-ID>

### Ticket Summary
- **Title:** [Ticket title]
- **Type:** [Bug/Feature/Task/etc.]
- **Priority:** [Priority level]
- **Components:** [Affected components]

### Issue Description
[Brief summary of the issue from ticket]

### Recommended Code Areas to Investigate

#### 🔴 Critical Priority
1. **path/to/file1.ext**
   - Brief description of what this file does
   - Line X: Specific area of interest
   - Reason: Why this file is critical

2. **path/to/file2.ext**
   - Brief description
   - Reason: Connection to the issue

#### 🟡 High Priority
3. **path/to/file3.ext**
   - Brief description
   - Reason: Related functionality

4. **path/to/config.ext**
   - Configuration file
   - Reason: May need updates

#### 🟢 Medium Priority
5. **path/to/related-file.ext**
   - Related functionality
   - Reason: Indirect connection

6. **tests/path/to/test-file.ext**
   - Test file
   - Reason: May need new test cases

### Suggested Investigation Steps

1. **Review Primary Component:**
   - Check main files for compatibility/correctness
   - Verify implementation matches requirements

2. **Check Related Components:**
   - Review configuration files
   - Verify integration points

3. **Test Thoroughly:**
   - Run existing tests
   - Add specific test cases for the issue

4. **Review Recent Changes:**
   - Check git history for recent changes
   - Look for related issues or PRs

### Related Documentation
- [Relevant documentation link 1]
- [Relevant documentation link 2]

### Next Steps
1. Start with Critical Priority files
2. Reproduce the issue locally
3. Implement fix in identified areas
4. Add/update tests
5. Verify the fix works
```

## Implementation Example

### User Request:
```
User: Analyze Jira ticket SASMOB-11163 and identify improvements in SASMOB
```

### Cline Response Flow:

```
Cline: I'll analyze Jira ticket SASMOB-11163 for the SASMOB project.

Step 1: Looking up project configuration in cline_workflow_config.json...
✅ Found project: EZIO SDK (SASMOB)
✅ Repository: /Users/username/dev/idpoath
✅ Source directory: src/main/java

Step 2: Fetching ticket information from Jira...
[Executes API call to https://jira.gemalto.com]

Ticket Details:
- Title: OAuth authentication fails on Android 14
- Type: Bug
- Priority: High
- Description: Users report authentication failures on Android 14 devices...

Step 3: Analyzing ticket content...
Keywords identified: OAuth, authentication, Android 14, SecurityException
Components: Authentication module

Step 4: Searching codebase in /Users/username/dev/idpoath...
[Uses search_files to find relevant code]

Found 8 relevant files:
- src/main/java/auth/OAuthProvider.java (Direct match)
- src/main/java/auth/AndroidAuthManager.java (Platform specific)
- src/main/java/permissions/PermissionHandler.java (Error related)
- AndroidManifest.xml (Configuration)
- [... more files ...]

Step 5: Generating analysis report...
[Creates prioritized list with recommendations]

Would you like me to:
1. Show detailed analysis of the top priority files?
2. Create a branch to start working on the fix?
3. Search for similar resolved issues?
```

## Configuration

### Required Environment Variables

```bash
# Jira API access
export JIRA_URL="https://your-jira-instance.com"
export JIRA_TOKEN="your-jira-api-token"
export JIRA_EMAIL="your-email@company.com"

# Project-specific settings (optional)
export PROJECT_ROOT="/path/to/project"
export SOURCE_DIR="src"  # or your source directory name
```

### Setting Up Project Configuration

**Step 1: Open configuration file**

Edit the file at: `~/.cline/Settings/cline_workflow_config.json`

**Step 2: Add repository paths to your Jira projects**

Locate the `jiraConfig.projects` section and add `repositoryPath` and `sourceDirectory` to each project:

```json
{
  "jiraConfig": {
    "baseUrl": "https://jira.gemalto.com",
    "email": "your.email@company.com",
    "apiToken": "your-api-token",
    "defaultProject": "SASMOB",
    "projects": {
      "PROJECT-KEY": {
        "projectKey": "PROJECT-KEY",
        "name": "Project Name",
        "repositoryPath": "/absolute/path/to/repository",
        "sourceDirectory": "src"
      }
    }
  }
}
```

**Step 3: Test the configuration**

```bash
# Test with a command
Analyze Jira ticket PROJECT-123 and identify improvements in PROJECT-KEY
```

**Complete Configuration Example:**

```json
{
  "jiraConfig": {
    "baseUrl": "https://jira.gemalto.com",
    "email": "jolyn.leow@thalesgroup.com",
    "apiToken": "your-api-token",
    "defaultProject": "SASMOB",
    "projects": {
      "SASMOB": {
        "projectKey": "SASMOB",
        "name": "EZIO SDK",
        "repositoryPath": "/Users/username/dev/idpoath",
        "sourceDirectory": "src/main/java"
      },
      "MSIL": {
        "projectKey": "MSIL",
        "name": "MSIL",
        "repositoryPath": "/Users/username/dev/mobile-app",
        "sourceDirectory": "app/src"
      },
      "BACKEND": {
        "projectKey": "BACKEND",
        "name": "Backend Services",
        "repositoryPath": "/Users/username/dev/backend-api",
        "sourceDirectory": "src"
      }
    }
  }
}
```

**Configuration Fields:**

- **projectKey** (required): Jira project key (e.g., "SASMOB")
- **name** (required): Human-readable project name
- **repositoryPath** (required for codebase analysis): Absolute path to the repository
- **sourceDirectory** (optional): Main source code directory, defaults to "src"

### Jira API Authentication

**IMPORTANT: Use the Atlassian MCP server for all Jira access**

The Atlassian MCP server is configured with proper authentication and provides dedicated tools for Jira operations:

- `jira_get_issue` - Get ticket details
- `jira_search` - Search for tickets using JQL
- `jira_get_project_issues` - Get all issues in a project
- `jira_update_issue` - Update ticket information
- And many more...

**Why Atlassian MCP Server?**
- Handles authentication automatically through MCP configuration
- Provides type-safe, structured access to Jira data
- More reliable than direct API calls
- No need to manage tokens or API endpoints manually
- Built-in error handling and validation

**Configuration:** The MCP server is configured in `~/.cline/Settings/cline_mcp_settings.json` with environment variables:
- `JIRA_URL` - Your Jira instance URL
- `JIRA_PERSONAL_TOKEN` - Your Jira API token

## Advanced Features

### 1. Batch Analysis

Analyze multiple tickets from a filter:

```
User: analyze jira filter <FILTER-ID>

Cline: I'll analyze all tickets in filter <FILTER-ID>...
      Found X tickets. Analyzing each...
      
      Summary:
      - X tickets related to [category 1]
      - X tickets related to [category 2]
      - X tickets related to [category 3]
      
      Top code areas needing attention:
      1. path/to/module1/ (X tickets)
      2. path/to/module2/ (X tickets)
      3. path/to/module3/ (X tickets)
```

### 2. Historical Analysis

Compare with previously resolved tickets:

```
User: analyze jira <TICKET-ID> and compare with similar resolved tickets

Cline: Analyzing <TICKET-ID>...
      
      Found X similar resolved tickets:
      - TICKET-A: Similar issue description (Resolved)
      - TICKET-B: Related problem (Resolved)
      
      Common fix patterns:
      1. [Pattern 1 from historical fixes]
      2. [Pattern 2 from historical fixes]
      3. [Pattern 3 from historical fixes]
      
      Recommended approach based on history:
      [... suggestions ...]
```

### 3. Impact Analysis

Estimate impact of potential changes:

```
Cline: Impact Analysis for <TICKET-ID>:
      
      Files to modify: X
      Estimated complexity: [Low/Medium/High]
      Affected features: [Feature list]
      Test coverage: X% ([good/needs improvement])
      
      Risk assessment:
      - [Risk level]: [Risk description]
      - [Risk level]: [Risk description]
      
      Recommended testing:
      - Unit tests: [Test files]
      - Integration tests: [Test files]
      - Manual testing: [Testing scenarios]
```

## Integration with Other Workflows

### With Git Workflows

```
User: analyze jira <TICKET-ID> and create a branch

Cline: [Analyzes ticket]
      [Creates branch: fix/<TICKET-ID>-brief-description]
      
      Branch created and ready for work!
      Recommended files to start with:
      1. path/to/critical-file1
      2. path/to/critical-file2
```

### With MR Review

```
User: analyze jira <TICKET-ID> and check if MR <MR-ID> addresses it

Cline: [Analyzes ticket]
      [Reviews MR <MR-ID>]
      
      MR <MR-ID> Coverage:
      ✅ Addresses [issue aspect 1]
      ✅ Updates [issue aspect 2]
      ⚠️  Missing: [Missing aspect]
      
      Recommendation: [Approval recommendation]
```

## Best Practices

1. **Always verify ticket details** before starting code analysis
2. **Search broadly first** then narrow down to specific files
3. **Consider related components** not just direct matches
4. **Check git history** for similar issues and their fixes
5. **Prioritize based on ticket severity** and component criticality
6. **Document findings** for future reference
7. **Verify with tests** that identified areas are correct

## Troubleshooting

### Issue: Wrong repository being analyzed

**Solution:**
1. Verify the project name in your command matches the `projectKey` in config
2. Check `cline_workflow_config.json` has correct `repositoryPath`
3. Ensure repository path exists and is accessible

**Example:**
```bash
# Check the configuration
cat ~/.cline/Settings/cline_workflow_config.json | grep -A 5 "SASMOB"

# Verify repository exists
ls -la /Users/username/dev/idpoath
```

### Issue: Project not found in configuration

**Solution:**
1. Open `~/.cline/Settings/cline_workflow_config.json`
2. Add the project under `jiraConfig.projects`
3. Include `repositoryPath` and `source

### Issue: Cannot access Jira via MCP server

**Solution:**
1. Verify Atlassian MCP server is configured in `cline_mcp_settings.json`
2. Check environment variables: `JIRA_URL` and `JIRA_PERSONAL_TOKEN`
3. Verify MCP server is running: Check the MCP servers list in Cline
4. Test with a simple command: `jira_get_issue` with a known ticket
5. Check network connectivity to Jira server
6. Verify API token has correct permissions

### Issue: Too many search results

**Solution:**
1. Refine search keywords based on ticket specifics
2. Limit search to specific directories (e.g., src/auth)
3. Use more specific file patterns
4. Filter by file modification date

### Issue: No relevant files found

**Solution:**
1. Broaden search terms
2. Search in test directories
3. Check configuration files
4. Look for related feature implementations
5. Ask user for codebase context

## Example Use Cases

### Use Case 1: Bug Fix

```
Ticket: PROJECT-123 - Feature X fails under condition Y
Result: Identified X critical files in relevant module
Action: Created fix branch, updated code, added tests
```

### Use Case 2: Feature Request

```
Ticket: PROJECT-456 - Add new feature Z
Result: Identified module structure, found integration points
Action: Planned implementation across X files, created design doc
```

### Use Case 3: Performance Issue

```
Ticket: PROJECT-789 - Slow operation in component A
Result: Found performance bottleneck, identified optimization opportunities
Action: Optimized implementation, added performance tests
```

## Related Documentation

- [Jira Ticket Creation Workflow](./jira-ticket-creation.md)
- [MR Review Workflow](./mr-review.md)
- [Git Workflows](./README.md)

---

**Remember:** This workflow helps you quickly identify where to start working on a Jira ticket. Always verify the analysis results and use your judgment when implementing fixes!
