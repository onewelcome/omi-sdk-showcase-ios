# Sprint Retrospective Generator Workflow

## Overview

This workflow automates the preparation for sprint retrospective discussions by:
1. Analyzing sprint metrics (velocity, rollover rate, bugs, blocked time)
2. Fetching commit frequency patterns from Git
3. Reviewing MR turnaround time
4. Generating data-driven retro talking points
5. Creating a Confluence retrospective page with all findings

## Trigger Commands

- `generate sprint [SPRINT NO.] retro`
- `generate sprint retrospective`
- `create sprint retro`
- `prepare sprint retrospective`

## Prerequisites

- Atlassian MCP server configured with Jira and Confluence access
- Git repository access
- Active or completed sprint in Jira
- GitLab access for MR data (if available)
- Write permissions for Confluence space

## Default Configuration

**Default Board:** SASMOB Board
- **Board ID:** 10561
- **Default Project Key:** SASMOB
- **Default Board URL:** https://jira.gemalto.com/secure/RapidBoard.jspa?rapidView=10561&projectKey=SASMOB

**Default Confluence Space:** AUTH
- **Space URL:** https://confluence.gemalto.com/spaces/AUTH/

**Note:** Unless explicitly specified, this workflow uses the SASMOB board for retrospective data and AUTH space for Confluence pages.

## Workflow Steps

### Step 1: Identify Sprint

Accept sprint identifier from user:
- Sprint number (e.g., "generate sprint 23 retro")
- Sprint name (e.g., "generate sprint Sprint 2025-01 retro")
- If not specified, use most recently completed sprint

**MCP Tool:** `jira_get_sprints_from_board`

**Parameters:**
- `board_id`: "10561" (or user-specified)
- `state`: "closed" (for completed sprints) or "active" (for current sprint)

### Step 2: Fetch Sprint Issues

Retrieve all issues from the identified sprint with full details.

**MCP Tool:** `jira_get_sprint_issues`

**Parameters:**
- `sprint_id`: From Step 1
- `fields`: "*all" (to get all issue data including story points, status transitions, etc.)
- `limit`: 100

### Step 3: Analyze Sprint Metrics

#### 3.1 Velocity vs Planned

Calculate:
- **Planned Story Points**: Total points committed at sprint start
- **Completed Story Points**: Points for issues in "Done" status
- **Velocity Achievement**: (Completed / Planned) × 100%

#### 3.2 Rollover Rate

Calculate:
- **Rolled Over Issues**: Issues incomplete at sprint end
- **Rollover Rate**: (Rolled Over / Total Issues) × 100%
- **Rollover Story Points**: Points from incomplete stories

#### 3.3 Bug Count

Analyze:
- **Bugs Created**: New bugs opened during sprint
- **Bugs Resolved**: Bugs closed during sprint
- **Bug Backlog Change**: Net change in bug count
- **Critical Bugs**: High/critical priority bugs

**MCP Tool:** `jira_search`

**JQL Query:**
```jql
project = SASMOB AND 
issuetype = Bug AND 
created >= [sprint_start_date] AND 
created <= [sprint_end_date]
```

#### 3.4 Blocked Time

Calculate:
- **Blocked Issues**: Issues that were blocked during sprint
- **Total Blocked Days**: Sum of days issues spent in "Blocked" status
- **Percentage of Sprint**: Blocked time / Total sprint days

**MCP Tool:** `jira_batch_get_changelogs`

**Parameters:**
- `issue_ids_or_keys`: List of all sprint issue keys
- `fields`: ["status"]

Parse changelogs to identify:
- When issues moved to "Blocked" status
- Duration in blocked state
- Reasons for blocking (from comments)

### Step 4: Fetch Commit Frequency Patterns

Analyze Git commit history during sprint period.

**Git Commands:**

```bash
# Get commit count per day
git log --since="[sprint_start_date]" --until="[sprint_end_date]" \
  --format="%ad" --date=short | sort | uniq -c

# Get commit count per author
git log --since="[sprint_start_date]" --until="[sprint_end_date]" \
  --format="%an" | sort | uniq -c | sort -rn

# Get commits by hour of day
git log --since="[sprint_start_date]" --until="[sprint_end_date]" \
  --format="%ad" --date=format:'%H' | sort | uniq -c

# Get average commits per day
git log --since="[sprint_start_date]" --until="[sprint_end_date]" \
  --oneline | wc -l
```

**Analysis:**
- Daily commit frequency (identify slow days)
- Peak commit times (when team is most productive)
- Commit distribution across team members
- Days with no commits (potential blockers or holidays)

