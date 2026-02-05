# Ticket Grooming Workflow

## Overview

This workflow automates the preparation of grooming sessions by analyzing backlog tickets, checking for completeness, suggesting story point estimates, grouping related work, and creating a structured agenda. It helps teams run more efficient grooming sessions and produce better estimates.

## Trigger Commands

- `Prepare grooming session`
- `Groom backlog`
- `Prepare backlog grooming`
- `Create grooming agenda`

## Prerequisites

### Required Configuration

1. **Issue Tracking Integration** configured with appropriate credentials
   - **For Jira/Confluence:** Use the Atlassian MCP server for accessing Jira issues and Confluence pages
   - See [MCP Server Rules](../mcp-server-rules.md) for detailed MCP server usage guidelines
2. **Project Configuration** (if available) with project-specific settings
3. **Access Permissions** to read backlog tickets and historical data

### Default Backlog

**Default SASMOB Backlog:** https://jira.gemalto.com/secure/RapidBoard.jspa?rapidView=10561&projectKey=SASMOB&view=planning.nodetail&issueLimit=100#

This is the default backlog board for the SASMOB project. The workflow can analyze tickets from this backlog or from other configured project backlogs.

## Workflow Steps

### Step 1: Fetch Backlog Tickets

**Action:** Retrieve all unrefined tickets from the backlog with "Open" status only

**JQL Query Examples:**

**Basic Query (Open tickets without story points):**
```jql
project = SASMOB AND status = Open AND "Story Points" is EMPTY ORDER BY priority DESC, created ASC
```

**Filter by Fix Version:**
```jql
project = SASMOB AND status = Open AND "Story Points" is EMPTY AND fixVersion = "upcoming_version" ORDER BY priority DESC, created ASC
```

**Filter by Labels:**
```jql
project = SASMOB AND status = Open AND "Story Points" is EMPTY AND labels = "needs-grooming" ORDER BY priority DESC, created ASC
```

**Filter by Component:**
```jql
project = SASMOB AND status = Open AND "Story Points" is EMPTY AND component = "OTP/OATH" ORDER BY priority DESC, created ASC
```

**Important:** 
- Only tickets with status "Open" should be fetched for grooming. Tickets in other statuses (In Progress, Needs Review, Responded, Reopened, etc.) should be excluded from the grooming session.
- **User can specify custom filtering criteria** such as:
  - Fix Version (e.g., `fixVersion = "upcoming_version"`)
  - Labels (e.g., `labels = "needs-grooming"`)
  - Components (e.g., `component = "Frontend"`)
  - Issue Type (e.g., `issuetype = Story`)
  - Priority (e.g., `priority = High`)
  - Created date (e.g., `created >= -30d`)

**Outputs:**
- List of backlog tickets (Open status only, filtered by user criteria)
- Ticket metadata (ID, summary, description, priority, etc.)

### Step 2: Analyze Ticket Completeness

**Action:** Check each ticket for required fields and quality

**Completeness Criteria:**
- ✅ **Has Summary** - Clear, concise title
- ✅ **Has Description** - Detailed explanation of the requirement
- ✅ **Has Acceptance Criteria** - Clear, testable conditions
- ✅ **Has Priority** - Set and appropriate
- ✅ **Has Type** - Correctly categorized (Story, Bug, Task, etc.)
- ✅ **Has Components/Tags** - Tagged with relevant areas
- ⚠️ **Has Dependencies** - Related tickets identified (if applicable)
- ⚠️ **Has Technical Notes** - Implementation considerations (if applicable)

**Quality Checks:**
- Description is not too vague or too detailed
- Acceptance Criteria are SMART (Specific, Measurable, Achievable, Relevant, Time-bound)
- Summary follows consistent format

**Output:** Completeness score for each ticket (0-100%)

### Step 3: Flag Tickets Needing Clarification

**Action:** Identify tickets that require discussion before grooming

**Flagging Criteria:**

**🔴 Critical Issues (Must Clarify):**
- Missing description
- Missing acceptance criteria
- Unclear requirements
- Conflicting information

**🟡 Important Issues (Should Clarify):**
- Vague description
- Incomplete acceptance criteria
- Missing dependencies
- No component tags

