# Predict Jira Story Rollovers Workflow

## Overview

This workflow predicts which Jira stories in the current active sprint are likely to roll over to the next sprint by analyzing task velocity, completion rates, and remaining work.

## Trigger Commands

- `predict jira story rollovers`
- `predict rollovers`
- `check rollover risk`
- `sprint rollover prediction`

## Configuration

**Default Settings:**
- Project Key: `SASMOB`
- Board ID: `10561`
- Velocity Calculation Window: Current sprint

## Workflow Steps

### 1. Fetch Active Sprint Information

**Objective:** Get the current active sprint details including start date, end date, and stories.

**Actions:**
1. Use MCP tool to get active sprint from board
2. Calculate sprint timeline:
   - Total sprint days
   - Days elapsed
   - Days remaining
3. Extract sprint stories with sub-tasks

**MCP Tools:**
```
cG_BJr0mcp0jira_get_sprints_from_board
- board_id: "10561"
- state: "active"
- limit: 1
```

### 2. Analyze Story Completion Status

**Objective:** Calculate completion metrics for each story in the sprint.

**For each story, gather:**
- Total story points (if available)
- Sub-task breakdown:
  - Total sub-tasks
  - Completed sub-tasks
  - In Progress sub-tasks
  - To Do sub-tasks
- Status: To Do, In Progress, Done
- Assignee information
- Time tracking:
  - Time spent
  - Time remaining estimate
  - Original estimate

**MCP Tools:**
```
cG_BJr0mcp0jira_get_sprint_issues
- sprint_id: [from step 1]
- fields: "summary,status,assignee,subtasks,timetracking,storypoints,progress"
- limit: 50
```

### 3. Calculate Velocity Metrics

**Objective:** Determine current velocity and required velocity to complete on time.

**Calculations:**

**A. Current Velocity (per day):**
```
Current Velocity = Completed Sub-tasks / Days Elapsed
```

**B. Required Velocity (per day):**
```
Required Velocity = Remaining Sub-tasks / Days Remaining
```

**C. Velocity Gap:**
```
Velocity Gap = Required Velocity - Current Velocity
```

**D. Completion Percentage:**
```
Completion % = (Completed Sub-tasks / Total Sub-tasks) × 100
```

**E. Expected Completion Date:**
```
If Current Velocity > 0:
    Expected Days = Remaining Sub-tasks / Current Velocity
    Expected Completion = Today + Expected Days
Else:
    Expected Completion = "Unable to predict (zero velocity)"
```

### 4. Calculate Rollover Risk Score

**Objective:** Assign a risk score to each story based on multiple factors.

**Risk Factors (0-100 scale):**

1. **Velocity Risk (40% weight):**
   - If Required Velocity > 2× Current Velocity: 100 points
   - If Required Velocity > 1.5× Current Velocity: 75 points
   - If Required Velocity > Current Velocity: 50 points
   - If Current Velocity meets requirement: 0 points

2. **Completion Risk (30% weight):**
   - If < 25% complete with < 3 days remaining: 100 points
   - If < 50% complete with < 5 days remaining: 75 points
   - If < 75% complete with < 2 days remaining: 50 points
   - If >= 75% complete: 0 points

3. **Status Risk (20% weight):**
   - If status = "To Do": 100 points
   - If status = "In Progress" with 0 completed sub-tasks: 75 points
   - If status = "In Progress" with some progress: 25 points
   - If status = "Done": 0 points

4. **Time Risk (10% weight):**
   - If Time Remaining > 2× Days Remaining × 8 hours: 100 points
   - If Time Remaining > Days Remaining × 8 hours: 50 points
   - Otherwise: 0 points

**Final Risk Score:**
```
Risk Score = (Velocity Risk × 0.4) + 
             (Completion Risk × 0.3) + 
             (Status Risk × 0.2) + 
             (Time Risk × 0.1)
```

**Risk Categories:**
- **CRITICAL (80-100):** Very likely to roll over
- **HIGH (60-79):** Likely to roll over
- **MEDIUM (40-59):** At risk
- **LOW (20-39):** Probably on track
- **MINIMAL (0-19):** On track

### 5. Generate Rollover Predictions

**Objective:** Present actionable insights about rollover risks.

**Output Format:**

