# Jira Ticket Search Workflow

**Trigger Commands:**
- `search jira ticket`
- `jira search`
- `find jira ticket`
- `search ticket`

**Description:**
Automated workflow for searching Jira tickets in the project using various search criteria. This workflow streamlines the manual process of finding tickets by allowing quick searches based on ticket key, summary, status, assignee, or JQL queries.

## Overview

This workflow automates Jira ticket searches by:
1. Accepting search criteria from the user
2. Constructing appropriate JQL (Jira Query Language) queries
3. Executing searches via Atlassian MCP server
4. Displaying formatted search results with key information

## Prerequisites

### 1. Atlassian MCP Server

**IMPORTANT: This workflow uses the Atlassian MCP server for Jira access**

The Atlassian MCP server provides tools for searching and managing Jira tickets. It should be configured in your MCP settings.

**MCP Server Configuration:**
- **Server Name:** `mcp-atlassian`
- **Available Tools:** `jira_search`, `jira_get_issue`, `jira_get_project_issues`, etc.
- **Configuration:** Set via environment variables (see below)

### 2. Environment Variables

**Required environment variables for MCP server:**
```bash
# Jira configuration
export JIRA_URL="https://your-jira-domain.com"
export JIRA_PERSONAL_TOKEN="your-personal-access-token"

# Optional: SSL verification (default: false)
export JIRA_SSL_VERIFY="false"

# Optional: Proxy settings
export HTTP_PROXY="your-proxy-url"
export HTTPS_PROXY="your-proxy-url"
export NO_PROXY="localhost,127.0.0.1"
```

**Note:** Personal Access Tokens are more secure than API tokens for self-hosted Jira instances.

### 3. Legacy API Configuration (Deprecated)

**Configuration File:**
```
File: /Users/[USER_TGI]/Documents/Cline/Settings/cline_workflow_config.json

Required section:
{
  "jiraConfig": {
    "baseUrl": "https://your-jira-domain.com",
    "email": "your-email@company.com",
    "apiToken": "your-api-token",
    "projectKey": "PROJ"
  }
}
```

**Note:** This workflow uses the same Jira configuration as the ticket creation workflow. Ensure your configuration is set up correctly.

### 4. Verify MCP Server Connection

**Check MCP server is available:**
```bash
# The MCP server should be listed in Cline's MCP settings
# Location: Settings > MCP Servers > mcp-atlassian
```

**Test MCP connection:**
Use Cline to verify the MCP server is working:
```
User: use jira_search tool to test connection

Cline: [Uses use_mcp_tool to execute jira_search]
```

### 5. Required Permissions

Your Jira account must have:
- Permission to browse issues in the target project
- Access to view issue details
- Search permissions

## Search Types

### 1. Search by Ticket Key

**Most direct search method - finds a specific ticket:**

```bash
# Search for specific ticket
User: search jira ticket PROJ-123
```

### 2. Search by Summary/Text

**Searches ticket summaries and descriptions:**

```bash
# Search for tickets containing specific text
User: search jira ticket "authentication"
User: find tickets about OAuth
```

### 3. Search by Status

**Find tickets in specific workflow states:**

```bash
# Search by status
User: search jira tickets in progress
User: find open tickets
User: search done tickets
```

### 4. Search by Assignee

**Find tickets assigned to specific users:**

```bash
# Search by assignee
User: search my jira tickets
User: find tickets assigned to john.doe
User: search unassigned tickets
```

### 5. Search by Type

**Filter by issue type:**

```bash
# Search by type
User: search jira bugs
User: find all stories
User: search tasks
```

### 6. Search by Priority

**Filter by priority level:**

```bash
# Search by priority
User: search high priority tickets
User: find critical bugs
```

### 7. Advanced JQL Search

**Use custom JQL queries for complex searches:**

```bash
# Custom JQL query
User: search jira "project = PROJ AND status = 'In Progress' AND assignee = currentUser()"
```

## Workflow Steps

### Step 1: Parse Search Criteria

**Cline will analyze your search request and determine:**
- Search type (key, text, status, assignee, etc.)
- Search parameters
- Project scope (defaults to configured project)

### Step 2: Construct JQL Query

**Based on search criteria, Cline constructs appropriate JQL:**

**Search by Key:**
```
key = PROJ-123
```

**Search by Text:**
```
project = PROJ AND (summary ~ "authentication" OR description ~ "authentication")
```

**Search by Status:**
```
project = PROJ AND status = "In Progress"
```

**Search by Assignee:**
```
project = PROJ AND assignee = currentUser()
```

**Combined Search:**
```
project = PROJ AND status = "In Progress" AND assignee = currentUser() AND type = Bug
```

