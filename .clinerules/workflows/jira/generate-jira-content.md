# Generate Jira Content Workflow

**Trigger Commands:**
- `generate jira content`
- `create jira story from content`
- `jira content to story`
- `generate detailed jira story`

**Description:**
Automated workflow for generating detailed Jira stories from provided content. This workflow transforms unstructured content into a properly formatted Jira story with comprehensive scope, acceptance criteria, dependencies, and Definition of Done.

## Overview

This workflow automates the manual process of creating detailed Jira stories by:
1. **User provides context** - Describe the feature/requirement in any format
2. **Cline analyzes content** - Extracts requirements and generates structured story
3. **Generates description** - Creates formatted description with all sections (In Scope, Out of Scope, Acceptance Criteria, Dependencies, DoD)
4. **Generates summary** - Creates concise one-line summary for the ticket
5. **User reviews** - Display generated content for approval/modification
6. **Creates Jira ticket** - After approval, creates story via Atlassian MCP server
7. **Returns confirmation** - Provides ticket key and URL

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
```
File: ~/Library/Application Support/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json
```

**Verify MCP Server is Connected:**
Check that the `mcp-atlassian` server appears in the connected MCP servers list in Cline's environment details.

### 2. Required Permissions

Your Jira account must have:
- Permission to create issues in the target project
- Access to the Project Backlog
- Appropriate issue type permissions (Story)
- Browse Projects permission

## Story Structure Format

The workflow generates stories in the following format:

```
As an Engineering Manager/Engineer, I want to [capability/feature]
So that [benefit/value].

In Scope:
- [Feature/functionality 1]
- [Feature/functionality 2]
- [Feature/functionality 3]

Out of Scope:
- [Excluded feature 1]
- [Excluded feature 2]
- [Future enhancement]

Acceptance Criteria:
- [Testable criterion 1]
- [Testable criterion 2]
- [Testable criterion 3]

Dependencies:
- [Technical dependency]
- [Team dependency]
- [Prerequisite ticket reference]

Definition of Done:
- [Completion requirement 1]
- [Completion requirement 2]
- [Quality gate]
- [Documentation requirement]
```

## Workflow Steps

### Step 1: User Provides Content

**User provides:**
- Context and description of the Jira story
- Can be in any format:
  - Meeting notes
  - Requirements
  - User feedback
  - Technical specifications
  - Bullet points
  - Paragraphs

**Example:**
```
User: generate jira content

We need to add authentication to the mobile app. Users want to log in 
with their existing accounts instead of creating new ones. Marketing 
says this will improve conversion by 30%. Need it before Q2 launch.
Security team needs to review. Design will provide mockups next week.
```

### Step 2: Cline Analyzes and Generates Description

**Cline will:**
1. Analyze the provided content
2. Extract key requirements and scope
3. Generate a formatted description in the format:

```
As an Engineering Manager/Software Engineer, I want to [capability]
So that [benefit].

In Scope:
- [Feature 1]
- [Feature 2]
- [Feature 3]

Out of Scope:
- [Excluded feature 1]
- [Excluded feature 2]

Acceptance Criteria:
- [Criterion 1]
- [Criterion 2]
- [Criterion 3]

Dependencies:
- [Dependency 1]
- [Dependency 2]

Definition of Done:
- [Completion requirement 1]
- [Completion requirement 2]
- [Quality gate]
```

4. Generate a concise summary line (for the Jira ticket summary field)

### Step 3: Review and Approval

**CRITICAL: All generated content MUST be shown to the user for approval before creating the Jira ticket.**

**Cline will display:**
1. **Proposed Summary:** A one-line summary of the story
2. **Generated Description:** The full formatted description including all sections (User Story, In Scope, Out of Scope, Acceptance Criteria, Dependencies, Definition of Done, Technical Considerations)
3. **Additional Fields:** Priority, labels, estimated effort (if generated)

**User MUST:**
- ✅ **Approve** - Explicitly approve the content before Cline proceeds to create the Jira ticket
- ❌ **Reject** - Cancel the workflow entirely
- ✏️ **Modify** - Request changes to any part of the generated content (summary, description, sections, priority, labels, etc.)

**Important Notes:**
- Cline will NEVER create the Jira ticket without explicit user approval
- Users should review all sections carefully before approving
- Any modifications requested will regenerate the content for another review
- The approval step ensures accuracy and quality before ticket creation