**🟢 Minor Issues (Nice to Clarify):**
- Missing labels
- Could use more detail
- Technical notes would help

**Output:** 
- Categorized list of tickets needing clarification
- Specific questions to ask for each ticket

### Step 4: Suggest Story Point Estimates

**Action:** Analyze similar tickets and suggest story point estimates

**Estimation Approach:**

1. **Find Similar Tickets:**
   - Search for completed tickets with similar characteristics:
     - Type
     - Components/tags
     - Description keywords
   - Filter to tickets with existing estimates

2. **Analyze Historical Data:**
   - Group similar tickets by story points
   - Calculate average complexity indicators:
     - Number of sub-tasks
     - Number of comments
     - Time to completion
     - Number of developers involved

3. **Generate Estimate Suggestions:**
   - **1 point** - Simple, well-understood changes (< 2 hours)
   - **2 points** - Small feature or fix (2-4 hours)
   - **3 points** - Standard feature (0.5-1 day)
   - **5 points** - Complex feature (1-2 days)
   - **8 points** - Major feature or technical work (3-5 days)
   - **13 points** - Epic-sized work (needs breakdown)

4. **Provide Rationale:**
   - Reference similar tickets
   - Highlight complexity factors
   - Note assumptions

**Output:**
- Suggested story points for each ticket
- Comparison with similar historical tickets
- Confidence level (High/Medium/Low)

### Step 5: Group Related Tickets

**Action:** Identify and group related work items

**Grouping Strategies:**

1. **By Epic/Parent:**
   - Group tickets under same parent/epic
   - Show hierarchy

2. **By Component/Area:**
   - Group tickets affecting same areas
   - Highlight cross-component dependencies

3. **By Theme:**
   - Identify common themes/features
   - Group by user journey or technical area

4. **By Dependency:**
   - Group tickets with dependencies
   - Show dependency chain

**Output:**
- Organized groups of related tickets
- Visual representation of relationships
- Suggested grooming order

### Step 6: Create Grooming Session Agenda

**Action:** Generate a structured agenda for the grooming session

**Agenda Structure:**

```markdown
# Backlog Grooming Session - [Date]

## Session Goals
- Review [X] tickets from backlog
- Target: [Y] story points estimated
- Focus areas: [Components/Themes]

## Agenda

### Part 1: Quick Wins (15 min)
**Complete Tickets Ready for Estimation:**
- [TICKET-1] - Summary (Suggested: 3 points)
- [TICKET-2] - Summary (Suggested: 2 points)

### Part 2: Tickets Needing Clarification (30 min)

#### 🔴 Critical Issues
- [TICKET-3] - Summary
  - **Issue:** Missing acceptance criteria
  - **Questions:** [List of questions]
  
#### 🟡 Important Issues
- [TICKET-4] - Summary
  - **Issue:** Vague requirements
  - **Questions:** [List of questions]

### Part 3: Complex Tickets Needing Discussion (30 min)

#### High Priority Complex Work
- [TICKET-5] - Summary (Suggested: 8 points)
  - **Complexity:** [Reasons]
  - **Similar Tickets:** [References]
  - **Discussion Points:** [Key considerations]

### Part 4: Related Work Groupings (15 min)

#### Group 1: [Feature/Epic Name]
- [TICKET-6] - Summary
- [TICKET-7] - Summary
- **Dependencies:** [Highlight dependencies]

### Part 5: Backlog Prioritization (10 min)
- Review priority rankings
- Identify next sprint candidates

## Summary Statistics
- Total tickets reviewed: [X]
- Tickets estimated: [Y]
- Average story points: [Z]
- Tickets needing follow-up: [N]

## Action Items
- [ ] Follow up on tickets needing clarification
- [ ] Schedule technical spike for [TICKET-X]
- [ ] Break down large tickets (13+ points)
```

**Output:** Complete grooming session agenda in Markdown format

## Workflow Execution

### Example Interaction

**Example 1: Basic Grooming Session**

```
User: Prepare grooming session

Cline: I'll prepare your backlog grooming session. Let me gather the information...

[Fetches Open status backlog tickets only]

Found 24 Open tickets in backlog. Analyzing...
[Analyzes completeness, estimates, and groupings]

✅ Analysis complete!
```