### Step 3: Execute Search via MCP Server

**IMPORTANT: Use Atlassian MCP server for all Jira operations**

```bash
# Execute search using MCP server tool: jira_search
# Tool parameters:
# - jql: The JQL query string
# - limit: Maximum number of results (default: 10, max: 50)
# - fields: Comma-separated fields to return
# - projects_filter: Optional project key filter
# - expand: Optional fields to expand

# Example MCP tool call:
<use_mcp_tool>
<server_name>mcp-atlassian</server_name>
<tool_name>jira_search</tool_name>
<arguments>
{
  "jql": "project = PROJ AND status = 'In Progress'",
  "limit": 50,
  "fields": "summary,issuetype,priority,description,assignee,labels,created,status,reporter,updated"
}
</arguments>
</use_mcp_tool>
```

**MCP Tool Benefits:**
- Handles authentication automatically using environment variables
- No need to manually manage tokens or proxy settings
- Consistent error handling and retries
- Type-safe parameter validation
- Automatic response formatting

**Available Fields:**
- `summary` - Issue summary/title
- `issuetype` - Type of issue (Bug, Story, Task, etc.)
- `priority` - Priority level
- `description` - Issue description
- `assignee` - Assigned user
- `labels` - Issue labels
- `created` - Creation date
- `status` - Current status
- `reporter` - User who created the issue
- `updated` - Last update date

### Step 4: Format and Display Results

**Cline will display results in a formatted table:**

```
Found 5 tickets:

┌──────────────┬────────────────────────────────┬────────────┬──────────┬──────────┐
│ Key          │ Summary                        │ Status     │ Assignee │ Priority │
├──────────────┼────────────────────────────────┼────────────┼──────────┼──────────┤
│ PROJ-123     │ Add OAuth authentication       │ In Progress│ john.doe │ High     │
│ PROJ-124     │ Fix login crash on iOS         │ Open       │ jane.doe │ Critical │
│ PROJ-125     │ Update API documentation       │ Done       │ bob.smith│ Medium   │
└──────────────┴────────────────────────────────┴────────────┴──────────┴──────────┘

View ticket: https://your-jira-domain.com/browse/PROJ-123
```

## Usage Examples

### Example 1: Search by Ticket Key

```
User: search jira ticket PROJ-123

Cline: Searching for ticket PROJ-123...
      
      ✅ Found ticket:
      
      Key: PROJ-123
      Summary: Add OAuth authentication support
      Status: In Progress
      Assignee: john.doe@company.com
      Priority: High
      Type: Story
      Created: 2025-01-15
      Updated: 2025-01-20
      
      Description:
      Implement OAuth 2.0 authentication flow with Google and Facebook providers.
      Include error handling and token refresh logic.
      
      URL: https://your-jira-domain.com/browse/PROJ-123
```

### Example 2: Search by Text

```
User: search jira tickets about authentication

Cline: Searching for tickets containing "authentication"...
      
      ✅ Found 8 tickets:
      
      1. PROJ-123 - Add OAuth authentication support [In Progress]
      2. PROJ-145 - Implement biometric authentication [Open]
      3. PROJ-167 - Fix authentication token expiry [Done]
      4. PROJ-189 - Update authentication documentation [In Review]
      5. PROJ-201 - Add multi-factor authentication [Backlog]
      6. PROJ-223 - Authentication performance optimization [Open]
      7. PROJ-245 - Fix authentication error handling [In Progress]
      8. PROJ-267 - Authentication security audit [Done]
      
      View all results: https://your-jira-domain.com/issues/?jql=project%3DPROJ...
```

### Example 3: Search My Tickets

```
User: search my jira tickets

Cline: Searching for tickets assigned to you...
      
      ✅ Found 12 tickets assigned to you:
      
      In Progress (3):
      - PROJ-123 - Add OAuth authentication [High]
      - PROJ-156 - Fix iOS crash [Critical]
      - PROJ-178 - Update SDK documentation [Medium]
      
      Open (5):
      - PROJ-190 - Implement push notifications [High]
      - PROJ-201 - Add biometric auth [Medium]
      - PROJ-212 - Fix Android build [Low]
      - PROJ-223 - Update dependencies [Medium]
      - PROJ-234 - Add unit tests [Low]
      
      In Review (4):
      - PROJ-145 - OAuth integration [High]
      - PROJ-167 - Token refresh logic [Medium]
      - PROJ-189 - API documentation [Low]
      - PROJ-198 - Error handling [Medium]
```

### Example 4: Search by Status