**Example interaction:**
```
Cline: I've generated the following Jira story. Please review carefully before I create the ticket.

📋 Proposed Summary:
"Implement Single Sign-On Authentication"

📝 Generated Description:
As an Engineering Manager/Software Engineer, I want to implement SSO authentication
So that users can log in with existing accounts and improve conversion by 30%.

In Scope:
- SSO integration with authentication providers
- Login UI with provider selection
- Token management and secure storage
- User profile synchronization
- All supported platforms

Out of Scope:
- Additional authentication methods (future)
- Legacy authentication removal
- Account merging functionality

Acceptance Criteria:
- User can successfully authenticate via SSO
- Login errors display clear messages
- Authentication tokens are securely stored
- User profile syncs on first login
- Design specifications implemented
- 30% improvement in login conversion rate

Dependencies:
- Backend SSO endpoints deployed
- SSO provider credentials configured
- Security review completed
- Design mockups finalized

Definition of Done:
- Code implemented for all platforms
- Unit and integration tests passing
- Security review approved
- Code reviewed by team members
- QA verification completed
- Documentation updated
- Deployed to production before Q2

🏷️ Additional Fields:
Priority: Medium
Labels: authentication, sso, security, conversion
Estimated Effort: 8 Story Points

⚠️ APPROVAL REQUIRED: I need your explicit approval before creating this Jira ticket.

Would you like to:
1. ✅ Approve and create Jira ticket
2. ✏️ Modify the summary, description, or other fields
3. ❌ Cancel workflow

Please review all sections carefully and let me know your decision.
```

### Step 4: Create Jira Ticket (Only After User Approval)

**IMPORTANT: This step is executed ONLY after receiving explicit user approval.**

**Once user explicitly approves, Cline will:**
1. Use the `jira_create_issue` MCP tool
2. Create the story with:
   - **Summary:** The approved summary line
   - **Description:** The approved formatted description
   - **Issue Type:** Story
   - **Priority:** As specified or default to Medium

**MCP Tool Usage:**
```
<use_mcp_tool>
<server_name>mcp-atlassian</server_name>
<tool_name>jira_create_issue</tool_name>
<arguments>
{
  "project_key": "PROJ",
  "summary": "[Approved summary line]",
  "issue_type": "Story",
  "description": "[Approved formatted description]",
  "priority": "Medium"
}
</arguments>
</use_mcp_tool>
```

### Step 5: Confirm Creation

**Cline will provide:**
- ✅ Confirmation of successful creation
- 🔑 Jira ticket key (e.g., PROJ-150)
- 🔗 Direct URL to the created ticket
- 📊 Summary of what was created

**Example:**
```
✅ Jira Story Created Successfully!

Key: PROJ-150
URL: https://your-domain.atlassian.net/browse/PROJ-150
Summary: Implement Single Sign-On Authentication
Type: Story
Priority: Medium

Next steps:
- Review the ticket in Jira
- Add any additional details if needed
- Assign to appropriate team member
- Add to sprint backlog
```

## Usage Examples

### Example 1: From Meeting Notes

```
User: generate jira content

Cline: Please provide the content to analyze.

User: Meeting notes from product sync:
      - Users are having trouble with the login flow
      - They want single sign-on with existing accounts
      - Marketing says this will improve conversion by 30%
      - Need this across all platforms
      - Should be done before Q2 launch
      - Security team needs to review implementation
      - Design team will provide mockups next week

Cline: I'll generate a detailed Jira story from this content.
      
      [Analyzes content and generates structured story]
      
      ✅ Generated Jira Story:
      
      Summary: Implement Single Sign-On Authentication
      
      User Story:
      As a User,
      I want to log in using my existing account credentials,
      So that I can access the application quickly without creating new credentials.
      
      In Scope:
      - SSO integration with authentication providers
      - Login UI with provider selection
      - Token management and secure storage
      - User profile synchronization
      - Error handling and user feedback
      - All supported platforms
      
      Out of Scope:
      - Additional authentication methods (future)
      - Legacy authentication removal
      - Account merging functionality
      
      Acceptance Criteria:
      - [ ] User can successfully authenticate via SSO
      - [ ] Login errors display clear messages
      - [ ] Authentication tokens are securely stored
      - [ ] User profile syncs on first login
      - [ ] Design specifications implemented
      - [ ] 30% improvement in login conversion rate
      
      Dependencies:
      - Backend SSO endpoints deployed
      - SSO provider credentials configured
      - External service registrations completed
      - Security review completed
      - Design mockups finalized
      
      Definition of Done:
      - [ ] Code implemented for all platforms
      - [ ] Unit and integration tests passing
      - [ ] Security review approved
      - [ ] Code reviewed by team members
      - [ ] QA verification completed
      - [ ] Documentation updated
      - [ ] Deployed to production before Q2
      - [ ] Conversion metrics tracked
      
      Technical Considerations:
      - Follow OAuth 2.0 best practices
      - Secure token storage mechanisms
      - Token refresh before expiry
      - Callback URL handling
      - Network retry logic
      
      Estimated Effort: 8 Story Points
      Labels: authentication, sso, security, conversion
      Priority: High
      
      Would you like me to create this as a Jira ticket?

User: yes

Cline: Creating Jira ticket...
      
      ✅ Ticket created successfully!
      
      Key: PROJ-150
      URL: https://your-domain.atlassian.net/browse/PROJ-150
      
      Summary: Implement Single Sign-On Authentication
      Type: Story
      Priority: High
      Labels: authentication, sso, security, conversion
```

