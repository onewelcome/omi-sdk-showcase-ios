# Check Sprint Status Workflow

## Overview

This workflow automates the process of checking the current active sprint status by:
1. Fetching the current active sprint
2. Analyzing all stories in the sprint
3. Calculating total story points completed vs incomplete
4. Providing a detailed status summary

## Trigger Commands

- `check sprint status`
- `check sprint status on jira stories`
- `sprint status`
- `how is the sprint doing`
- `sprint progress`

## Prerequisites

- Atlassian MCP server configured with Jira access
- Active sprint exists in your Jira board
- Story points field configured in Jira (automatically detected)

## Default Configuration

**Default Board:** MOBSTA Board 
- **Board ID:** 10561
- **Project Key:** SASMOB
- **Board URL:** https://jira.gemalto.com/secure/RapidBoard.jspa?rapidView=10561&projectKey=SASMOB&view=planning.nodetail&quickFilter=31916&issueLimit=100#

**Note:** Unless explicitly specified by the user, this workflow will always use the MOBSTA board (ID: 10561) for checking sprint status.

## Workflow Steps

### Step 1: Identify Jira Board

**Default:** Board ID **10561** (MOBSTA project)

The workflow uses the MOBSTA board by default. Users can override by specifying:
1. A different board ID: `check sprint status for board [BOARD_ID]`
2. A board name: `check sprint status for [Board Name]`
3. If no board is specified, **always use board ID 10561**

### Step 2: Get Active Sprints

Fetch the current active sprint(s) from the identified board.

**MCP Tool:** `jira_get_sprints_from_board`

**Parameters:**
- `board_id`: Board ID from Step 1
- `state`: "active"

### Step 3: Fetch Sprint Issues

Retrieve all issues in the active sprint.

**MCP Tool:** `jira_get_sprint_issues`

**Parameters:**
- `sprint_id`: ID from Step 1
- `fields`: Include story points field (e.g., `customfield_10016`)
- `limit`: 50 (adjust if needed)

### Step 4: Detect Story Points Field

Automatically detect the story points field:
1. Search common field names using `jira_search_fields`
2. Check fields like "story points", "story point estimate", etc.
3. Use detected field or ask user if not found

### Step 5: Analyze Story Points

Calculate:
- **Done Story Points**: Sum of story points for issues with status "Done" or "Closed"
- **In Progress Story Points**: Sum of story points for issues with status "In Progress" or "In Review"
- **To Do Story Points**: Sum of story points for issues with status "To Do" or "Backlog"
- **Total Story Points**: Sum of all story points in the sprint

### Step 6: Generate Summary

Present a clear summary with:
- Sprint name and dates
- Total story points committed
- Story points completed
- Story points remaining
- Completion percentage
- Breakdown by status

## Example Usage

### Basic Usage

```
User: check sprint status on jira stories
```

**Cline Output:**
```
📊 Sprint Status Report

Sprint: [Sprint Name]
Duration: [Start Date] to [End Date]
Status: Active

Story Points Summary:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Done:         XX points (XX%)
🔄 In Progress:  XX points (XX%)
📋 To Do:        XX points (XX%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Total:        XX points

Progress: [Progress Bar] XX% Complete

Status Breakdown:
• Done: X issues
• In Review: X issues
• In Progress: X issues
• To Do: X issues

Top Completed Stories:
[List of completed high-point stories]

Remaining High-Priority Stories:
[List of remaining high-point stories]
```

### With Specific Board

```
User: check sprint status for board [BOARD_ID]
User: check sprint status for [Board Name]
```

### Multiple Sprints

If multiple active sprints exist, Cline will show all or ask which one to analyze.

## Implementation Details

### Story Points Field Detection

Cline will automatically detect the story points field by:
1. Using `jira_search_fields` to search for "story point" related fields
2. Checking common patterns in field names and descriptions
3. Testing candidate fields against sprint issues
4. Falling back to asking the user if detection fails
5. Caching the detected field for future use

### Status Mapping

Default status categories:
- **Done**: "Done", "Closed", "Resolved", "Completed"
- **In Progress**: "In Progress", "In Review", "Code Review", "Testing"
- **To Do**: "To Do", "Open", "Backlog", "Selected for Development"

The workflow adapts to your Jira workflow's status names.

### Issues Without Story Points

Issues without story points are:
- Listed separately in the report
- Not included in the percentage calculation
- Counted in the "unestimated" category

## Advanced Features

### Filter by Issue Type

```
User: check sprint status for stories only
User: check sprint status for bugs only
```

### Include Sub-tasks

```
User: check sprint status including sub-tasks
```

By default, sub-tasks are excluded from story point calculations.

### Export to File

```
User: check sprint status and save to file
```

Creates a markdown report in `sprint-status-report.md`.

### Compare with Previous Sprint

```
User: check sprint status and compare with last sprint
```

Shows velocity trends and improvements.

## Workflow Code Structure