```
User: search jira tickets in progress

Cline: Searching for tickets with status "In Progress"...
      
      ✅ Found 15 tickets in progress:
      
      High Priority (5):
      - PROJ-123 - Add OAuth authentication [john.doe]
      - PROJ-145 - Implement biometric auth [jane.doe]
      - PROJ-167 - Fix critical bug [bob.smith]
      - PROJ-189 - Security update [alice.jones]
      - PROJ-201 - Performance optimization [charlie.brown]
      
      Medium Priority (8):
      - PROJ-212 - Update documentation [john.doe]
      - PROJ-223 - Add unit tests [jane.doe]
      ...
      
      Low Priority (2):
      - PROJ-256 - Code cleanup [bob.smith]
      - PROJ-267 - Update README [alice.jones]
```

### Example 5: Search Bugs

```
User: search jira bugs

Cline: Searching for bug tickets...
      
      ✅ Found 23 bugs:
      
      Critical (2):
      - PROJ-156 - App crashes on login [In Progress]
      - PROJ-178 - Data loss on sync [Open]
      
      High (7):
      - PROJ-190 - Memory leak in auth module [In Progress]
      - PROJ-201 - UI freeze on iOS [Open]
      - PROJ-212 - Crash on invalid input [In Review]
      ...
      
      Medium (10):
      - PROJ-223 - Incorrect error message [Open]
      - PROJ-234 - Layout issue on iPad [Backlog]
      ...
      
      Low (4):
      - PROJ-245 - Typo in error message [Open]
      - PROJ-256 - Minor UI glitch [Backlog]
      ...
```

### Example 6: Advanced JQL Search

```
User: search jira "project = PROJ AND status = 'In Progress' AND priority in (High, Critical) AND assignee = currentUser()"

Cline: Executing custom JQL query...
      
      ✅ Found 3 tickets:
      
      1. PROJ-123 - Add OAuth authentication
         Status: In Progress
         Priority: High
         Assignee: You
         Updated: 2 hours ago
      
      2. PROJ-156 - Fix critical iOS crash
         Status: In Progress
         Priority: Critical
         Assignee: You
         Updated: 1 day ago
      
      3. PROJ-178 - Security vulnerability fix
         Status: In Progress
         Priority: High
         Assignee: You
         Updated: 3 days ago
```

### Example 7: Search with Multiple Criteria

```
User: search high priority bugs assigned to me

Cline: Searching for high priority bugs assigned to you...
      
      JQL: project = PROJ AND type = Bug AND priority = High AND assignee = currentUser()
      
      ✅ Found 4 bugs:
      
      1. PROJ-156 - App crashes on invalid login
         Status: In Progress
         Created: 2025-01-15
         Updated: 2 hours ago
      
      2. PROJ-190 - Memory leak in authentication
         Status: Open
         Created: 2025-01-18
         Updated: 1 day ago
      
      3. PROJ-212 - Data corruption on sync
         Status: In Review
         Created: 2025-01-20
         Updated: 3 hours ago
      
      4. PROJ-234 - Security vulnerability in OAuth
         Status: Open
         Created: 2025-01-22
         Updated: 5 hours ago
```

## Common Search Patterns

### 1. My Work

```bash
# All my tickets
search my jira tickets

# My tickets in progress
search my tickets in progress

# My open tickets
search my open tickets
```

### 2. Team Work

```bash
# Tickets assigned to team member
search tickets assigned to john.doe

# Unassigned tickets
search unassigned tickets

# Tickets in review
search tickets in review
```

### 3. By Priority

```bash
# Critical tickets
search critical tickets

# High priority tickets
search high priority tickets

# All high and critical
search jira "priority in (High, Critical)"
```

### 4. By Type

```bash
# All bugs
search jira bugs

# All stories
search jira stories

# All tasks
search jira tasks
```

### 5. Recent Activity

```bash
# Recently updated
search jira "updated >= -7d"

# Recently created
search jira "created >= -7d"

# Updated today
search jira "updated >= startOfDay()"
```

### 6. Sprint Related

```bash
# Current sprint
search jira "sprint in openSprints()"

# Specific sprint
search jira "sprint = 'Sprint 23'"

# Backlog
search jira "sprint is EMPTY"
```

## JQL Quick Reference

### Basic Operators

```
=     equals
!=    not equals
>     greater than
>=    greater than or equals
<     less than
<=    less than or equals
~     contains (text search)
!~    does not contain
IN    in list
NOT IN not in list
IS    is (for null/empty)
IS NOT is not (for null/empty)
```

### Common Fields