### Example 2: From Technical Specification

```
User: generate jira story from content

Content:
Technical Specification: Real-Time Notification System

Background:
Current system lacks real-time notifications. Users miss important updates.

Requirements:
- Support multiple notification channels
- Handle permission requests
- Support deep linking to relevant content
- Track notification analytics
- Allow users to customize notification preferences
- Support rich content notifications
- Background notification handling

Constraints:
- Must work offline (queue notifications)
- Resource-efficient implementation
- Privacy compliant (user consent required)
- Minimal performance impact

Non-functional Requirements:
- 99.9% delivery rate
- < 5 second delivery latency
- Support 10,000 concurrent users

Cline: [Generates detailed story]
      
      ✅ Generated Jira Story:
      
      Summary: Implement Real-Time Notification System
      
      User Story:
      As a User,
      I want to receive real-time notifications,
      So that I stay informed about important updates even when not actively using the system.
      
      In Scope:
      - Notification channel integrations
      - Permission request handling
      - Deep linking to specific content
      - Rich content notification support
      - Background notification processing
      - Notification analytics tracking
      - User preference management
      - Offline notification queuing
      
      Out of Scope:
      - Alternative notification channels (future)
      - Email notifications (separate system)
      - SMS notifications (separate system)
      - In-app notification center
      - Notification scheduling features
      
      Acceptance Criteria:
      - [ ] Notifications delivered successfully across channels
      - [ ] Permission requests follow platform guidelines
      - [ ] Deep links navigate to correct content
      - [ ] Rich content displays correctly
      - [ ] Background notifications processed correctly
      - [ ] Analytics track delivery and engagement
      - [ ] Users can customize preferences
      - [ ] Notifications queue offline and sync when online
      - [ ] 99.9% delivery rate achieved
      - [ ] < 5 second average delivery latency
      - [ ] Resource usage remains acceptable
      - [ ] Privacy compliance implemented
      
      Dependencies:
      - Backend notification service deployed
      - Notification provider credentials configured
      - External service registrations completed
      - Analytics platform integration
      - User preferences API endpoints
      
      Definition of Done:
      - [ ] All channel integrations complete
      - [ ] Permission flows implemented
      - [ ] Deep linking functional
      - [ ] Rich content support working
      - [ ] Analytics tracking implemented
      - [ ] User preferences functional
      - [ ] Offline queuing working
      - [ ] Unit tests >80% coverage
      - [ ] Integration tests passing
      - [ ] Performance benchmarks met
      - [ ] Privacy compliance verified
      - [ ] QA sign-off received
      - [ ] Documentation complete
      
      Technical Considerations:
      - Use appropriate notification protocols
      - Implement offline queue with persistent storage
      - Resource-efficient background processing
      - Secure credential storage
      - Rate limiting for API calls
      - Content caching for rich notifications
      - Deep link URL scheme registration
      
      Estimated Effort: 13 Story Points
      Labels: notifications, real-time, analytics
      Priority: High
      
      ✅ Created Jira ticket PROJ-151
```

### Example 3: From User Feedback