```markdown
# Sprint Rollover Prediction Report

## Sprint Information
- Sprint Name: [Sprint Name]
- Sprint Goal: [Goal]
- Start Date: [Date]
- End Date: [Date]
- Days Elapsed: X / Y days
- Days Remaining: Z days

## Overall Sprint Velocity
- Total Stories: X
- Completed Stories: Y (Z%)
- Total Sub-tasks: X
- Completed Sub-tasks: Y (Z%)
- Current Velocity: X sub-tasks/day
- Required Velocity: Y sub-tasks/day
- Velocity Gap: Z sub-tasks/day (X%)

## Rollover Risk Summary
- CRITICAL Risk: X stories
- HIGH Risk: X stories
- MEDIUM Risk: X stories
- LOW Risk: X stories
- MINIMAL Risk: X stories

---

## Stories at Risk of Rollover

### CRITICAL RISK (80-100)

#### [STORY-KEY] Story Title
- **Risk Score:** 95/100
- **Status:** In Progress
- **Assignee:** John Doe
- **Completion:** 15% (2/13 sub-tasks)
- **Current Velocity:** 0.2 tasks/day
- **Required Velocity:** 1.8 tasks/day
- **Velocity Gap:** 1.6 tasks/day (800% increase needed)
- **Expected Completion:** 8 days after sprint end
- **Recommendation:** 
  - Consider reducing scope or splitting story
  - Need immediate attention from team
  - May require additional resources

#### [STORY-KEY] Another Story
...

### HIGH RISK (60-79)

#### [STORY-KEY] Story Title
...

---

## Stories On Track

### [STORY-KEY] Story Title
- **Risk Score:** 15/100
- **Status:** In Progress
- **Completion:** 80% (8/10 sub-tasks)
- **Expected Completion:** 2 days before sprint end
- **Status:** ✅ On track

---

## Recommendations

### Immediate Actions Required (Critical Risk)
1. [STORY-KEY] - Consider splitting or descoping
2. [STORY-KEY] - Needs additional resources

### Monitor Closely (High Risk)
1. [STORY-KEY] - Check progress daily
2. [STORY-KEY] - Remove blockers

### Sprint Health
- **Overall Risk Level:** MEDIUM
- **Projected Completion:** 75% of stories will complete
- **Recommended Actions:**
  - Focus on critical risk stories
  - Consider moving X stories to next sprint
  - Review sprint capacity planning

### Team Velocity Insights
- Team is currently operating at X% of required velocity
- Historical velocity: [if available]
- Trend: [Improving/Declining/Stable]
```

### 6. Flag Stories for Action

**Objective:** Create actionable follow-ups for high-risk stories.

**For each CRITICAL or HIGH risk story:**

1. **Add comment to Jira (optional, with user approval):**
   ```
   ⚠️ Rollover Risk Alert
   
   This story has been flagged as HIGH RISK for rolling over to next sprint.
   
   Risk Score: 85/100
   Current Progress: 25% complete
   Required Velocity: 2.5× current velocity
   
   Recommended Actions:
   - Review scope with PO
   - Consider splitting into smaller stories
   - Identify and remove blockers
   - Re-estimate remaining work
   ```

2. **Generate summary for team standup:**
   - List of at-risk stories
   - Quick status overview
   - Action items needed

3. **Export data for further analysis:**
   - JSON format with all metrics
   - Can be used for dashboards or reports

### 7. Present Interactive Options

**Objective:** Allow user to take action on predictions.

**Options:**
1. **View detailed story analysis** - Drill down into specific story
2. **Add Jira comments** - Flag stories in Jira with risk warnings
3. **Export report** - Save report to file (JSON/Markdown)
4. **Suggest rescoping** - AI-powered suggestions for reducing scope
5. **Compare with previous sprints** - Historical velocity comparison
6. **Update story status** - Transition stories based on findings

## Usage Examples

### Example 1: Basic Prediction

```
User: predict jira story rollovers

Cline: I'll analyze the current sprint for rollover risks...

[Fetches sprint data]
[Calculates velocities]
[Generates report]

Here's the rollover prediction for Sprint 23:

Overall Sprint Health: MEDIUM RISK
- 3 stories at CRITICAL risk
- 2 stories at HIGH risk
- 4 stories on track

Would you like me to:
1. Show detailed analysis for critical stories
2. Add risk warnings to Jira
3. Export the full report
```

### Example 2: Specific Story Focus

```
User: predict rollovers, focus on high risk stories

Cline: Analyzing sprint for high-risk stories...

Found 5 stories with HIGH or CRITICAL risk:

CRITICAL (2 stories):
- SASMOB-1234: Biometric Login (95/100 risk)
- SASMOB-1235: OAuth Integration (87/100 risk)

HIGH (3 stories):
- SASMOB-1236: UI Redesign (72/100 risk)
...

[Detailed analysis for each]
```

### Example 3: With Historical Context

```
User: predict rollovers and compare to sprint velocity history

Cline: Analyzing sprint with historical context...

Current Sprint Velocity: 3.2 tasks/day
Historical Average: 4.1 tasks/day
Trend: Current sprint is 22% below average

This may explain why we have 5 stories at risk...

[Full analysis]
```

## Integration with Other Workflows

This workflow integrates with:

1. **check-sprint-status.md** - Uses sprint status data
2. **jira-to-code.md** - Can trigger code implementation for at-risk stories
3. **jira-ticket-search.md** - Can search for related blockers
4. **mr-review-request.md** - Can expedite reviews for at-risk stories