### Step 5: Review MR Turnaround Time

Analyze merge request metrics from GitLab.

**GitLab API Calls:**

```bash
# Get MRs created during sprint
curl "https://gitlab.cpliam.com/api/v4/projects/[PROJECT_ID]/merge_requests" \
  -H "PRIVATE-TOKEN: [TOKEN]" \
  --data-urlencode "created_after=[sprint_start_date]" \
  --data-urlencode "created_before=[sprint_end_date]"

# For each MR, get:
# - created_at
# - merged_at (or closed_at)
# - time_stats (time estimates and time spent)
# - discussion count
# - approval count
```

**Calculate:**
- **Average Time to First Review**: Time from MR creation to first comment
- **Average Time to Merge**: Time from MR creation to merge
- **MR Approval Rate**: Percentage of MRs approved vs requested changes
- **Review Cycles**: Average number of review iterations
- **MR Size**: Average lines changed per MR

### Step 6: Generate Retro Talking Points

Create structured talking points organized by retrospective format:

#### What Went Well? 🌟

**Data Points:**
- "Achieved XX% velocity (completed XX/XX story points)"
- "Merged XX MRs with average turnaround of X.X days"
- "Bug resolution rate: XX% (closed XX bugs)"
- "Consistent commit pattern with peak activity on [days]"
- "No critical blockers lasted more than X days"

#### What Didn't Go Well? 🔴

**Data Points:**
- "XX% rollover rate (XX stories incomplete)"
- "XX stories blocked for total of XX days (XX% of sprint)"
- "XX new bugs discovered (XX critical)"
- "MR review time exceeded X days for XX% of MRs"
- "Commit frequency dropped on [dates] - investigate reasons"

#### What Should We Try? 💡

**Suggestions Based on Data:**
- If rollover rate > 20%: "Better story point estimation / reduce commitment"
- If blocked time > 10%: "Daily blocker resolution meetings / clearer dependencies"
- If bugs high: "More code review focus / increase test coverage"
- If MR turnaround slow: "Set review time expectations / pair programming"
- If commit patterns uneven: "Encourage smaller, more frequent commits"

#### Action Items 🎯

**Generated from metrics:**
- "Track story point accuracy: actual vs estimated"
- "Create blocker escalation process if issues blocked > 2 days"
- "Set MR review SLA: first review within 4 hours"
- "Investigate commit gap on [date] - document learnings"
- "Review and improve bug prevention practices"

### Step 7: Create Confluence Retro Page

Generate a comprehensive retrospective page in Confluence.

**MCP Tool:** `confluence_create_page`

**Parameters:**
- `space_key`: Project space (default: "AUTH")
- `title`: "Sprint [NUMBER] Retrospective - [Date]"
- `content`: Generated content in Markdown format
- `parent_id`: Link to sprint retrospectives parent page (if exists)

**Page Structure:**

```markdown
# Sprint [NUMBER] Retrospective

**Sprint Duration:** [Start Date] - [End Date]  
**Sprint Goal:** [Goal from Jira]  
**Team:** [Team members from sprint]

---

## 📊 Sprint Metrics Summary

### Velocity
- **Planned:** XX story points
- **Completed:** XX story points
- **Achievement:** XX%

📈 Velocity Trend: [Chart or comparison with previous sprints]

### Completion
- **Total Stories:** XX
- **Completed:** XX (XX%)
- **Rolled Over:** XX (XX%)
- **Added Mid-Sprint:** XX

### Quality
- **Bugs Created:** XX
- **Bugs Resolved:** XX
- **Net Bug Count:** +/- XX
- **Critical Bugs:** XX

### Blockers
- **Issues Blocked:** XX
- **Total Blocked Time:** XX days
- **% of Sprint:** XX%
- **Average Block Duration:** X.X days

---

## 💻 Development Metrics

### Commit Activity
- **Total Commits:** XXX
- **Average per Day:** XX
- **Active Days:** XX/XX
- **Peak Commit Time:** [Time range]

📊 Commit Frequency Chart:
[Text-based chart showing daily commit count]

### Team Contribution
| Developer | Commits | % of Total |
|-----------|---------|------------|
| [Name]    | XXX     | XX%        |
| [Name]    | XXX     | XX%        |

### Merge Request Metrics
- **Total MRs:** XX
- **Merged:** XX
- **Average Time to First Review:** X.X hours
- **Average Time to Merge:** X.X days
- **Average Review Cycles:** X.X

---

## 🌟 What Went Well

[Data-driven positive points]

- ✅ [Point with supporting data]
- ✅ [Point with supporting data]
- ✅ [Point with supporting data]

---

## 🔴 What Didn't Go Well

[Data-driven challenges]

- ❌ [Issue with supporting data]
- ❌ [Issue with supporting data]
- ❌ [Issue with supporting data]

---

## 💡 What Should We Try

[Data-driven improvement suggestions]

- 💭 [Suggestion based on metrics]
- 💭 [Suggestion based on metrics]
- 💭 [Suggestion based on metrics]

---

## 🎯 Action Items

| Action | Owner | Due Date | Status |
|--------|-------|----------|--------|
| [Action item from metrics] | TBD | [Date] | 🔲 Todo |
| [Action item from metrics] | TBD | [Date] | 🔲 Todo |

---

## 📈 Sprint Comparison

| Metric | This Sprint | Last Sprint | Change |
|--------|-------------|-------------|--------|
| Velocity | XX pts | XX pts | +/- XX% |
| Rollover Rate | XX% | XX% | +/- XX% |
| Bugs Created | XX | XX | +/- XX |
| Avg MR Time | X.X days | X.X days | +/- XX% |

---

## 🔗 Related Links

- [Sprint Board](https://jira.gemalto.com/secure/RapidBoard.jspa?rapidView=10561)
- [Sprint Planning Notes](link)
- [Previous Retrospective](link)

---

## 📝 Team Notes

[Space for team to add their own observations during the retro meeting]

---

**Generated:** [Timestamp]  
**Generated by:** Cline Sprint Retro Generator
```