```
User: create jira story from content

Content:
User feedback from support tickets:
- 15 users complained about slow search (tickets #234, #235, #239)
- Average search time is 8 seconds
- Users expect results in <2 seconds
- Most searches are for common queries
- Some users searching by category or filters
- Performance degradation across platforms

Cline: [Generates story]
      
      ✅ Generated Jira Story:
      
      Summary: Improve Search Performance to <2 Seconds
      
      User Story:
      As a User,
      I want search results to appear quickly (< 2 seconds),
      So that I can find information efficiently without frustration.
      
      In Scope:
      - Search performance optimization
      - Common query optimization
      - Category and filter search improvements
      - Search result caching
      - Performance monitoring
      
      Out of Scope:
      - Advanced filtering features (future)
      - Search UI redesign
      - Voice search capabilities
      - Search analytics dashboard
      
      Acceptance Criteria:
      - [ ] Search results return in < 2 seconds (95th percentile)
      - [ ] Common query search < 1 second
      - [ ] Category search < 2 seconds
      - [ ] Filter search < 2 seconds
      - [ ] Performance consistent across platforms
      - [ ] No regression in search accuracy
      - [ ] Performance monitoring in place
      - [ ] 95% reduction in support tickets
      
      Dependencies:
      - Backend search API optimization
      - Database indexing improvements
      - Search infrastructure upgrades
      - Performance testing environment
      
      Definition of Done:
      - [ ] Search performance <2 seconds verified
      - [ ] Load testing completed (10,000 concurrent searches)
      - [ ] Cross-platform testing completed
      - [ ] Performance monitoring dashboard live
      - [ ] User satisfaction metrics improved
      - [ ] Support ticket volume reduced
      - [ ] Code reviewed and deployed
      - [ ] Documentation updated
      
      Technical Considerations:
      - Implement search result caching
      - Add database indexes on frequently searched fields
      - Use CDN for static search data
      - Lazy load search results (pagination)
      - Debounce search input (300ms)
      - Prefetch popular searches
      - Monitor with performance tools
      
      Estimated Effort: 5 Story Points
      Labels: performance, search, optimization, user-experience
      Priority: High
```

## Prompt Templates

### Template 1: Quick Generation
```
generate jira content

[Paste your content]
```

### Template 2: With Context
```
create jira story from content with context

Content: [paste content]

Context:
- Project: Mobile Shopping App
- Current state: Basic search exists but slow
- Business goal: Reduce cart abandonment due to poor search
```

### Template 3: Specify Audience
```
generate detailed jira story for product manager

Content: [paste content]
```

### Template 4: With Priority
```
jira content to story priority high

Content: [paste content]
```

## Advanced Features

### 1. Multi-Story Generation

**When content describes multiple features:**

```
User: generate jira content

Content:
Sprint planning notes:
1. Add social login (Google, Facebook)
2. Implement push notifications
3. Add user profile editing
4. Create settings screen

Cline: I've identified 4 separate stories in your content.
      Would you like me to:
      1. Generate all 4 stories
      2. Generate one story per request
      3. Combine related stories

User: generate all 4 stories

Cline: [Generates 4 separate detailed stories]
      
      ✅ Generated 4 Jira Stories:
      
      1. PROJ-200: Implement Social Login (OAuth 2.0)
      2. PROJ-201: Add Push Notification System
      3. PROJ-202: Implement User Profile Editing
      4. PROJ-203: Create Settings Screen
      
      All stories created with full details.
```

### 2. Story Refinement

**Iteratively improve the generated story:**

```
User: generate jira content
      [provides content]

Cline: [Generates initial story]

User: Add more technical details about database schema

Cline: [Updates story with database considerations]

User: Include performance requirements

Cline: [Adds performance criteria to acceptance criteria and technical considerations]

User: Looks good, create the ticket

Cline: ✅ Created PROJ-204
```

### 3. Template Customization

**Custom story templates for specific project types:**

```json
{
  "storyTemplates": {
    "mobile_feature": {
      "sections": [
        "User Story",
        "In Scope",
        "Out of Scope",
        "Acceptance Criteria",
        "iOS Implementation Details",
        "Android Implementation Details",
        "Dependencies",
        "Definition of Done",
        "Testing Strategy"
      ]
    },
    "bug_fix": {
      "sections": [
        "Bug Description",
        "Steps to Reproduce",
        "Expected vs Actual Behavior",
        "Root Cause Analysis",
        "Fix Implementation",
        "Testing Plan",
        "Regression Prevention"
      ]
    },
    "technical_debt": {
      "sections": [
        "Current State",
        "Problems",
        "Proposed Solution",
        "Benefits",
        "Migration Plan",
        "Rollback Strategy",
        "Success Metrics"
      ]
    }
  }
}
```

## Content Analysis Tips

**For best results, provide content that includes:**

1. **The What** - What needs to be built/fixed
2. **The Why** - Why it's needed (business value)
3. **The Who** - Who will use it or benefit
4. **The When** - Any timing constraints
5. **The How** (optional) - Technical approach if known
6. **The Constraints** - Limitations or requirements

**Example of good content:**

```
Content:
What: Add biometric authentication to mobile apps
Why: 60% of users want faster login. Competitors have this feature.
Who: All mobile app users (iOS & Android)
When: Need before Q2 release (March 31)
How: Use Face ID/Touch ID on iOS, BiometricPrompt on Android
Constraints: Must work offline, <500KB app size increase
```

## Troubleshooting