```
project       Project key
key           Issue key
summary       Issue summary
description   Issue description
status        Issue status
assignee      Assignee
reporter      Reporter
priority      Priority
type          Issue type
created       Creation date
updated       Last update date
resolved      Resolution date
labels        Labels
sprint        Sprint
```

### Functions

```
currentUser()           Current logged-in user
now()                   Current date/time
startOfDay()            Start of today
endOfDay()              End of today
startOfWeek()           Start of current week
endOfWeek()             End of current week
openSprints()           Open sprints
```

### Date Formats

```
-1d                     Yesterday
-7d                     7 days ago
-1w                     1 week ago
-1M                     1 month ago
"2025-01-15"            Specific date
```

### Logical Operators

```
AND                     Both conditions must be true
OR                      Either condition must be true
NOT                     Negates condition
()                      Groups conditions
```

## Advanced Search Examples

### Example 1: Complex Status Search

```jql
project = PROJ AND status IN ("In Progress", "In Review") AND assignee = currentUser() ORDER BY priority DESC, updated DESC
```

### Example 2: Date Range Search

```jql
project = PROJ AND created >= "2025-01-01" AND created <= "2025-01-31" AND type = Bug
```

### Example 3: Label-based Search

```jql
project = PROJ AND labels IN (authentication, security) AND status != Done
```

### Example 4: Sprint and Priority

```jql
project = PROJ AND sprint in openSprints() AND priority IN (High, Critical) ORDER BY priority DESC
```

### Example 5: Recently Updated Bugs

```jql
project = PROJ AND type = Bug AND updated >= -7d ORDER BY updated DESC
```

### Example 6: Unassigned High Priority

```jql
project = PROJ AND assignee IS EMPTY AND priority IN (High, Critical) ORDER BY created ASC
```

## Search Result Formats

### Compact Format (Default)

```
Found 5 tickets:

1. PROJ-123 - Add OAuth authentication [In Progress, High]
2. PROJ-124 - Fix iOS crash [Open, Critical]
3. PROJ-125 - Update docs [Done, Medium]
4. PROJ-126 - Add tests [In Review, Low]
5. PROJ-127 - Refactor code [Backlog, Medium]
```

### Detailed Format

```
Found 5 tickets:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PROJ-123: Add OAuth authentication support
Status: In Progress | Priority: High | Type: Story
Assignee: john.doe@company.com
Created: 2025-01-15 | Updated: 2025-01-20

Description:
Implement OAuth 2.0 authentication flow with Google and Facebook providers.

URL: https://your-jira-domain.com/browse/PROJ-123

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Additional tickets...]
```

### Table Format

```
┌──────────────┬────────────────────────────────┬────────────┬──────────┬──────────┐
│ Key          │ Summary                        │ Status     │ Assignee │ Priority │
├──────────────┼────────────────────────────────┼────────────┼──────────┼──────────┤
│ PROJ-123     │ Add OAuth authentication       │ In Progress│ john.doe │ High     │
│ PROJ-124     │ Fix login crash on iOS         │ Open       │ jane.doe │ Critical │
│ PROJ-125     │ Update API documentation       │ Done       │ bob.smith│ Medium   │
└──────────────┴────────────────────────────────┴────────────┴──────────┴──────────┘
```

## Pagination

**For large result sets:**

```
User: search jira bugs

Cline: Found 150 bugs (showing first 50):
      
      [Results 1-50]
      
      Options:
      1. Show next 50 results
      2. Show all results
      3. Refine search
      
      What would you like to do?

User: 1

Cline: Showing results 51-100:
      
      [Results 51-100]
```

## Export Results

**Save search results to file:**

```
User: search my tickets and export to file

Cline: Searching for your tickets...
      
      ✅ Found 25 tickets
      
      Exporting to: jira-search-results-2025-01-20.md
      
      ✅ Results exported!
      
      File contains:
      - Ticket keys and summaries
      - Status and priority
      - Assignee information
      - Direct links to tickets
```

## Troubleshooting

### Issue 1: No Results Found

**Possible causes:**
- Incorrect project key
- Too restrictive search criteria
- No tickets match the criteria

**Solution:**
```bash
# Verify project key
echo $JIRA_PROJECT_KEY

# Try broader search
search jira tickets

# Check if project has any tickets
curl -H "Authorization: Bearer $JIRA_API_TOKEN" \
  "$JIRA_BASE_URL/rest/api/2/search?jql=project=$JIRA_PROJECT_KEY&maxResults=1"
```

### Issue 2: MCP Server Authentication Failed

**Error:** `401 Unauthorized` or connection errors

**Root Cause:** Missing or invalid environment variables