**Example 2: Grooming with Fix Version Filter**

```
User: Prepare grooming session for tickets with fix version "upcoming_version"

Cline: I'll prepare your backlog grooming session for tickets targeted for "upcoming_version"...

[Fetches Open status backlog tickets filtered by fixVersion = "upcoming_version"]

Found 15 Open tickets for upcoming_version. Analyzing...
[Analyzes completeness, estimates, and groupings]

✅ Analysis complete!
```

**Example 3: Grooming with Multiple Filters**

```
User: Prepare grooming session for high priority bugs in the Authentication component

Cline: I'll prepare your backlog grooming session with the specified filters...

[Fetches tickets with: status = Open AND priority = High AND issuetype = Bug AND component = "Authentication"]

Found 8 Open high-priority bugs in Authentication. Analyzing...

[Analyzes completeness, estimates, and groupings]

✅ Analysis complete!

📊 Summary:
- Total tickets: 24
- Complete & ready: 8 tickets (33%)
- Need clarification: 12 tickets (50%)
- Need breakdown: 4 tickets (17%)

🎯 Suggested Estimates:
- 1-2 points: 6 tickets
- 3-5 points: 10 tickets
- 8+ points: 8 tickets

📋 I've created a grooming session agenda. Would you like me to:
1. Show the full agenda
2. Save it to a file
3. Export to documentation platform
4. Create a tracking ticket for the grooming session
```

### Interactive Options

**During execution, Cline may ask:**

1. **Project Selection:**
   - "Which project's backlog should I analyze?"
   - Lists available projects from configuration

2. **Scope Selection:**
   - "How many tickets should I include?"
   - "Should I focus on specific components/tags?"
   - "Should I filter by fix version (e.g., 'upcoming_version')?"
   - "Should I filter by labels (e.g., 'needs-grooming', 'technical-debt')?"
   - "Should I filter by priority (e.g., High, Medium)?"
   - "Should I filter by issue type (e.g., Story, Bug, Task)?"
   - "Should I filter by created date (e.g., last 30 days)?"

3. **Estimation Context:**
   - "Should I include velocity data from past sprints?"
   - "Reference estimates from specific team members?"

4. **Output Format:**
   - "Where should I save the grooming agenda?"
   - "Should I export this to your documentation platform?"

## Advanced Features

### Feature 1: Historical Estimate Accuracy

**Action:** Track and improve estimate accuracy over time

```
Compare suggested estimates vs actual estimates:
- Show accuracy percentage
- Identify patterns in over/under estimation
- Adjust future suggestions based on team velocity
```

### Feature 2: Spike Identification

**Action:** Identify tickets that need technical investigation

**Spike Criteria:**
- High complexity with many unknowns
- New technology or approach
- Significant technical risk
- No similar historical tickets

**Output:** Suggest creating spike tickets for investigation

### Feature 3: Dependency Chain Analysis

**Action:** Visualize and optimize dependency chains

```
Analyze ticket dependencies:
- Identify critical path
- Flag circular dependencies
- Suggest optimal grooming order
- Highlight blockers
```

### Feature 4: Capacity Planning

**Action:** Compare backlog with team capacity

```
Calculate:
- Total story points in backlog
- Average team velocity
- Estimated sprints to clear backlog
- Prioritization recommendations
```

### Feature 5: Grooming Session Notes

**Action:** Create structured notes during the session

```
Track:
- Decisions made
- Estimates assigned
- Questions raised
- Action items
- Attendees

Export after session
```

## Output Examples

### Example 1: Ticket Completeness Report

```markdown
## Ticket Completeness Analysis

### ✅ Ready for Grooming (8 tickets)

1. **TICKET-123** - Add user authentication
   - Completeness: 95%
   - Suggested: 5 points (similar to TICKET-45, TICKET-89)
   - Priority: High

2. **TICKET-124** - Fix login crash
   - Completeness: 90%
   - Suggested: 2 points (similar to TICKET-102)
   - Priority: Urgent

### ⚠️ Needs Clarification (12 tickets)

1. **TICKET-125** - Improve performance
   - Completeness: 40%
   - Issues:
     - ❌ No acceptance criteria
     - ⚠️ Vague description
   - Questions:
     - Which specific areas need optimization?
     - What is the target performance metric?
     - Are there specific user complaints?

2. **TICKET-126** - Add new report feature
   - Completeness: 55%
   - Issues:
     - ⚠️ Missing component tags
     - ⚠️ No mockups or wireframes
   - Questions:
     - What data should be included?
     - What is the export format?
     - Who are the target users?
```