### Issue 1: Generated Story Too Generic

**Problem:** Story lacks specific details

**Solution:**
- Provide more detailed content
- Include technical specifications
- Add business context and metrics
- Specify acceptance criteria explicitly

### Issue 2: Wrong User Story Format

**Problem:** "As an X" statement doesn't fit

**Solution:**
```
User: The user story should be "As a System" not "As a User"

Cline: [Regenerates with correct perspective]
      
      As a System Administrator,
      I want to configure notification settings,
      So that I can control system alerts.
```

### Issue 3: Missing Technical Details

**Problem:** Technical considerations are too high-level

**Solution:**
```
User: Add more technical details about:
      - Database schema changes
      - API endpoints needed
      - Security requirements
      - Performance benchmarks

Cline: [Enhances technical considerations section]
```

### Issue 4: Scope Too Large

**Problem:** Generated story is too big for one sprint

**Solution:**
```
User: Split this into smaller stories

Cline: [Analyzes scope and suggests breakdown]
      
      I can split this into 3 stories:
      1. Core authentication flow (5 pts)
      2. Social provider integration (8 pts)
      3. Security and error handling (3 pts)
      
      Would you like me to generate all 3?
```

## Best Practices

1. **Provide Detailed Content** - More context = better story
2. **Include Business Value** - Explain why it matters
3. **Specify Constraints** - Performance, security, etc.
4. **List Dependencies** - What's needed before/during
5. **Define Success** - How to measure completion
6. **⚠️ ALWAYS Review Before Approving** - Carefully verify all generated content (summary, description, sections, priority, labels) before giving approval
7. **Refine Iteratively** - Request modifications as needed until content is perfect
8. **Use Consistent Format** - Follow team conventions
9. **Link Related Work** - Reference other tickets
10. **Update After Creation** - Refine based on feedback in Jira if needed

## Integration with Other Workflows

### With Jira Ticket Creation
```
generate jira content
[generates story]
create jira ticket
[creates ticket with generated content]
```

### With Git Branch
```
generate jira content
[creates PROJ-205]
create branch feature/PROJ-205-add-biometric-auth
```

### With Sprint Planning
```
generate jira content for sprint
[generates multiple stories]
add all to Sprint 24
```

## Configuration

**Optional configuration in `cline_workflow_config.json`:**

```json
{
  "jiraContentGeneration": {
    "defaultProject": "PROJ",
    "defaultIssueType": "Story",
    "defaultPriority": "Medium",
    "defaultAudience": "Engineering Manager",
    "includeEstimation": true,
    "includeTechnicalConsiderations": true,
    "autoCreateTicket": false,
    "storyPointOptions": [1, 2, 3, 5, 8, 13, 21],
    "commonLabels": [
      "mobile",
      "ios",
      "android",
      "backend",
      "frontend",
      "performance",
      "security",
      "authentication",
      "notifications"
    ]
  }
}
```

## Related Workflows

- `jira-ticket-creation` - Create basic Jira tickets
- `jira-ticket-search` - Search existing tickets
- `jira-to-code` - Sprint workflow from ticket to code
- `git-commit` - Commit with Jira references

## Quick Reference

### Trigger Commands
```
generate jira content
create jira story from content
jira content to story
generate detailed jira story
```

### Required Input
- Content to analyze (meeting notes, specs, feedback, etc.)

### Optional Input
- Context (project background, related work)
- Target audience (Engineer, PM, QA, etc.)
- Priority (Highest to Lowest)

### Generated Components
- User Story ("As an X, I want Y, so that Z")
- In Scope (what will be delivered)
- Out of Scope (what won't be delivered)
- Acceptance Criteria (testable requirements)
- Dependencies (prerequisites and blockers)
- Definition of Done (completion checklist)
- Technical Considerations (architecture, tech choices)
- Estimated Effort (story points)
- Labels (categorization tags)

### Output
- Formatted Jira story (markdown)
- Created Jira ticket (with key and URL)
- Summary of generated components

## Notes

- **⚠️ CRITICAL:** All generated content MUST be shown to the user and explicitly approved before Jira ticket creation
- Stories follow standard Agile format
- Acceptance criteria are testable and specific
- Dependencies highlight blockers early
- Technical considerations guide implementation
- Definition of Done ensures quality
- Labels improve discoverability
- Content analysis uses AI to extract key information
- Supports multiple content types (notes, specs, feedback)
- Can generate single or multiple stories
- Integrates with other Jira workflows
- User approval is mandatory - Cline will never auto-create tickets without explicit confirmation

---

**Last Updated:** 2025-12-03
**Version:** 1.0
**Maintainer:** Development Team