**Solution:**
```bash
# Verify environment variables are set
echo $JIRA_URL
echo $JIRA_PERSONAL_TOKEN

# If not set, add to your shell profile (~/.zshrc or ~/.bash_profile)
export JIRA_URL="https://your-jira-domain.com"
export JIRA_PERSONAL_TOKEN="your-personal-access-token"

# Reload shell configuration
source ~/.zshrc  # or source ~/.bash_profile

# Restart VS Code for MCP server to pick up new variables

# Regenerate personal access token if needed
# For Self-hosted: Jira Profile → Personal Access Tokens
# For Atlassian Cloud: https://id.atlassian.com/manage-profile/security/api-tokens
```

**Important:** The MCP server uses environment variables for authentication, not configuration files.

### Issue 3: Invalid JQL Query

**Error:** `400 Bad Request - Invalid JQL`

**Solution:**
- Check JQL syntax
- Verify field names are correct
- Ensure values are properly quoted
- Test query in Jira web interface first

### Issue 4: Too Many Results

**Solution:**
```bash
# Add more specific criteria
search jira "project = PROJ AND status = 'In Progress' AND assignee = currentUser()"

# Use date filters
search jira "project = PROJ AND updated >= -7d"

# Limit by type
search jira "project = PROJ AND type = Bug"
```

### Issue 5: Slow Search

**Solution:**
- Reduce maxResults parameter
- Use more specific search criteria
- Avoid complex JQL queries
- Search by specific fields instead of text search

## Integration with Other Workflows

### Search and Create Branch

```
User: search ticket PROJ-123 and create branch

Cline: Found ticket: PROJ-123 - Add OAuth authentication
      
      Creating branch: feature/PROJ-123-add-oauth-authentication
      ✅ Branch created and checked out
```

### Search and Request Review

```
User: search my tickets in review

Cline: Found 3 tickets in review:
      1. PROJ-145 - OAuth integration
      2. PROJ-167 - Token refresh
      3. PROJ-189 - API docs
      
      Which ticket would you like to request review for?

User: 1

Cline: Requesting review for PROJ-145...
```

## Best Practices

1. **Use Specific Searches** - Be as specific as possible to get relevant results
2. **Save Common Queries** - Create shortcuts for frequently used searches
3. **Use JQL for Complex Searches** - Learn JQL for advanced filtering
4. **Check Recent Updates** - Use date filters to find recent activity
5. **Export Large Results** - Save large result sets to files for analysis
6. **Combine with Other Workflows** - Integrate search with branch creation, reviews, etc.

## Quick Reference

### Trigger Commands
```
search jira ticket
jira search
find jira ticket
search ticket
```

### Common Search Patterns
```
search jira ticket PROJ-123             # By key
search jira "authentication"            # By text
search my jira tickets                  # My tickets
search jira tickets in progress         # By status
search jira bugs                        # By type
search high priority tickets            # By priority
```

### JQL Examples
```
project = PROJ AND assignee = currentUser()
project = PROJ AND status = "In Progress"
project = PROJ AND type = Bug AND priority = High
project = PROJ AND updated >= -7d
```

## Configuration Reference

### MCP Server Environment Variables

**Required:**
```bash
export JIRA_URL="https://your-jira-domain.com"
export JIRA_PERSONAL_TOKEN="your-personal-access-token"
```

**Optional:**
```bash
export JIRA_SSL_VERIFY="true"
export JIRA_PROJECTS_FILTER="PROJ,OTHER"  # Filter projects
export HTTP_PROXY="your-proxy-url"
export HTTPS_PROXY="your-proxy-url"
export NO_PROXY="localhost,127.0.0.1"
```

### Legacy Configuration (Deprecated)

**File:** `/Users/[USER_TGI]/Documents/Cline/Settings/cline_workflow_config.json`

```json
{
  "jiraConfig": {
    "baseUrl": "https://your-jira-domain.com",
    "email": "your-email@company.com",
    "apiToken": "your-api-token",
    "projectKey": "PROJ"
  }
}
```

**Note:** This configuration file is deprecated. Use MCP server with environment variables instead.

## Related Workflows

- `jira-ticket-creation` - Create new Jira tickets
- `git-branch` - Create branches with Jira ticket keys
- `mr-review-request` - Link MRs to Jira tickets

## Notes

- Search uses Atlassian MCP server for all Jira operations
- MCP server handles authentication via environment variables
- Results are limited to 50 by default (configurable via `limit` parameter)
- JQL queries are automatically validated and executed
- Search respects your Jira permissions
- Results include clickable links to tickets
- MCP server provides consistent error handling and retries

---

**Last Updated:** 2025-12-11
**Version:** 1.0
**Maintainer:** Development Team