### Example 2: Related Tickets Grouping

```markdown
## Related Work Groups

### Group 1: Authentication Epic (5 tickets)
- **TICKET-123** - Add user authentication (5 pts)
- **TICKET-127** - Add biometric login (3 pts)
- **TICKET-128** - Add SSO support (8 pts)
- **TICKET-129** - Session management (3 pts)
- **TICKET-130** - Password reset flow (2 pts)

**Dependencies:**
- TICKET-127 depends on TICKET-123
- TICKET-128 depends on TICKET-123
- TICKET-129 depends on TICKET-123

**Suggested Order:** TICKET-123 → TICKET-129 → TICKET-127 → TICKET-130 → TICKET-128

### Group 2: Performance Optimization (3 tickets)
- **TICKET-131** - Optimize database queries (5 pts)
- **TICKET-132** - Add caching layer (8 pts)
- **TICKET-133** - Reduce API calls (3 pts)

**Theme:** Technical debt reduction
**Impact:** Improves app responsiveness by ~30%
```

## Best Practices

### Before Grooming Session

1. **Run analysis 1-2 days before session**
   - Gives time to clarify tickets
   - Allows Product Owner to prepare

2. **Share agenda with team in advance**
   - Team can review tickets beforehand
   - Come prepared with questions

3. **Limit session scope**
   - Target 15-20 tickets per session
   - Focus on upcoming sprint(s)

### During Grooming Session

1. **Start with quick wins**
   - Build momentum
   - Get easy tickets estimated

2. **Use historical data as reference**
   - Show similar tickets
   - Don't be bound by suggestions

3. **Time-box discussions**
   - 5 minutes per ticket max
   - Park complex discussions for follow-up

4. **Update tickets immediately**
   - Apply estimates as you go
   - Document decisions

### After Grooming Session

1. **Create action items**
   - Assign clarification tasks
   - Schedule spikes if needed

2. **Update backlog**
   - Move groomed tickets to "Ready"
   - Update priorities

3. **Track estimate accuracy**
   - Compare grooming estimates to final estimates
   - Improve future suggestions

## Configuration

### Atlassian MCP Server (for Jira/Confluence)

If using Jira or Confluence, the workflow accesses them through the **Atlassian MCP server**.

**Required Environment Variables:**

```bash
# Jira Configuration
JIRA_URL=https://your-domain.atlassian.net
JIRA_PERSONAL_TOKEN=your_jira_api_token

# Optional: Filter projects
JIRA_PROJECTS_FILTER=PROJ1,PROJ2

# Confluence Configuration (if needed)
CONFLUENCE_URL=https://your-domain.atlassian.net/wiki
CONFLUENCE_API_TOKEN=your_confluence_api_token
```

**Important Notes:**
- MCP server tools do NOT accept the `task_progress` parameter
- Only provide parameters that the MCP server tool explicitly accepts
- See [MCP Server Rules](../mcp-server-rules.md) for complete usage guidelines

### Example Project Configuration

```json
{
  "project": {
    "key": "PROJ",
    "grooming": {
      "backlog_status": "Open",
      "ready_status": "Ready for Development",
      "max_tickets_per_session": 20,
      "estimate_scale": [1, 2, 3, 5, 8, 13],
      "completeness_threshold": 70,
      "focus_components": ["Frontend", "Backend", "API"],
      "exclude_labels": ["on-hold", "blocked"],
      "default_filters": {
        "fix_version": "upcoming_version",
        "priority": ["High", "Medium"],
        "issue_types": ["Story", "Bug"],
        "created_within_days": 90
      }
    }
  }
}
```

