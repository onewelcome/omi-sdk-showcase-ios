# Check Story Description Workflow

## Overview

This workflow automates the process of scanning Jira tickets in the current active sprint and checking if any important fields are missing. It helps ensure stories are properly defined before development begins.

## Trigger Commands

- `scan jira stories for current sprint`
- `check sprint stories`
- `validate sprint tickets`
- `check story descriptions`

## What This Workflow Does

1. **Fetches Active Sprint** - Gets the current active sprint for the configured board
2. **Retrieves Sprint Stories** - Fetches all stories/issues in the active sprint
3. **Validates Each Story** - Checks for missing critical fields:
   - Description
   - Scope (In Scope / Out of Scope)
   - Acceptance Criteria
   - Story Points
   - Sub-tasks
4. **Generates Report** - Provides a detailed report of stories with missing fields
5. **Provides Recommendations** - Suggests actions to complete story definitions

## Prerequisites

- Atlassian MCP server configured
- Jira credentials set up (`JIRA_URL`, `JIRA_PERSONAL_TOKEN`)
- Board ID configured (can be found in your Jira board URL)
- Access to the Jira board and sprints

## Workflow Steps

### Step 1: Navigate to Default Board

```markdown
**Cline will:**
1. Use the default board ID (10561) directly
2. Do NOT search for active sprint first
3. Navigate directly to the board to view sprint information
4. Display board details and available sprints
```

**Important:** The workflow should navigate to the default board first, not search for the active sprint. This ensures proper access and context before querying sprint data.

**Note:** You can find your board ID in the Jira board URL. For example:
- URL: `https://jira.gemalto.com/secure/RapidBoard.jspa?rapidView=10561&projectKey=SASMOB`
- Board ID: `10561`

### Step 2: Get Active Sprint

```markdown
**Cline will:**
1. After navigating to the board, get active sprint using `jira_get_sprints_from_board`
2. Filter to state="active" to get only the current sprint
3. Display sprint details (name, dates, goal)
```

### Step 3: Fetch Sprint Stories

```markdown
**Cline will:**
1. Use `jira_get_sprint_issues` to get all issues in the sprint
2. Request necessary fields:
   - summary
   - description
   - issuetype
   - customfield_10016 (Story Points)
   - subtasks
3. Display count of stories found
```

### Step 4: Validate Stories

**For each story, Cline checks:**

#### ✅ Description
- **Check:** Description field is not empty
- **Flag if:** Description is missing or only whitespace
- **Importance:** Critical - describes what needs to be done

#### ✅ Scope (In Scope / Out of Scope)
- **Check:** Description contains "In Scope" and "Out of Scope" sections
- **Flag if:** Either section is missing from description
- **Importance:** High - clarifies boundaries of work

#### ✅ Acceptance Criteria
- **Check:** Description contains "Acceptance Criteria" section
- **Flag if:** Section is missing or empty
- **Importance:** Critical - defines when story is complete

#### ✅ Story Points
- **Check:** Story points field has a value
- **Flag if:** Story points not estimated
- **Importance:** Medium - needed for sprint planning

#### ✅ Sub-tasks
- **Check:** Story has at least one sub-task
- **Flag if:** No sub-tasks exist
- **Importance:** Medium - breaks down work into manageable pieces

### Step 5: Generate Report

```markdown
**Cline will create a report showing:**

1. **Summary Statistics:**
   - Total stories in sprint
   - Stories with all fields complete
   - Stories with missing fields

2. **Detailed Findings:**
   For each story with issues:
   - Story key and title
   - List of missing fields
   - Current status
   - Assignee
   - Link to Jira ticket

3. **Prioritized Action Items:**
   - Critical issues (missing description/AC)
   - High priority (missing scope)
   - Medium priority (missing points/sub-tasks)
```

### Step 6: Provide Recommendations

```markdown
**Cline will suggest:**

1. **Immediate Actions:**
   - Stories that must be fixed before sprint starts
   - Stories that block development

2. **Team Actions:**
   - Who should update which stories
   - Potential refinement meeting needs

3. **Process Improvements:**
   - Template for story descriptions
   - Checklist for story creation
```

## Example Usage

### Basic Usage

