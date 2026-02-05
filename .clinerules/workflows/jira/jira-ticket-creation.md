# Jira Ticket Creation Workflow

**Trigger Commands:**
- `create jira ticket`
- `jira ticket`
- `new jira ticket`
- `create ticket`

**Description:**
Automated workflow for creating Jira tickets in the Project Backlog based on user requirements. This workflow streamlines the manual process of ticket creation by gathering requirements, formatting the ticket, and creating it via the Atlassian MCP server.

## Overview

This workflow automates the creation of Jira tickets by:
1. Gathering ticket requirements from the user
2. Formatting the ticket according to Jira standards
3. Creating the ticket via Atlassian MCP server tools
4. Returning the ticket URL and key

**IMPORTANT:** This workflow uses the **Atlassian MCP server** for Jira access, NOT direct API calls. The MCP server provides reliable access to Jira with proper authentication and error handling.

## Prerequisites

### 1. Atlassian MCP Server Configuration

**IMPORTANT:** This workflow requires the **Atlassian MCP server** to be configured and running.

**MCP Server Configuration:**
The Atlassian MCP server should be configured in your Cline MCP settings with the following environment variables:

```bash
# Required environment variables for Atlassian MCP server
JIRA_URL=https://your-domain.atlassian.net
JIRA_PERSONAL_TOKEN=your-personal-access-token
```

**Configuration Location:**
The MCP server configuration is stored in:
```
File: ~/Library/Application Support/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json
```

**Verify MCP Server is Connected:**
Check that the `mcp-atlassian` server appears in the connected MCP servers list in Cline's environment details.

**How to Get Jira Personal Access Token:**