## MCP Tools Used

This workflow uses the following Atlassian MCP tools:

1. **cG_BJr0mcp0jira_get_sprints_from_board**
   - Get active sprint information
   - Parameters: board_id, state

2. **cG_BJr0mcp0jira_get_sprint_issues**
   - Get all issues in the sprint
   - Parameters: sprint_id, fields, limit

3. **cG_BJr0mcp0jira_get_issue** (if detailed analysis needed)
   - Get detailed issue information
   - Parameters: issue_key, fields, expand

4. **cG_BJr0mcp0jira_add_comment** (optional, with approval)
   - Add risk warning comments to stories
   - Parameters: issue_key, comment

5. **cG_BJr0mcp0jira_batch_get_changelogs** (optional)
   - Analyze velocity trends from history
   - Parameters: issue_ids_or_keys, fields

## Error Handling

### No Active Sprint
```
User: predict rollovers

Cline: I couldn't find an active sprint for board 10561.
Would you like me to:
1. Check another board
2. Analyze a specific sprint by ID
3. View all sprints for this board
```

### Insufficient Data
```
Cline: Some stories don't have sub-tasks or time estimates.
I'll calculate risk based on available data, but predictions
may be less accurate for:
- SASMOB-1234 (no sub-tasks)
- SASMOB-1235 (no time tracking)

Proceed with analysis? (yes/no)
```

### API Rate Limiting
```
Cline: I've analyzed 30 stories so far but hit API rate limits.
I'll continue in 60 seconds, or we can:
1. Analyze what we have so far
2. Focus on high-risk stories only
3. Wait and get complete data
```

## Best Practices

1. **Run Early in Sprint** - Run this prediction at 30%, 50%, and 70% sprint completion for best results

2. **Focus on Actionable Insights** - Don't just report risks, provide recommendations

3. **Consider Team Capacity** - Factor in holidays, PTO, and other commitments

4. **Update Estimates** - Encourage team to update time tracking for better predictions

5. **Historical Context** - Compare with previous sprint velocities for trends

6. **Collaborate with PO** - Share predictions with Product Owner for scope discussions

7. **Act on Predictions** - Use predictions to make mid-sprint adjustments

## Configuration Options

### Custom Velocity Calculation

Users can customize how velocity is calculated:

```json
{
  "velocity_calculation": {
    "method": "subtasks",  // Options: "subtasks", "storypoints", "time"
    "exclude_done_status": true,
    "exclude_weekends": true,
    "include_carryover": false
  }
}
```

### Risk Threshold Customization

Adjust risk score thresholds:

```json
{
  "risk_thresholds": {
    "critical": 80,
    "high": 60,
    "medium": 40,
    "low": 20
  }
}
```

### Board Configuration

Support multiple boards:

```json
{
  "boards": {
    "default": {
      "project_key": "SASMOB",
      "board_id": "10561"
    },
    "platform": {
      "project_key": "PLAT",
      "board_id": "4001"
    }
  }
}
```

## Advanced Features

### Machine Learning Enhancement (Future)

- Train on historical sprint data
- Predict rollovers based on team patterns
- Learn from past predictions vs actual outcomes
- Adjust risk weights based on team performance

### Real-time Monitoring

- Watch mode: Check rollover risk every few hours
- Slack notifications when risk increases
- Daily summaries of risk changes

### What-If Analysis

```
User: what if we move SASMOB-1234 to next sprint?

Cline: If we move SASMOB-1234 (13 sub-tasks) to next sprint:
- Sprint completion: 75% → 89%
- Required velocity: 3.2 → 2.1 tasks/day
- High-risk stories: 5 → 2

Recommendation: Yes, moving this story would significantly
improve sprint health.
```

## Troubleshooting

### Issue: Velocity calculations seem off

**Solution:**
- Verify time tracking is being used consistently
- Check if sub-tasks are properly linked to stories
- Ensure story statuses are up to date

### Issue: Too many false positives

**Solution:**
- Adjust risk threshold weights
- Include historical velocity data
- Consider team-specific factors (experience, complexity)

### Issue: Predictions don't match reality

**Solution:**
- Review past sprint outcomes vs predictions
- Adjust risk calculation weights
- Include more contextual factors (blockers, dependencies)

## Related Workflows

- [check-sprint-status.md](./check-sprint-status.md) - Check overall sprint health
- [jira-to-code.md](./jira-to-code.md) - Start work on at-risk stories
- [jira-ticket-search.md](./jira-ticket-search.md) - Find related issues/blockers
- [check-story-description.md](./check-story-description.md) - Verify story quality

## Maintenance

**Last Updated:** 2025-12-09  
**Next Review:** 2025-03-09

**Update Triggers:**
- Changes in sprint planning process
- New risk factors identified
- Team feedback on prediction accuracy
- Jira API changes