```
User: scan jira stories for current sprint

Cline: I'll scan the current active sprint for stories with missing fields.

[Using configured board]
[Fetching active sprint...]
Found: Sprint 24 (Jan 15 - Jan 29, 2025)
Goal: Implement authentication features

[Fetching sprint stories...]
Found 12 stories in sprint

[Validating stories...]

📊 SPRINT STORY VALIDATION REPORT
==================================

Summary:
- Total Stories: 12
- Complete Stories: 8 ✅
- Stories with Issues: 4 ⚠️

Critical Issues (Must Fix):
---------------------------
1. PROJ-123: Add biometric login
   ❌ Missing: Description, Acceptance Criteria
   Status: To Do
   Assignee: John Doe
   Link: https://jira.company.com/browse/PROJ-123

2. PROJ-125: Update OAuth flow
   ❌ Missing: Acceptance Criteria
   Status: To Do
   Assignee: Jane Smith
   Link: https://jira.company.com/browse/PROJ-125

High Priority Issues:
--------------------
3. PROJ-127: Add 2FA support
   ⚠️ Missing: Scope sections
   Status: In Progress
   Assignee: Bob Wilson
   Link: https://jira.company.com/browse/PROJ-127

Medium Priority Issues:
----------------------
4. PROJ-130: Login UI improvements
   ⚠️ Missing: Story Points, Sub-tasks
   Status: To Do
   Assignee: Alice Brown
   Link: https://jira.company.com/browse/PROJ-130

Recommendations:
---------------
🔴 CRITICAL: 2 stories are missing descriptions/AC and cannot be developed
   → Schedule refinement session before sprint starts
   → Assign product owner to update PROJ-123, PROJ-125

🟡 HIGH: 1 story needs scope clarification
   → Update PROJ-127 with In Scope/Out of Scope sections

🟢 MEDIUM: 1 story needs estimation and breakdown
   → Estimate PROJ-130 and create sub-tasks

Would you like me to:
1. Generate a checklist for updating these stories?
2. Create a template for proper story descriptions?
3. Export this report to a file?
```

### Advanced Usage

```
User: scan jira stories for current sprint and save report

Cline: [Performs scan using configured board]
      Report generated and saved to: sprint-validation-report.md
      
User: check only critical fields

Cline: [Scans only Description and Acceptance Criteria]

User: scan jira stories for board 10561

Cline: [Performs scan using board ID 10561]

User: scan jira stories and create tickets for missing items

Cline: [Scans and offers to create sub-tasks for updating stories]
```

### Command Variations

```
# Use default/configured board
scan jira stories for current sprint
check sprint stories
validate sprint tickets

# Specify custom board ID
scan sprint for board 10561
check stories for board 1234
validate sprint for board 5678

# Save report
scan sprint and save report
check sprint stories and export
```

## Configuration

### Board Configuration

**Default Configuration:**
- **Default Board ID:** `10561` (Mobile Protector - Team Alpha)
- **Default Project Key:** `SASMOB`

These defaults will be used unless you specify a different board in your command.

You can also configure a custom default board in `cline_workflow_config.json`:

```json
{
  "jira": {
    "defaultBoardId": "10561",
    "defaultProjectKey": "SASMOB",
    "defaultBoardName": "Mobile Protector - Team Alpha"
  }
}
```

**Finding your Board ID:**

Your board ID is in the Jira board URL:
```
https://jira.example.com/secure/RapidBoard.jspa?rapidView=10561&projectKey=SASMOB
                                                          ^^^^
                                                       Board ID
```

**Examples:**
- SASMOB project (default): Board ID `10561`
- IDCX SDK Board: Board ID `23833`
- Mobile SDK SG Core Team 1: Board ID `2583`
- Custom project: Board ID `1234`

**To use a specific board without configuration:**
```
scan sprint for board 10561
```

### Customizing Fields to Check

You can customize which fields are validated by modifying the workflow logic:

```javascript
const REQUIRED_FIELDS = {
  description: { priority: "critical", name: "Description" },
  acceptanceCriteria: { priority: "critical", name: "Acceptance Criteria" },
  scope: { priority: "high", name: "Scope (In/Out)" },
  storyPoints: { priority: "medium", name: "Story Points" },
  subtasks: { priority: "medium", name: "Sub-tasks" }
};
```

### Custom Field IDs

If your Jira instance uses custom fields, update the field mappings:

```javascript
const FIELD_MAPPINGS = {
  storyPoints: "customfield_10016", // Story Points custom field
  epicLink: "customfield_10014",     // Epic Link custom field
  // Add your custom fields here
};
```

## Field Validation Rules

### Description Format

**Expected structure:**
```markdown
## Description
[What needs to be done]

## In Scope
- Feature A
- Feature B

## Out of Scope
- Feature C
- Future enhancement D

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Technical Considerations
[Optional: technical notes]

## Dependencies
[Optional: dependencies]
```

### Story Points

- **Valid values:** 1, 2, 3, 5, 8, 13, 21 (Fibonacci sequence)
- **Flag if:** Null, 0, or not set
- **Recommendation:** Use planning poker or similar estimation

### Sub-tasks

- **Minimum:** At least 1 sub-task per story
- **Recommendation:** 2-5 sub-tasks per story
- **Best practice:** Each sub-task should be completable in 1-2 days

## Report Formats

### Console Output (Default)

Displays formatted report in chat with:
- Color-coded priorities (🔴🟡🟢)
- Emojis for status (✅ ❌ ⚠️)
- Clickable links to Jira

### Markdown File