## Example Usage

### Basic Usage

```
User: generate sprint 23 retro

Cline: 
🔄 Generating Sprint 23 Retrospective...

✅ Sprint identified: Sprint 23 (2025-01-01 to 2025-01-14)
✅ Fetched 24 sprint issues
✅ Analyzed sprint metrics
✅ Collected commit data (247 commits)
✅ Reviewed 18 merge requests
✅ Generated talking points
✅ Created Confluence page

📄 Retrospective Page:
https://confluence.gemalto.com/display/AUTH/Sprint+23+Retrospective

📊 Quick Summary:
• Velocity: 85% (34/40 points)
• Rollover: 15% (4 stories)
• Bugs: 8 created, 6 resolved
• MR Turnaround: 1.2 days avg
```

### With Specific Sprint Name

```
User: generate sprint "Sprint 2025-01" retro
```

### For Current Active Sprint

```
User: generate sprint retro for current sprint
```

### Custom Confluence Space

```
User: generate sprint 23 retro in TECH space
```

## Implementation Details

### Date Range Detection

For completed sprints, use exact sprint dates from Jira.
For active sprints, use sprint start date to current date.

### Git Repository Detection

```bash
# Detect git repository
git rev-parse --git-dir

# If multiple repos, ask user which one to analyze
# Or analyze all repos in workspace
```

### GitLab Project Detection

```bash
# Parse .git/config for remote URL
git config --get remote.origin.url

# Extract project ID from GitLab API
# Or ask user to provide project ID
```

### Missing Data Handling

- **No Git data**: Skip commit analysis, note in report
- **No GitLab access**: Skip MR analysis, note in report
- **No changelog data**: Use issue current status only
- **Incomplete sprint**: Mark as "In Progress" retro

### Confluence Page Formatting

Use Markdown format (converted by MCP server):
- Headers: `#`, `##`, `###`
- Tables: Standard Markdown tables
- Lists: Bulleted and numbered
- Emphasis: Bold `**text**`, italic `*text*`
- Emojis: Unicode emojis for visual appeal

## Advanced Features

### Multi-Sprint Comparison

```
User: generate sprint 23 retro and compare with sprint 22
```

Adds comparison section showing trends across sprints.

### Custom Metrics

```
User: generate sprint retro including technical debt metric
```

Searches for "tech debt" labeled issues and includes in analysis.

### Team-Specific Analysis

```
User: generate sprint retro for iOS team
```

Filters data by component or team label.

### Export Options

```
User: generate sprint retro and save locally
```

Creates local markdown file in addition to Confluence page.

## Workflow Code Structure