```javascript
// Pseudo-code workflow logic
async function checkSprintStatus(boardId) {
  // 1. Get active sprint
  const sprints = await jira_get_sprints_from_board({
    board_id: boardId,
    state: "active"
  });
  
  if (sprints.length === 0) {
    return "No active sprint found";
  }
  
  const sprint = sprints[0];
  
  // 2. Get all issues in sprint
  const issues = await jira_get_sprint_issues({
    sprint_id: sprint.id,
    fields: "summary,status,issuetype,customfield_10016",
    limit: 100
  });
  
  // 3. Calculate story points
  const storyPoints = {
    done: 0,
    inProgress: 0,
    toDo: 0,
    unestimated: []
  };
  
  issues.forEach(issue => {
    const points = issue.fields.customfield_10016 || 0;
    const status = issue.fields.status.name;
    
    if (isDoneStatus(status)) {
      storyPoints.done += points;
    } else if (isInProgressStatus(status)) {
      storyPoints.inProgress += points;
    } else {
      storyPoints.toDo += points;
    }
    
    if (!points && issue.fields.issuetype.name !== "Sub-task") {
      storyPoints.unestimated.push(issue.key);
    }
  });
  
  // 4. Generate report
  return generateReport(sprint, storyPoints, issues);
}
```

## Configuration (Optional)

### Board ID Configuration

**Default Board ID:** 10561 (MOBSTA)
**Default Project Key:** SASMOB

The workflow always uses the MOBSTA board (ID: 10561) by default unless the user explicitly specifies a different board.

Optionally override the default board ID in `cline_workflow_config.json`:

```json
{
  "jira": {
    "defaultBoardId": "10561",
    "defaultProjectKey": "SASMOB",
    "storyPointsField": "[AUTO_DETECTED_OR_CUSTOM]"
  }
}
```

**Important:** Even if this configuration file doesn't exist, the workflow will default to board ID 10561 (SASMOB).

### Custom Status Mappings

Optionally override default status categories to match your workflow:

```json
{
  "jira": {
    "statusMapping": {
      "done": ["[Your Done Status Names]"],
      "inProgress": ["[Your In Progress Status Names]"],
      "toDo": ["[Your To Do Status Names]"]
    }
  }
}
```

**Note:** If not configured, Cline will use intelligent defaults that adapt to your Jira instance's status names.

## Troubleshooting

### Issue: "No active sprint found"

**Cause:** No sprints in "active" state on the board

**Solution:**
1. Verify board ID is correct
2. Check if sprint has been started in Jira
3. Try listing all sprints: `jira_get_sprints_from_board` with `state: null`

### Issue: "Story points field not found"

**Cause:** Story points custom field not detected automatically

**Solution:**
1. Cline will automatically search using `jira_search_fields`
2. You can manually specify: `check sprint status using field [FIELD_NAME]`
3. Optionally configure in `cline_workflow_config.json` for future use

### Issue: "Permission denied"

**Cause:** Insufficient Jira permissions

**Solution:**
1. Verify `JIRA_PERSONAL_TOKEN` has board access
2. Check user has permission to view sprints
3. Confirm board is not restricted

### Issue: Incorrect story point totals

**Cause:** Sub-tasks or epics included in calculation

**Solution:**
1. Filter by issue type: `issuetype != Sub-task`
2. Explicitly exclude epics if needed
3. Verify story points are on parent issues only

## Best Practices

1. **Run at Sprint Planning**: Check capacity vs committed points
2. **Daily Standup**: Quick progress check
3. **Mid-Sprint Review**: Assess if sprint goals are achievable
4. **Sprint Retrospective**: Compare planned vs actual completion

## Integration with Other Workflows

This workflow integrates with:
- **jira-to-code**: Start work on sprint stories
- **jira-ticket-search**: Deep dive into specific issues
- **confluence-search**: Link to sprint planning docs

## Related Workflows

- [jira-ticket-search](./jira-ticket-search.md) - Search for specific issues
- [jira-to-code](./jira-to-code.md) - Start work on sprint stories
- [jira-ticket-creation](./jira-ticket-creation.md) - Add stories to sprint

## Examples

### Example 1: Simple Status Check

```
User: check sprint status

Cline: Fetching active sprint...

Sprint: [Sprint Name] (Active)
Period: [Start Date] - [End Date]

✅ Done: XX points
🔄 In Progress: XX points  
📋 To Do: XX points
━━━━━━━━━━━━━━━━━━━━
📊 Total: XX points (XX% complete)
```

### Example 2: Detailed Breakdown

```
User: check sprint status with details

Cline: 
📊 Detailed Sprint Status

Sprint: [Sprint Name]
Goal: "[Sprint Goal]"
Duration: [Start Date] to [End Date] (X days remaining)

Story Points Breakdown:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Done (XX%):              XX points
   • [Completed issues with points]

🔄 In Progress (XX%):       XX points
   • [In progress issues with points]

📋 To Do (XX%):             XX points
   • [Remaining issues with points]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Velocity Metrics:
• Avg points/day: X.X
• Projected completion: [Date]
• Burn rate: [Status]

Risks:
⚠️ [Any blocked or at-risk items]
```

### Example 3: Export Report

```
User: check sprint status and save report

Cline: 
✅ Sprint status analyzed
📄 Report saved to: sprint-[NAME]-status-[DATE].md

Summary: XX% complete (XX/XX points done)
```

## Notes

- Story points field is automatically detected from your Jira configuration
- The workflow excludes sub-tasks by default to avoid double-counting
- Epics are filtered out unless explicitly requested
- Issues without story points are listed separately as "unestimated"
- Works with any Jira board structure (Scrum or Kanban)
- Adapts to your team's status names and workflow

## Maintenance

**Last Updated:** 2025-01-08  
**Next Review:** 2025-04-08

**Update Triggers:**
- Changes to Jira custom fields
- New status categories added
- Team workflow changes
- User feedback on reporting format