**Configuration Notes:**
- `backlog_status` should be set to "Open" to ensure only open tickets are included
- `default_filters` are optional and can be customized per project
- User-specified filters during workflow execution will override default filters

## Integration with Other Workflows

### Works well with:

1. **Ticket creation workflows** - Create spike tickets during grooming
2. **Development workflows** - Start work on groomed tickets
3. **Sprint planning workflows** - Verify capacity before grooming
4. **Documentation workflows** - Reference docs during grooming
5. **Content generation workflows** - Flesh out incomplete tickets

### Example Combined Workflow:

```
1. User: Prepare grooming session
2. [Review analysis and agenda]
3. [During session: clarify tickets]
4. User: Generate detailed content for TICKET-125
5. [Create detailed story]
6. User: Check sprint status
7. [Verify capacity for groomed tickets]
```

## Troubleshooting

### Issue: No backlog tickets found

**Possible Causes:**
- Incorrect query or filter
- No tickets with "Open" status in backlog
- Tickets are in other statuses (In Progress, Needs Review, etc.)
- Insufficient permissions

**Solutions:**
1. Verify the JQL query includes `status = Open`
2. Check if tickets exist with "Open" status
3. Review project settings and status workflow
4. Verify access permissions

### Issue: Estimate suggestions seem inaccurate

**Possible Causes:**
- Insufficient historical data
- Team velocity changed
- Different team composition

**Solutions:**
1. Review similar tickets manually
2. Adjust estimates based on current team
3. Build estimation history over time

### Issue: Too many tickets flagged for clarification

**Possible Causes:**
- Low completeness threshold
- Tickets created without proper template
- New project with immature process

**Solutions:**
1. Adjust completeness threshold in config
2. Create ticket templates
3. Train team on ticket writing standards

## Metrics and Insights

### Track over time:

- **Average ticket completeness** - Improve ticket quality
- **Grooming velocity** - Tickets groomed per session
- **Estimate accuracy** - Compare initial vs final estimates
- **Clarification rate** - % of tickets needing clarification
- **Breakdown rate** - % of tickets needing breakdown

### Report on:

- **Backlog health** - % of tickets ready for grooming
- **Estimation confidence** - Based on similar tickets
- **Dependency complexity** - Number of dependency chains
- **Technical debt** - Tickets flagged as technical work

## Related Documentation

- [MCP Server Rules](../mcp-server-rules.md) - MCP server usage guidelines
- [jira-ticket-creation.md](./jira-ticket-creation.md) - Create Jira tickets
- [jira-ticket-search.md](./jira-ticket-search.md) - Search Jira tickets
- [check-sprint-status.md](./check-sprint-status.md) - Check sprint health
- [generate-jira-content.md](./generate-jira-content.md) - Generate story content

## Notes

- **For Jira/Confluence access:** This workflow uses the Atlassian MCP server
- **Status Filtering:** Only tickets with "Open" status are included in grooming sessions. Tickets in other statuses (In Progress, Needs Review, Responded, Reopened, Closed, Done, Resolved) are excluded.
- **User-Specified Filters:** Users can specify custom filtering criteria such as:
  - **Fix Version** - Target specific releases (e.g., `fixVersion = "upcoming_version"`, `fixVersion = "v2.0.0"`)
  - **Labels** - Focus on specific tags (e.g., `labels = "needs-grooming"`, `labels = "technical-debt"`)
  - **Components** - Analyze specific areas (e.g., `component = "Frontend"`, `component = "API"`)
  - **Priority** - Filter by urgency (e.g., `priority = High`)
  - **Issue Type** - Focus on specific work types (e.g., `issuetype = Story`, `issuetype = Bug`)
  - **Date Range** - Recent tickets only (e.g., `created >= -30d`)
- Estimates are suggestions based on historical data - use team judgment
- Grooming is collaborative - use this as a tool, not a replacement for discussion
- Regularly review and adjust estimation patterns based on team feedback
- Adapt the workflow to your team's specific needs and processes

## Maintenance

**Last Updated:** 2025-12-10
**Next Review:** 2026-03-10

**Update Triggers:**
- Changes in estimation practices
- New ticket fields or workflows
- Team feedback on grooming efficiency
- Changes in backlog management process