```javascript
// Pseudo-code workflow logic
async function generateSprintRetro(sprintIdentifier, boardId = "10561") {
  // 1. Identify sprint
  const sprint = await identifySprint(sprintIdentifier, boardId);
  
  // 2. Fetch sprint data
  const issues = await jira_get_sprint_issues({
    sprint_id: sprint.id,
    fields: "*all",
    limit: 100
  });
  
  // 3. Analyze metrics
  const metrics = {
    velocity: calculateVelocity(issues, sprint),
    rolloverRate: calculateRolloverRate(issues),
    bugCount: await analyzeBugs(sprint),
    blockedTime: await analyzeBlockedTime(issues)
  };
  
  // 4. Fetch commit data
  const commits = await analyzeCommits(sprint.startDate, sprint.endDate);
  
  // 5. Review MR data
  const mrData = await analyzeMergeRequests(sprint.startDate, sprint.endDate);
  
  // 6. Generate talking points
  const talkingPoints = generateTalkingPoints(metrics, commits, mrData);
  
  // 7. Create Confluence page
  const pageContent = buildRetroPage(sprint, metrics, commits, mrData, talkingPoints);
  
  const page = await confluence_create_page({
    space_key: "AUTH",
    title: `Sprint ${sprint.name} Retrospective`,
    content: pageContent,
    content_format: "markdown"
  });
  
  return {
    pageUrl: page.url,
    summary: generateSummary(metrics)
  };
}

function calculateVelocity(issues, sprint) {
  const planned = sumStoryPoints(issues);
  const completed = sumStoryPoints(issues.filter(i => i.fields.status.name === "Done"));
  return {
    planned,
    completed,
    achievement: (completed / planned) * 100
  };
}

function calculateRolloverRate(issues) {
  const total = issues.length;
  const incomplete = issues.filter(i => i.fields.status.name !== "Done").length;
  return {
    total,
    incomplete,
    rate: (incomplete / total) * 100
  };
}

async function analyzeBugs(sprint) {
  const bugsCreated = await jira_search({
    jql: `project = SASMOB AND issuetype = Bug AND created >= "${sprint.startDate}" AND created <= "${sprint.endDate}"`,
    limit: 100
  });
  
  const bugsResolved = bugsCreated.issues.filter(
    bug => bug.fields.status.name === "Done"
  );
  
  return {
    created: bugsCreated.total,
    resolved: bugsResolved.length,
    critical: bugsCreated.issues.filter(b => b.fields.priority.name === "Critical").length
  };
}

async function analyzeBlockedTime(issues) {
  const changelogs = await jira_batch_get_changelogs({
    issue_ids_or_keys: issues.map(i => i.key),
    fields: ["status"]
  });
  
  let totalBlockedDays = 0;
  let blockedIssues = 0;
  
  changelogs.forEach(changelog => {
    const blockEvents = changelog.histories.filter(
      h => h.items.some(i => i.toString === "Blocked")
    );
    
    if (blockEvents.length > 0) {
      blockedIssues++;
      totalBlockedDays += calculateBlockedDuration(blockEvents);
    }
  });
  
  return {
    blockedIssues,
    totalBlockedDays,
    percentage: (totalBlockedDays / sprintDays) * 100
  };
}
```

## Configuration

### Optional Config in `cline_workflow_config.json`

```json
{
  "retrospective": {
    "defaultBoardId": "10561",
    "defaultSpace": "AUTH",
    "includeCommitAnalysis": true,
    "includeMRAnalysis": true,
    "gitlabProjectId": "[PROJECT_ID]",
    "retrospectiveParentPageId": "[PAGE_ID]",
    "customMetrics": [
      {
        "name": "Technical Debt",
        "jql": "labels = tech-debt",
        "type": "count"
      }
    ]
  }
}
```

## Troubleshooting

### Issue: "Sprint not found"

**Cause:** Sprint number/name doesn't match Jira

**Solution:**
1. List available sprints: `jira_get_sprints_from_board`
2. Verify sprint name spelling
3. Check if sprint exists on correct board

### Issue: "No commit data found"

**Cause:** Not in git repository or date range mismatch

**Solution:**
1. Verify you're in git repository: `git status`
2. Check sprint dates match git log date range
3. Ensure commits exist in the period

### Issue: "Cannot access GitLab API"

**Cause:** Missing token or network issues

**Solution:**
1. Check `GITLAB_PERSONAL_TOKEN` environment variable
2. Verify GitLab URL is correct
3. Test API access: `curl -v https://gitlab.cpliam.com/api/v4/version`
4. Use zsh terminal, not cline terminal (see Terminal Configuration Rules)

### Issue: "Confluence page creation failed"

**Cause:** Insufficient permissions or invalid space

**Solution:**
1. Verify Confluence API token has write permissions
2. Check space key is correct
3. Ensure you have permission to create pages in space

### Issue: "Incomplete metrics"

**Cause:** Missing Jira custom fields or changelog access

**Solution:**
1. Verify story points field is configured
2. Check user has permission to view issue history
3. Some metrics may not be available - workflow will note this