For **Self-hosted Jira** (recommended):
1. Go to your Jira profile (click profile icon → Profile)
2. Look for "Personal Access Tokens" or "Security" section
3. Click "Create token" or "Generate new token"
4. Give it a name: "Cline MCP Atlassian"
5. Copy the token immediately (you won't see it again!)
6. Set as environment variable: `JIRA_PERSONAL_TOKEN=your-token`

For **Atlassian Cloud** (atlassian.net):
1. Go to https://id.atlassian.com/manage-profile/security/api-tokens
2. Click "Create API token"
3. Give it a name (e.g., "Cline MCP Atlassian")
4. Copy the token and save it securely
5. Set as environment variable: `JIRA_PERSONAL_TOKEN=your-token`

**Add to MCP Configuration:**
Ensure the environment variables are set for the Atlassian MCP server in your MCP settings.

### 2. Verify MCP Server Connection

**Check MCP server status:**
The Atlassian MCP server should appear in the "Connected MCP Servers" section of Cline's environment details.

**Verify server connection:**
Look for `mcp-atlassian` in the list of connected servers with available tools:
- `jira_create_issue`
- `jira_get_issue`
- `jira_search`
- And other Jira/Confluence tools

**Test MCP server access:**
You can test the connection by using a simple MCP tool call:

```
<use_mcp_tool>
<server_name>mcp-atlassian</server_name>
<tool_name>jira_get_all_projects</tool_name>
<arguments>
{
  "include_archived": false
}
</arguments>
</use_mcp_tool>
```

**If the MCP server is not connected:**
1. Check that the Atlassian MCP server is configured in MCP settings
2. Verify environment variables are set correctly
3. Restart VS Code to reload MCP servers
4. Check MCP server logs for connection errors

### 3. Required Permissions

Your Jira account (associated with the Personal Access Token) must have:
- Permission to create issues in the target project
- Access to the Project Backlog
- Appropriate issue type permissions
- Browse Projects permission

## Workflow Steps

### Default Values

**The workflow uses the following defaults:**
- **Project:** Mobile Protector OTP SDK (SASMOB)
- **Issue Type:** Story
- **Priority:** Medium

**Important Notes:**
- **Summary is always required** - You must provide a summary for every ticket
- **User input always overrides defaults** - If you specify a different issue type, priority, or project, your input will be used instead of the defaults

### Step 1: Gather Ticket Requirements

**Cline will ask for the following information:**

1. **Summary** (required)
   - Brief title of the ticket
   - Example: "Implement OAuth authentication"
   - **This field is mandatory and must be provided by the user**

2. **Description** (required)
   - Detailed description of the requirement
   - Can include acceptance criteria, technical details, etc.
   - Supports Jira markdown format

3. **Issue Type** (required)
   - Story
   - Task
   - Bug
   - Epic
   - Sub-task

4. **Priority** (optional, default: Medium)
   - Highest
   - High
   - Medium
   - Low
   - Lowest

5. **Labels** (optional)
   - Tags for categorization
   - Example: "authentication", "security", "mobile"

6. **Assignee** (optional)
   - Jira username or email
   - Leave empty for unassigned

7. **Sprint** (optional)
   - Sprint ID or name
   - Leave empty for backlog

8. **Story Points** (optional)
   - Estimation in story points
   - Example: 3, 5, 8

### Step 2: Format Ticket Data

**Cline will format the ticket according to Jira API requirements:**

```json
{
  "fields": {
    "project": {
      "key": "PROJ"
    },
    "summary": "Ticket summary",
    "description": {
      "type": "doc",
      "version": 1,
      "content": [
        {
          "type": "paragraph",
          "content": [
            {
              "type": "text",
              "text": "Ticket description"
            }
          ]
        }
      ]
    },
    "issuetype": {
      "name": "Story"
    },
    "priority": {
      "name": "Medium"
    },
    "labels": ["label1", "label2"]
  }
}
```

### Step 3: Create Ticket via Atlassian MCP Server

**Use the `jira_create_issue` MCP tool:**

```
<use_mcp_tool>
<server_name>mcp-atlassian</server_name>
<tool_name>jira_create_issue</tool_name>
<arguments>
{
  "project_key": "PROJ",
  "summary": "Ticket summary",
  "issue_type": "Story",
  "description": "Detailed description",
  "priority": "Medium",
  "components": "component1,component2",
  "additional_fields": {
    "labels": ["label1", "label2"]
  }
}
</arguments>
</use_mcp_tool>
```

**MCP Tool Parameters:**
- `project_key` (required) - The Jira project key
- `summary` (required) - Ticket title
- `issue_type` (required) - Type of issue (Story, Task, Bug, Epic, Subtask)
- `description` (optional) - Detailed description
- `assignee` (optional) - User identifier (email, name, or accountId)
- `components` (optional) - Comma-separated component names
- `additional_fields` (optional) - Dictionary of additional fields like labels, priority, parent, etc.

**Extract from MCP response:**
- `key` → Ticket key (e.g., "PROJ-123")
- `id` → Ticket ID
- `self` → API URL

### Step 4: Return Ticket Information

**Cline will provide:**
- Ticket key (e.g., "PROJ-123")
- Ticket URL (e.g., "https://your-domain.atlassian.net/browse/PROJ-123")
- Confirmation message

## Prompt Templates

**Quick ticket creation with minimal input:**

### Template 1: Story with Summary Only (Uses Defaults)
```
create jira ticket summary "Add biometric authentication support"
```
**Result:** Creates a Story (default) in SASMOB project with Medium priority

### Template 2: Story with Summary and Description
```
create jira ticket summary "Implement OAuth 2.0 login" description "Add OAuth authentication with Google and Facebook providers. Include error handling and token refresh logic."
```

### Template 3: Bug Report
```
create jira ticket type Bug summary "App crashes on invalid login" description "Steps to reproduce: 1. Enter invalid credentials 2. Tap login 3. App crashes. Expected: Show error message. Actual: App crashes."
```

### Template 4: Task with Priority
```
create jira ticket type Task summary "Update API documentation" priority High description "Update REST API docs to reflect new authentication endpoints"
```

### Template 5: Complete Specification
```
create jira ticket type Story summary "Add push notification support" description "Implement push notifications for iOS and Android. Include notification permissions, deep linking, and analytics tracking." priority High labels "mobile,notifications,ios,android"
```

### Template 6: Epic
```
create jira ticket type Epic summary "User Authentication System Overhaul" description "Complete redesign of authentication including OAuth, biometric auth, MFA, and session management" priority Highest
```

**Key Points:**
- **Summary is always required** - You must include `summary "Your title here"`
- **Defaults are used** - If you don't specify type/priority, defaults are: Story, Medium priority, SASMOB project
- **User input overrides defaults** - Specifying `type Bug` or `priority High` will override the defaults
- **Description is optional** - But recommended for clarity

## Usage Examples

### Example 1: Interactive Mode (Recommended)

```
User: create jira ticket

Cline: I'll help you create a Jira ticket. Let me gather the requirements.
      
      What's the ticket summary?

User: Implement biometric authentication for iOS

Cline: What's the detailed description?

User: Add Face ID and Touch ID support for iOS app
      
      Acceptance Criteria:
      - Support Face ID on compatible devices
      - Support Touch ID as fallback
      - Handle permission requests
      - Add error handling for failed authentication

Cline: What issue type? (Story/Task/Bug/Epic/Sub-task)

User: Story

Cline: What priority? (Highest/High/Medium/Low/Lowest, default: Medium)

User: High

Cline: Any labels? (comma-separated, or press Enter to skip)

User: ios, authentication, security

Cline: Assignee? (Jira username/email, or press Enter for unassigned)

User: john.doe@company.com

Cline: Story points? (or press Enter to skip)

User: 5

Cline: Creating Jira ticket...
      
      ✅ Ticket created successfully!
      
      Key: PROJ-123
      URL: https://your-domain.atlassian.net/browse/PROJ-123
      
      Summary: Implement biometric authentication for iOS
      Type: Story
      Priority: High
      Assignee: john.doe@company.com
      Labels: ios, authentication, security
      Story Points: 5
```

### Example 2: Provide Details Upfront

```
User: create jira ticket summary "Add OAuth login" description "Implement OAuth 2.0 authentication flow with Google and Facebook providers" type Story priority High labels "authentication,oauth,security"

Cline: Creating Jira ticket with provided details...
      
      Summary: Add OAuth login
      Description: Implement OAuth 2.0 authentication flow with Google and Facebook providers
      Type: Story
      Priority: High
      Labels: authentication, oauth, security
      
      ✅ Ticket created!
      
      Key: PROJ-124
      URL: https://your-domain.atlassian.net/browse/PROJ-124
```

### Example 3: Bug Report

```
User: create jira ticket

Cline: What's the ticket summary?

User: App crashes on login with invalid credentials

Cline: What's the detailed description?

User: Steps to Reproduce:
      1. Open app
      2. Enter invalid email/password
      3. Tap Login button
      4. App crashes
      
      Expected: Show error message
      Actual: App crashes
      
      Environment: iOS 17.2, iPhone 15
      Severity: Critical

Cline: What issue type?

User: Bug

Cline: What priority?

User: Highest

Cline: Any labels?

User: ios, crash, login

Cline: Creating bug ticket...
      
      ✅ Bug ticket created!
      
      Key: PROJ-125
      URL: https://your-domain.atlassian.net/browse/PROJ-125
      
      Summary: App crashes on login with invalid credentials
      Type: Bug
      Priority: Highest
      Labels: ios, crash, login
```

### Example 4: Epic Creation

```
User: create jira ticket type Epic

Cline: What's the epic summary?

User: User Authentication System

Cline: What's the detailed description?

User: Complete overhaul of the authentication system including:
      - OAuth 2.0 integration
      - Biometric authentication
      - Multi-factor authentication
      - Session management
      - Password reset flow

Cline: What priority?

User: High

Cline: Any labels?

User: epic, authentication, security

Cline: Creating epic...
      
      ✅ Epic created!
      
      Key: PROJ-126
      URL: https://your-domain.atlassian.net/browse/PROJ-126
      
      Summary: User Authentication System
      Type: Epic
      Priority: High
      Labels: epic, authentication, security
```

### Example 5: Task with Sprint Assignment

```
User: create jira ticket

Cline: What's the ticket summary?

User: Update API documentation

Cline: What's the detailed description?

User: Update REST API documentation to reflect new authentication endpoints

Cline: What issue type?

User: Task

Cline: What priority?

User: Medium

Cline: Any labels?

User: documentation, api

Cline: Assignee?

User: [Press Enter to skip]

Cline: Story points?

User: 2

Cline: Sprint ID or name? (or press Enter for backlog)

User: Sprint 23

Cline: Creating task and adding to Sprint 23...
      
      ✅ Task created and added to sprint!
      
      Key: PROJ-127
      URL: https://your-domain.atlassian.net/browse/PROJ-127
      
      Summary: Update API documentation
      Type: Task
      Priority: Medium
      Labels: documentation, api
      Story Points: 2
      Sprint: Sprint 23
```

## Advanced Features

### 1. Rich Text Description

**Jira supports rich text formatting in descriptions:**

```
User: create jira ticket

Cline: What's the detailed description?

User: *Requirements:*
      - Support multiple authentication methods
      - Implement secure token storage
      
      *Technical Details:*
      {code:java}
      public class AuthManager {
          // Implementation here
      }
      {code}
      
      *References:*
      - [OAuth 2.0 Spec|https://oauth.net/2/]
      - Related ticket: PROJ-100

Cline: [Converts to Jira ADF format and creates ticket]
```

### 2. Custom Fields

**If your Jira project has custom fields:**

```bash
# Add custom field to API call
curl -X POST "$JIRA_BASE_URL/rest/api/3/issue" \
  -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "fields": {
      "project": {"key": "PROJ"},
      "summary": "Ticket summary",
      "issuetype": {"name": "Story"},
      "customfield_10001": "Custom value",
      "customfield_10002": {"value": "Option 1"}
    }
  }'
```

### 3. Link to Existing Tickets

**Create ticket with links to other tickets:**

```json
{
  "fields": {
    "project": {"key": "PROJ"},
    "summary": "New ticket",
    "issuetype": {"name": "Story"}
  },
  "update": {
    "issuelinks": [
      {
        "add": {
          "type": {
            "name": "Relates"
          },
          "inwardIssue": {
            "key": "PROJ-100"
          }
        }
      }
    ]
  }
}
```

### 4. Add Attachments

**After creating ticket, add attachments:**

```bash
# Upload attachment
curl -X POST "$JIRA_BASE_URL/rest/api/3/issue/$TICKET_KEY/attachments" \
  -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  -H "X-Atlassian-Token: no-check" \
  -F "file=@/path/to/file.png"
```

## Jira Description Format (ADF)

**Jira uses Atlassian Document Format (ADF) for rich text:**

### Basic Text
```json
{
  "type": "doc",
  "version": 1,
  "content": [
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "Plain text"
        }
      ]
    }
  ]
}
```

### Bold and Italic
```json
{
  "type": "text",
  "text": "Bold text",
  "marks": [{"type": "strong"}]
}
```

### Bullet List
```json
{
  "type": "bulletList",
  "content": [
    {
      "type": "listItem",
      "content": [
        {
          "type": "paragraph",
          "content": [
            {"type": "text", "text": "Item 1"}
          ]
        }
      ]
    }
  ]
}
```

### Code Block
```json
{
  "type": "codeBlock",
  "attrs": {"language": "java"},
  "content": [
    {
      "type": "text",
      "text": "public class Example {}"
    }
  ]
}
```

### Hyperlink
```json
{
  "type": "text",
  "text": "Click here",
  "marks": [
    {
      "type": "link",
      "attrs": {"href": "https://example.com"}
    }
  ]
}
```

## Troubleshooting

### Issue 1: MCP Server Not Connected

**Error:** MCP server `mcp-atlassian` not found

**Solution:**
1. Check MCP server configuration in Cline settings
2. Verify environment variables are set:
   - `JIRA_URL=https://your-domain.atlassian.net`
   - `JIRA_PERSONAL_TOKEN=your-token`
3. Restart VS Code to reload MCP servers
4. Check MCP server logs for errors

### Issue 2: Authentication Failed

**Error:** `401 Unauthorized` from MCP tool

**Solution:**
1. Verify your Personal Access Token is valid
2. Check token permissions in Jira
3. Regenerate token if expired:
   - For Self-hosted: Jira Profile → Personal Access Tokens
   - For Atlassian Cloud: https://id.atlassian.com/manage-profile/security/api-tokens
4. Update environment variable with new token
5. Restart MCP server

### Issue 3: Project Not Found

**Error:** `project is required` or `Project does not exist`

**Solution:**
Use the MCP tool to list available projects:

```
<use_mcp_tool>
<server_name>mcp-atlassian</server_name>
<tool_name>jira_get_all_projects</tool_name>
<arguments>
{
  "include_archived": false
}
</arguments>
</use_mcp_tool>
```

Verify the correct project key from the results and update your workflow parameters.

### Issue 4: Invalid Issue Type

**Error:** `Issue type is invalid`

**Solution:**
Check available issue types using the MCP tool to search for project information. Common issue types are:
- Story
- Task
- Bug
- Epic
- Subtask (note: use "Subtask" not "Sub-task")

Use the exact issue type name (case-sensitive) when creating tickets.

### Issue 5: Permission Denied

**Error:** `You do not have permission to create issues in this project`

**Solution:**
Contact your Jira administrator to grant the necessary permissions:
- Browse Projects
- Create Issues
- Edit Issues (if needed)

Verify your Personal Access Token has the appropriate scope and permissions.

### Issue 6: Invalid Priority

**Error:** `Priority is invalid`

**Solution:**
Use standard Jira priorities:
- Highest
- High
- Medium
- Low
- Lowest

Priority names are case-sensitive and must match exactly.

### Issue 7: User Not Found (Assignee)

**Error:** `User cannot be assigned issues`

**Solution:**
1. Verify the user has access to the project
2. Use the correct user identifier format:
   - Email: `user@company.com`
   - Display name: `John Doe`
   - Account ID: `accountid:...`
3. Or leave assignee empty for unassigned tickets

## Configuration File

**Jira configuration is stored in:**

**File:** `/Users/[USER_TGI]/Documents/Cline/Settings/cline_workflow_config.json`

```json
{
  "jiraConfig": {
    "baseUrl": "https://your-domain.atlassian.net",
    "email": "your-email@company.com",
    "apiToken": "your-api-token",
    "projectKey": "PROJ"
  }
}
```

**Optional: Add defaults and common values:**

```json
{
  "jiraConfig": {
    "baseUrl": "https://your-domain.atlassian.net",
    "email": "your-email@company.com",
    "apiToken": "your-api-token",
    "projectKey": "PROJ",
    "defaults": {
      "issueType": "Story",
      "priority": "Medium"
    },
    "issueTypes": [
      "Story",
      "Task",
      "Bug",
      "Epic",
      "Sub-task"
    ],
    "priorities": [
      "Highest",
      "High",
      "Medium",
      "Low",
      "Lowest"
    ],
    "commonLabels": [
      "authentication",
      "security",
      "ios",
      "android",
      "api",
      "documentation",
      "bug-fix",
      "enhancement"
    ]
  }
}
```

**Note:** The API token is stored in the configuration file. Keep this file secure and don't commit it to version control.

## Integration with Other Workflows

### Create Ticket from Git Branch

```
User: create jira ticket from current branch

Cline: Current branch: feature/oauth-login
      
      Detected summary: OAuth login
      
      Creating ticket...
      ✅ Ticket created: PROJ-128
      
      Would you like to update the branch name to include the ticket key?
      (feature/oauth-login → feature/PROJ-128-oauth-login)

User: yes

Cline: Renaming branch...
      ✅ Branch renamed to: feature/PROJ-128-oauth-login
```

### Create Ticket and Branch Together

```
User: create jira ticket and branch

Cline: What's the ticket summary?

User: Add push notification support

Cline: [Creates ticket PROJ-129]
      
      ✅ Ticket created: PROJ-129
      
      Creating branch: feature/PROJ-129-add-push-notification-support
      ✅ Branch created and checked out
```

### Link Ticket to MR

```
User: request review with jira ticket PROJ-129

Cline: [Creates MR with Jira ticket reference]
      
      MR Title: PROJ-129: Add push notification support
      MR Description: Implements push notification support
                     
                     Jira: https://your-domain.atlassian.net/browse/PROJ-129
```

## Best Practices

1. **Clear Summaries** - Use concise, descriptive titles
2. **Detailed Descriptions** - Include acceptance criteria and technical details
3. **Appropriate Labels** - Use consistent labeling for easy filtering
4. **Correct Issue Type** - Choose the right type for the work
5. **Realistic Estimates** - Provide accurate story points
6. **Link Related Tickets** - Reference related work
7. **Update Status** - Keep ticket status current
8. **Add Comments** - Document progress and decisions

## Security Notes

1. **Never commit API tokens** - Store in environment variables only
2. **Use API tokens, not passwords** - More secure and can be revoked
3. **Limit token scope** - Only grant necessary permissions
4. **Rotate tokens regularly** - Update tokens periodically
5. **Secure storage** - Keep tokens in secure locations

## Related Workflows

- `git-branch` - Create branches with Jira ticket keys
- `git-commit` - Commit with Jira ticket references
- `mr-review-request` - Link MRs to Jira tickets

## Quick Reference

### Trigger Commands
```
create jira ticket
jira ticket
new jira ticket
create ticket
```

### Required Configuration
```
File: /Users/[USER_TGI]/Documents/Cline/Settings/cline_workflow_config.json

Required fields in jiraConfig:
- baseUrl: "https://your-domain.atlassian.net"
- email: "your-email@company.com"
- apiToken: "your-api-token"
- projectKey: "PROJ"
```

### Common Issue Types
- Story
- Task
- Bug
- Epic
- Sub-task

### Common Priorities
- Highest
- High
- Medium (default)
- Low
- Lowest

## Example API Response

**Successful ticket creation:**
```json
{
  "id": "10123",
  "key": "PROJ-123",
  "self": "https://your-domain.atlassian.net/rest/api/3/issue/10123"
}
```

**Ticket URL:**
```
https://your-domain.atlassian.net/browse/PROJ-123
```

## Notes

- Tickets are created in the Project Backlog by default
- Use sprint assignment to add to active sprint
- Custom fields require additional API configuration
- Rich text formatting uses Atlassian Document Format (ADF)
- API token is more secure than password authentication
- Ticket keys are auto-generated by Jira (e.g., PROJ-123)

---

**Last Updated:** 2025-11-06
**Version:** 1.0
**Maintainer:** Development Team