Save report as markdown file:
```markdown
# Sprint Validation Report
Generated: 2025-01-15 14:30:00

[Report content]
```

### JSON Export

Export data for further processing:
```json
{
  "sprint": {
    "id": "1234",
    "name": "Sprint 24",
    "state": "active"
  },
  "summary": {
    "total": 12,
    "complete": 8,
    "withIssues": 4
  },
  "issues": [...]
}
```

## Integration with Other Workflows

### With Jira Ticket Creation

```
User: scan sprint stories, then create tickets for updates

Cline: [Scans stories]
      Found 4 stories with missing fields.
      Creating update tasks...
      
      Created:
      - PROJ-150: Update PROJ-123 description
      - PROJ-151: Add AC to PROJ-125
```

### With Git Branch Creation

```
User: scan sprint stories and create branches

Cline: [Scans stories]
      All stories validated ✅
      Creating branches for sprint stories...
```

### With Generate Jira Content

```
User: scan sprint and generate content for incomplete stories

Cline: [Scans stories]
      PROJ-123 is missing description.
      [Triggers generate-jira-content workflow]
```

## Troubleshooting

### Issue: Cannot find active sprint

**Solution:**
```
1. Verify your board has an active sprint
2. Check sprint state: jira_get_sprints_from_board with your board_id
3. Verify you have permissions to view the board
4. Confirm board ID is correct in your Jira URL
```

### Issue: Wrong board being scanned

**Solution:**
```
1. Verify the board ID in cline_workflow_config.json
2. Check if command specifies a different board
3. Confirm project key matches your board
```

### Issue: Custom fields not detected

**Solution:**
```
1. Use jira_search_fields to find custom field IDs
2. Update FIELD_MAPPINGS with correct IDs
3. Verify field names match your Jira configuration
```

### Issue: False positives for scope/AC

**Solution:**
```
1. Check description format matches expected template
2. Ensure sections use exact headings (## In Scope, etc.)
3. Verify markdown formatting is correct
```

## Best Practices

### Before Sprint Starts

1. **Run validation early:** Check stories 2-3 days before sprint
2. **Fix critical issues:** Ensure all stories have descriptions and AC
3. **Refinement meeting:** Use report to guide refinement discussions

### During Sprint

1. **Daily checks:** Run validation at standup
2. **New stories:** Validate any stories added mid-sprint
3. **Track progress:** Monitor completion of validation fixes

### Process Improvements

1. **Story template:** Create template based on validation rules
2. **Definition of Ready:** Use validation criteria as DoR checklist
3. **Automation:** Set up Jira automation to enforce validation

## Related Workflows

- **[jira-ticket-creation](jira-ticket-creation.md)** - Create properly formatted tickets
- **[generate-jira-content](generate-jira-content.md)** - Generate story content from notes
- **[jira-to-code](jira-to-code.md)** - Start development from validated stories
- **[jira-ticket-search](jira-ticket-search.md)** - Search for specific stories

## Support

**Common Questions:**

**Q: What if my team doesn't use story points?**  
A: Customize the validation rules to skip story points check.

**Q: Can I check multiple sprints?**  
A: Yes, modify the workflow to accept sprint ID parameter.

**Q: How do I export the report?**  
A: Request "save report to file" and Cline will create markdown/JSON export.

**Q: Can I validate only specific story types?**  
A: Yes, request "scan only user stories" or filter by issue type.

## Version History

- **v1.2** (2025-01-15) - Made workflow generic
  - Removed hardcoded board defaults
  - Added configuration guide for any board
  - Enhanced flexibility for different projects

- **v1.1** (2025-01-15) - Added board configuration support
  - Added support for custom board override
  - Enhanced command variations

- **v1.0** (2025-01-15) - Initial workflow creation
  - Basic validation for description, scope, AC, points, sub-tasks
  - Report generation with priorities
  - Integration with other workflows

## Maintenance

**Review Schedule:** Monthly or when Jira template changes

**Update Triggers:**
- New required fields added to story template
- Changes in team's Definition of Ready
- Jira custom field changes
- Team feedback on validation rules

**Last Updated:** 2025-01-15  
**Next Review:** 2025-02-15

## Quick Start

**Step 1: Find your Board ID**
- Open your Jira board
- Look at the URL: `rapidView=XXXX` (XXXX is your board ID)
- Example: `rapidView=10561` → Board ID is `10561`

**Step 2: Configure (Optional)**
- Add board ID to `cline_workflow_config.json`
- OR specify in command: `scan sprint for board 10561`

**Step 3: Run the workflow**
```
scan jira stories for current sprint
```

**Cline will:**
1. Connect to your configured board
2. Fetch the active sprint
3. Validate all stories in the sprint
4. Generate a comprehensive report

**Using defaults (SASMOB project, Board 10561):**
```
scan jira stories for current sprint
```

**Using a different board:**
```
scan sprint for board 23833
```