## Best Practices

1. **Run After Sprint Close**: Generate retro within 1-2 days of sprint end while data is fresh
2. **Review Before Meeting**: Generate page before retro meeting so team can review
3. **Customize Talking Points**: Use generated points as starting point, add team observations
4. **Track Action Items**: Follow up on action items from previous retros
5. **Compare Trends**: Look at multiple sprint retros to identify patterns
6. **Share Insights**: Link retro pages in sprint planning for context

## Integration with Other Workflows

This workflow integrates with:
- **check-sprint-status**: Uses similar sprint metrics calculation
- **predict-rollovers**: Rollover data feeds into retro insights
- **check-story-description**: Story quality impacts retro discussions
- **ticket-grooming**: Action items may include grooming improvements

## Related Workflows

- [check-sprint-status](./check-sprint-status.md) - Current sprint health
- [predict-rollovers](./predict-rollovers.md) - Identify at-risk stories
- [check-story-description](./check-story-description.md) - Story quality checks
- [ticket-grooming](./ticket-grooming.md) - Backlog preparation

## Examples

### Example 1: Complete Retro Generation

```
User: generate sprint 23 retro

Cline:
🔄 Generating Sprint 23 Retrospective...

📋 Sprint Details:
   Name: Sprint 23
   Duration: Jan 1 - Jan 14, 2025 (14 days)
   Goal: Complete authentication module

✅ Step 1/7: Sprint data fetched (24 issues)
✅ Step 2/7: Velocity analyzed (85% achievement)
✅ Step 3/7: Rollover calculated (15% - 4 stories)
✅ Step 4/7: Bugs analyzed (8 created, 6 resolved)
✅ Step 5/7: Blocked time calculated (12 days total)
✅ Step 6/7: Commit patterns analyzed (247 commits)
✅ Step 7/7: MR metrics reviewed (18 MRs, 1.2 day avg)

📊 Key Metrics:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Velocity:        85% (34/40 pts)
Rollover:        15% (4 stories)
Bugs:            +2 net (8 created, 6 fixed)
Blocked Time:    8.6% of sprint
Commits/Day:     17.6 avg
MR Turnaround:   1.2 days avg
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 Generated Talking Points:

What Went Well:
• Strong velocity achievement (85%)
• Fast MR turnaround (1.2 days)
• Consistent daily commits

What Didn't Go Well:
• 4 stories rolled over (estimation issue?)
• 8 new bugs discovered
• 12 days of blocked time across team

What Should We Try:
• Review estimation accuracy
• Increase code review thoroughness
• Daily blocker resolution check-in

📄 Confluence Page Created:
   https://confluence.gemalto.com/display/AUTH/Sprint+23+Retrospective
   
✅ Retrospective ready for team review!
```

### Example 2: Quick Summary

```
User: generate sprint retro

Cline:
Using most recent sprint: Sprint 24

🔄 Analyzing sprint data...

📊 Sprint 24 Summary:
• 78% velocity (31/40 pts completed)
• 20% rollover rate
• 5 bugs created, 4 resolved
• 2.1 days avg MR time

📄 Full retro page:
https://confluence.gemalto.com/display/AUTH/Sprint+24+Retrospective
```

### Example 3: Comparison Mode

```
User: generate sprint 23 retro and compare with sprint 22

Cline:
📊 Generating Sprint 23 Retro with Sprint 22 Comparison...

Sprint 23 vs Sprint 22:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Velocity:      85% vs 92%  (📉 -7%)
Rollover:      15% vs 8%   (📈 +7%)
Bugs:          8 vs 5      (📈 +3)
MR Time:       1.2 vs 1.5  (📉 -0.3 days)
Commits/Day:   17.6 vs 14.2 (📈 +3.4)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 Trend Analysis:
✅ Improved: MR turnaround, commit frequency
⚠️ Declined: Velocity, rollover rate, bug count

[Full retro page with comparison section created]
```

## Notes

- Retrospective generation is most accurate for completed sprints
- Git and GitLab data is optional but recommended for complete picture
- Generated talking points are data-driven suggestions - team should add their own observations
- Action items should be reviewed and assigned during the actual retro meeting
- Confluence page can be edited after generation to add team notes
- Works best when sprint has accurate Jira data (story points, status transitions)

## Maintenance

**Last Updated:** 2025-01-12  
**Next Review:** 2025-04-12

**Update Triggers:**
- New metrics requested by team
- Changes to retrospective format preferences
- Integration with additional data sources
- Team feedback on generated talking points
