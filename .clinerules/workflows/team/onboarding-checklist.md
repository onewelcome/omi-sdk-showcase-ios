# Onboarding Checklist Workflow

**Trigger Commands:**
- `onboard new developer [NEWCOMER'S NAME]`
- `onboard [NAME]`
- `start onboarding for [NAME]`
- `create onboarding checklist`

**Description:**
Automated workflow for onboarding new team members. This workflow streamlines the onboarding process by creating a Confluence onboarding page with structured checklists, preparing Slack welcome messages, and facilitating buddy/mentor assignment. Optionally creates starter Jira tickets for tracking specific onboarding tasks.

## Overview

This workflow automates the onboarding process by:
1. Creating a personalized Confluence page for tracking all onboarding activities
2. Generating structured checklist for setup, documentation, and starter tasks
3. Preparing Slack welcome messages and channel invitations
4. Setting up initial meetings and checkpoints

**IMPORTANT:** This workflow uses the **Atlassian MCP server** for Confluence access, NOT direct API calls. The MCP server provides reliable access with proper authentication and error handling.

## Prerequisites

### 1. Atlassian MCP Server Configuration

**Required MCP Server:**
The Atlassian MCP server must be configured with the following environment variables:

```bash
# Required environment variables for Atlassian MCP server
JIRA_URL=https://your-domain.atlassian.net
JIRA_PERSONAL_TOKEN=your-personal-access-token
CONFLUENCE_URL=https://your-domain.atlassian.net/wiki
CONFLUENCE_API_TOKEN=your-api-token
```

**Configuration Location:**
```
File: ~/Library/Application Support/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json
```

**Verify MCP Server:**
Check that `mcp-atlassian` appears in connected MCP servers with available tools:
- `jira_create_issue`
- `jira_update_issue`
- `confluence_create_page`
- `confluence_update_page`

### 2. Slack Configuration

**Optional Slack Integration:**

```json
{
  "slackConfig": {
    "webhookUrl": "https://hooks.slack.com/services/YOUR/WEBHOOK/URL",
    "defaultChannel": "#team-introductions",
    "onboardingChannel": "#onboarding"
  }
}
```

**Configuration File:**
```
File: /Users/[USER_TGI]/Documents/Cline/Settings/cline_workflow_config.json
```

### 3. Required Permissions

Your accounts must have:
- **Jira:** Create issues, assign issues (optional, for starter tickets)
- **Confluence:** Create pages, edit pages in onboarding space
- **Slack:** Post messages to channels (via webhook)

## Workflow Structure

### Confluence Page Structure

**Page:** [NEWCOMER] - Onboarding Guide
- Welcome message
- Team contacts
- Important links
- Week-by-week goals
- Resources and documentation
- Common questions

## Workflow Steps

### Step 1: Gather Onboarding Information

**Cline will collect:**

1. **Newcomer's Name** (required)
   - Full name of the new team member
   - Example: "John Doe"

2. **Start Date** (optional, default: today)
   - First day on the team
   - Example: "2025-03-01"

3. **Role/Position** (required)
   - Job title or role
   - Example: "Senior Mobile Developer", "Backend Engineer"

4. **Team** (optional)
   - Team or squad assignment
   - Example: "Authentication Team", "Mobile Team"

5. **Buddy/Mentor** (optional)
   - Assigned mentor for guidance
   - Example: "jane.smith@company.com"

6. **Manager** (optional)
   - Direct manager
   - Example: "manager@company.com"

7. **Special Requirements** (optional)
   - Any specific needs or focus areas
   - Example: "iOS development focus", "Security clearance needed"

### Step 2: Create Confluence Onboarding Page

**Page Creation via MCP:**

The Confluence page serves as the central tracking hub and includes:
- Welcome message and quick info
- Structured checklist for all onboarding activities
- Week-by-week goals (30-60-90 days)
- Essential documentation links
- Important contacts
- Common questions

### Step 3: Generate Starter Jira Tickets

**Creating Initial Tasks:**

For each newcomer, the workflow can optionally create starter Jira tickets tagged with 'good-first-issue' and 'onboarding' labels to help them begin contributing.

**Sub-task 1: Development Environment Setup**

```xml
<invoke name="c_l3Q10mcp0jira_create_issue">
  <parameter name="project_key">ONBOARD</parameter>
  <parameter name="summary">Development Environment Setup</parameter>
  <parameter name="issue_type">Sub-task</parameter>
  <parameter name="description">**Goal:** Set up complete development environment

**PC Environment Setup:**
- [ ] **Operating System Configuration**
  - Mac: Install Homebrew, configure system preferences
  - Windows: Install WSL2 (if needed), configure PowerShell
  - Install OS-specific command line tools
- [ ] **VPN Setup**
  - Install corporate VPN client
  - Configure VPN credentials and certificates
  - Test VPN connectivity to internal resources
  - Verify access to internal repositories and services
- [ ] **Network Configuration**
  - Configure proxy settings (if required)
  - Set up DNS and network access
  - Test connectivity to development servers

**Development Tools Installation:**
- [ ] Install required IDEs and development tools
  - Android Studio (for Android development)
  - Xcode (for iOS development, Mac only)
  - VS Code with essential extensions
- [ ] Configure Git and SSH keys
  - Generate SSH key pair
  - Add SSH key to GitLab/GitHub
  - Configure Git global settings (name, email)
- [ ] Clone project repositories
  - Clone main project repository
  - Clone related/dependency repositories
  - Verify repository access

**Android Build Environment:**
- [ ] **Android Studio Setup**
  - Install Android Studio (latest stable version)
  - Install Android SDK and build tools
  - Configure SDK locations and paths
  - Install required Android SDK platforms (API levels)
  - Install NDK (if native code is used)
- [ ] **Android Emulator Configuration**
  - Create Android Virtual Devices (AVDs)
  - Configure emulator settings (RAM, storage, etc.)
  - Test emulator launch and performance
- [ ] **Android Project Setup**
  - Open project in Android Studio
  - Sync Gradle dependencies
  - Configure signing certificates (debug keystore)
  - Build project successfully
  - Run app on emulator/device

**iOS Build Environment (Mac only):**
- [ ] **Xcode Setup**
  - Install Xcode from App Store
  - Install Xcode Command Line Tools
  - Accept Xcode license agreement
  - Configure Xcode preferences
- [ ] **iOS Simulator Configuration**
  - Install iOS simulators for target versions
  - Configure simulator settings
  - Test simulator launch
- [ ] **iOS Project Setup**
  - Open project in Xcode
  - Install CocoaPods dependencies (`pod install`)
  - Configure provisioning profiles and certificates
  - Set up development team in Xcode
  - Build project successfully
  - Run app on simulator/device
- [ ] **Additional iOS Tools**
  - Install fastlane (if used for deployment)
  - Install SwiftLint (if used for code quality)
  - Configure iOS development certificates

**Project Dependencies:**
- [ ] Install project dependencies
  - Node.js and npm/yarn (if applicable)
  - Ruby and required gems
  - Python and required packages
  - Platform-specific package managers
- [ ] Set up development environment (databases, services, etc.)
  - Install and configure local databases
  - Set up mock servers or test environments
  - Configure environment-specific settings
- [ ] Configure environment variables
  - Create `.env` files with required variables
  - Configure API keys and secrets
  - Set up environment-specific configurations
- [ ] Install required CLI tools
  - Install Gradle (if not using wrapper)
  - Install fastlane, CocoaPods
  - Install platform-specific build tools

**Verification:**
- [ ] Test build: Run project successfully
  - Android: Build and run on emulator
  - iOS: Build and run on simulator
  - Verify all features load correctly
- [ ] Run automated tests
  - Unit tests pass
  - Integration tests pass
  - UI tests pass (if applicable)

**Resources:**
- Development Setup Guide: [Confluence link]
- Repository Access: [GitLab link]
- Android Setup Documentation: [Link]
- iOS Setup Documentation: [Link]
- VPN Setup Guide: [IT Support link]

**Acceptance Criteria:**
- PC environment fully configured (Mac/Windows, VPN access)
- Can build and run applications locally on both Android and iOS
- All required tools installed and verified
- Environment variables configured
- Tests run successfully
- VPN connectivity working</parameter>
  <parameter name="assignee">john.doe@company.com</parameter>
  <parameter name="additional_fields">{"parent": "ONBOARD-123", "priority": {"name": "High"}}</parameter>
</invoke>
```

**Sub-task 2: Access and Permissions**

```xml
<invoke name="c_l3Q10mcp0jira_create_issue">
  <parameter name="project_key">ONBOARD</parameter>
  <parameter name="summary">Access and Permissions</parameter>
  <parameter name="issue_type">Sub-task</parameter>
  <parameter name="description">**Goal:** Obtain all necessary access and permissions

**Jira Access:**
- [ ] **Jira Account Setup**
  - Create Jira account (if not already created)
  - Configure Jira profile and notifications
  - Learn Jira basics (create, search, update tickets)
- [ ] **Jira Project Access**
  - Access to main project(s): [PROJECT-KEY]
  - Access to onboarding project: ONBOARD
  - Access to related projects: [List related projects]
  - Verify permissions to create/edit issues
  - Join project boards and filters
- [ ] **Jira Permissions Verification**
  - Can view and create tickets
  - Can update and transition tickets
  - Can assign tickets to self
  - Can comment and mention team members
  - Can access sprint boards and backlogs

**Confluence Access:**
- [ ] **Confluence Account Setup**
  - Create Confluence account (if not already created)
  - Configure Confluence profile and notifications
  - Learn Confluence basics (view, create, edit pages)
- [ ] **Confluence Space Access**
  - Access to team space: [SPACE-KEY]
  - Access to onboarding space: ONBOARD
  - Access to documentation space: [DOC-SPACE]
  - Access to architecture space: [ARCH-SPACE]
  - Verify permissions to create/edit pages
- [ ] **Confluence Permissions Verification**
  - Can view all required documentation
  - Can create personal pages
  - Can comment on pages
  - Can edit team pages (if appropriate)
  - Can add attachments and images

**Development Tools Access:**
- [ ] **Version Control Repository Access**
  - GitLab/GitHub account created
  - SSH keys added to profile
  - Access to main repositories
  - Access to related repositories
  - Verify clone/push permissions
- [ ] **CI/CD Pipeline Access**
  - Access to build pipelines
  - Can view build logs and artifacts
  - Can trigger manual builds (if needed)
  - Access to deployment dashboards

**Communication Tools:**
- [ ] **Team Communication Channels**
  - Slack/Teams account activated
  - Join team channels: [#team-channel]
  - Join engineering channels: [#engineering]
  - Join social channels: [#social]
  - Configure notification preferences
- [ ] **Email and Calendar**
  - Email account configured
  - Calendar access and team calendars added
  - Meeting invites for team ceremonies

**Network and Security:**
- [ ] **VPN Access Configured**
  - VPN client installed and configured
  - VPN credentials provided
  - Test VPN connection successful
  - Access to internal resources verified
- [ ] **Security and Compliance**
  - Security training completed
  - Compliance acknowledgments signed
  - Access badges/tokens issued (if physical access needed)

**Cloud and Infrastructure:**
- [ ] **Cloud Resources Access (if needed)**
  - AWS/Azure/GCP console access
  - Required IAM roles assigned
  - Access to staging environments
  - Access to development databases
- [ ] **Internal Tools and Services Access**
  - API gateway access
  - Monitoring dashboards (Grafana, etc.)
  - Log aggregation tools (Splunk, etc.)
  - Error tracking (Sentry, etc.)

**Mobile-Specific Access:**
- [ ] **Android Development**
  - Access to Google Play Console (if needed)
  - Access to Firebase projects
  - Access to crash reporting tools
  - Access to analytics platforms
- [ ] **iOS Development**
  - Apple Developer account access
  - Access to App Store Connect (if needed)
  - Certificates and provisioning profiles
  - Access to TestFlight

**Point of Contact:**
- IT Support: it-support@company.com
- Manager: [manager email]
- Jira Admin: [jira-admin email]
- Confluence Admin: [confluence-admin email]

**Verification Checklist:**
- [ ] Can access all required systems
- [ ] Can view and create Jira tickets in project
- [ ] Can view and edit Confluence pages in team space
- [ ] Can clone and push to repositories
- [ ] VPN connects successfully
- [ ] Can access CI/CD pipelines
- [ ] Joined all team communication channels
- [ ] Cloud resources accessible (if applicable)
- [ ] Mobile development accounts configured

**Access Issues:**
If you encounter access issues:
1. Check with IT Support first
2. Verify with your manager
3. Contact specific tool admins
4. Document issues in this ticket</parameter>
  <parameter name="assignee">john.doe@company.com</parameter>
  <parameter name="additional_fields">{"parent": "ONBOARD-123", "priority": {"name": "High"}}</parameter>
</invoke>
```

**Sub-task 3: Documentation Review**

```xml
<invoke name="c_l3Q10mcp0jira_create_issue">
  <parameter name="project_key">ONBOARD</parameter>
  <parameter name="summary">Documentation Review</parameter>
  <parameter name="issue_type">Sub-task</parameter>
  <parameter name="description">**Goal:** Review essential documentation and understand project context

**Required Reading:**
- [ ] Project Architecture Overview
- [ ] Core System Documentation
- [ ] Getting Started Guide
- [ ] API Documentation
- [ ] Security Best Practices
- [ ] Code Style Guide
- [ ] Git Workflow and Branching Strategy
- [ ] CI/CD Pipeline Documentation
- [ ] Testing Strategy and Guidelines
- [ ] Release Process Documentation

**Documentation Locations:**
- Project documentation (Confluence, Wiki, etc.)
- Technical documentation
- Development practices and standards

**Expected Outcome:**
- Understand project architecture
- Know where to find information
- Familiar with development practices

**Questions to Answer:**
1. What are the main components of the system?
2. How do core workflows function?
3. What is our branching strategy?
4. How do we handle releases?</parameter>
  <parameter name="assignee">john.doe@company.com</parameter>
  <parameter name="additional_fields">{"parent": "ONBOARD-123", "priority": {"name": "Medium"}}</parameter>
</invoke>
```

**Sub-task 4: Codebase Familiarization**

```xml
<invoke name="c_l3Q10mcp0jira_create_issue">
  <parameter name="project_key">ONBOARD</parameter>
  <parameter name="summary">Codebase Familiarization</parameter>
  <parameter name="issue_type">Sub-task</parameter>
  <parameter name="description">**Goal:** Gain familiarity with codebase structure and key components

**Activities:**
- [ ] Explore repository structure
- [ ] Review main packages/modules
- [ ] Identify key classes and interfaces
- [ ] Understand dependency management
- [ ] Review recent pull/merge requests
- [ ] Study test suites and coverage
- [ ] Run and debug sample flows
- [ ] Generate architecture diagrams using Cline

**Key Areas to Explore:**
1. **Core Modules**
   - Main functionality
   - Key components
   - Critical paths

2. **API/Interface Layer**
   - Public interfaces
   - Error handling
   - Logging framework

3. **Testing Infrastructure**
   - Unit tests
   - Integration tests
   - End-to-end tests

**Buddy Activity:**
- Pair programming session with buddy
- Code walkthrough of critical paths
- Q&A session

**Deliverable:**
- Create personal notes document in Confluence
- List questions for discussion with buddy</parameter>
  <parameter name="assignee">john.doe@company.com</parameter>
  <parameter name="additional_fields">{"parent": "ONBOARD-123", "priority": {"name": "Medium"}}</parameter>
</invoke>
```

**Sub-task 5: Starter Tasks**

```xml
<invoke name="c_l3Q10mcp0jira_create_issue">
  <parameter name="project_key">ONBOARD</parameter>
  <parameter name="summary">Starter Tasks</parameter>
  <parameter name="issue_type">Sub-task</parameter>
  <parameter name="description">**Goal:** Complete beginner-friendly tasks to practice workflow

**Starter Tasks:**

1. **Documentation Update (1-2 story points)**
   - Fix outdated documentation
   - Add missing code comments
   - Update README files

2. **Small Bug Fix (2-3 story points)**
   - Fix minor UI issues
   - Improve error messages
   - Add input validation

3. **Test Coverage Improvement (2-3 story points)**
   - Add unit tests for uncovered code
   - Improve existing test assertions
   - Add edge case tests

4. **Code Refactoring (3-5 story points)**
   - Simplify complex methods
   - Remove code duplication
   - Improve naming conventions

**Process to Follow:**
1. Pick a starter task from backlog (tagged with 'good-first-issue')
2. Create feature branch: `feature/ONBOARD-XXX-description`
3. Make changes and write tests
4. Create merge request following guidelines
5. Address review comments
6. Merge to main branch

**Learning Goals:**
- Practice Git workflow
- Understand code review process
- Learn CI/CD pipeline
- Get comfortable with testing

**Buddy Support:**
- Review first merge request
- Provide feedback and guidance
- Answer questions</parameter>
  <parameter name="assignee">john.doe@company.com</parameter>
  <parameter name="additional_fields">{"parent": "ONBOARD-123", "priority": {"name": "Medium"}}</parameter>
</invoke>
```

**Sub-task 6: Team Introductions**

```xml
<invoke name="c_l3Q10mcp0jira_create_issue">
  <parameter name="project_key">ONBOARD</parameter>
  <parameter name="summary">Team Introductions</parameter>
  <parameter name="issue_type">Sub-task</parameter>
  <parameter name="description">**Goal:** Meet the team and understand roles and responsibilities

**Meetings to Schedule:**
- [ ] 1:1 with Manager
- [ ] 1:1 with Buddy/Mentor
- [ ] Team standup attendance
- [ ] Team retrospective attendance
- [ ] Sprint planning attendance
- [ ] Coffee chats with team members
- [ ] Cross-team introductions (if applicable)

**People to Meet:**

**Mobile Team:**
- Product Manager: [name]
- Tech Lead: [name]
- Senior Engineers: [names]
- QA Lead: [name]

**Related Teams:**
- Backend/API Team
- Security Team
- DevOps Team

**Key Contacts:**
- **Manager:** [manager name] - Career guidance, performance
- **Buddy:** [buddy name] - Day-to-day questions, code reviews
- **Tech Lead:** [tech lead] - Technical decisions, architecture
- **Product Manager:** [PM name] - Requirements, priorities

**Expected Outcome:**
- Know who to ask for what
- Understand team dynamics
- Feel comfortable reaching out</parameter>
  <parameter name="assignee">john.doe@company.com</parameter>
  <parameter name="additional_fields">{"parent": "ONBOARD-123", "priority": {"name": "Medium"}}</parameter>
</invoke>
```

**Sub-task 7: Tools and Workflows Training**

```xml
<invoke name="c_l3Q10mcp0jira_create_issue">
  <parameter name="project_key">ONBOARD</parameter>
  <parameter name="summary">Tools and Workflows Training</parameter>
  <parameter name="issue_type">Sub-task</parameter>
  <parameter name="description">**Goal:** Master team tools and workflows

**Tools Training:**

1. **Jira**
   - [ ] Create and update tickets
   - [ ] Use sprint boards
   - [ ] Track time and log work
   - [ ] Understand ticket lifecycle
   - [ ] Use filters and dashboards

2. **GitLab/Git**
   - [ ] Branching strategy
   - [ ] Merge request process
   - [ ] Code review guidelines
   - [ ] Resolve merge conflicts
   - [ ] Use GitLab CI/CD

3. **Confluence**
   - [ ] Find documentation
   - [ ] Create and edit pages
   - [ ] Use templates
   - [ ] Add comments and mentions

4. **Slack**
   - [ ] Channel organization
   - [ ] Notification settings
   - [ ] Important channels to join
   - [ ] Use threads effectively
   - [ ] Integrate with Jira/GitLab

5. **CI/CD Pipeline**
   - [ ] Understand pipeline stages
   - [ ] View build logs
   - [ ] Interpret test results
   - [ ] Trigger manual jobs

6. **Development Tools**
   - [ ] Setup IDE extensions and plugins
   - [ ] Configure development workflows
   - [ ] Learn automation tools (Cline, etc.)
   - [ ] Explore productivity tools
   - [ ] Understand team tooling

**Workflow Training:**
- Daily standup format
- Sprint planning process
- Code review expectations
- Testing requirements
- Release procedures
- Incident response

**Resources:**
- Team Handbook (Confluence)
- Workflow videos (if available)
- Buddy for hands-on training</parameter>
  <parameter name="assignee">john.doe@company.com</parameter>
  <parameter name="additional_fields">{"parent": "ONBOARD-123", "priority": {"name": "Low"}}</parameter>
</invoke>
```

**Sub-task 8: First Code Contribution**

```xml
<invoke name="c_l3Q10mcp0jira_create_issue">
  <parameter name="project_key">ONBOARD</parameter>
  <parameter name="summary">First Code Contribution</parameter>
  <parameter name="issue_type">Sub-task</parameter>
  <parameter name="description">**Goal:** Complete first meaningful code contribution to production

**Objective:**
Pick a real user story or task from current sprint and implement it end-to-end

**Requirements:**
- Moderate complexity (3-5 story points or equivalent)
- Includes: implementation, tests, documentation
- Reviewed by buddy and team members as per team standards
- Merged and deployed following team process

**Process:**
1. **Planning**
   - Understand requirements
   - Review acceptance criteria
   - Design approach with buddy
   - Break down into tasks

2. **Implementation**
   - Write clean, maintainable code
   - Follow code style guide
   - Add comprehensive tests
   - Update documentation

3. **Code Review**
   - Create detailed merge request
   - Address review feedback
   - Learn from suggestions

4. **Deployment**
   - Verify in staging environment
   - Monitor production deployment
   - Celebrate first contribution! 🎉

**Success Criteria:**
- Feature works as expected
- Tests pass in CI/CD
- Code reviewed and approved
- Documentation updated
- Successfully deployed to production

**Reflection:**
After completion, write a brief reflection:
- What went well?
- What was challenging?
- What did you learn?
- What would you do differently?</parameter>
  <parameter name="assignee">john.doe@company.com</parameter>
  <parameter name="additional_fields">{"parent": "ONBOARD-123", "priority": {"name": "Medium"}}</parameter>
</invoke>
```

### Step 4: Setup Slack Introductions

**Preparing Welcome Messages:**

```xml
<invoke name="c_l3Q10mcp0confluence_create_page">
  <parameter name="space_key">ONBOARD</parameter>
  <parameter name="title">John Doe - Onboarding Guide</parameter>
  <parameter name="content"># Welcome to the Team, John! 👋

We're excited to have you join the team as a **[ROLE]**!

This page is your central hub for onboarding information and will be updated as you progress.

---

## 📋 Quick Info

| | |
|---|---|
| **Start Date** | [START_DATE] |
| **Role** | [ROLE] |
| **Team** | [TEAM_NAME] |
| **Manager** | [Manager Name] |
| **Buddy** | [Buddy Name] |

---

## 👥 Your Team

### Your Team
- **Tech Lead:** [Name] - Technical decisions, architecture
- **Product Manager/Owner:** [Name] - Requirements, priorities
- **Team Members:** [Names] - Code reviews, mentorship
- **QA Lead:** [Name] - Testing strategy, quality

### Key Contacts
- **IT Support:** [contact info]
- **HR:** [contact info]
- **Security:** [contact info]

---

## 🎯 Your First 30-60-90 Days

### Week 1-2: Setup & Learn
- ✅ Complete development environment setup
- ✅ Obtain all necessary access
- ✅ Read core documentation
- ✅ Meet the team
- ✅ Attend first sprint ceremonies

### Week 3-4: Explore & Practice
- 🔄 Deep dive into codebase
- 🔄 Shadow buddy on tasks
- 🔄 Complete starter tasks
- 🔄 First code reviews
- 🔄 Learn team workflows

### Week 5-8: Contribute
- ⏳ Pick up sprint stories
- ⏳ First production contribution
- ⏳ Participate actively in ceremonies
- ⏳ Start mentoring newcomers (if applicable)

### Month 3: Own & Lead
- ⏳ Own feature development
- ⏳ Lead technical discussions
- ⏳ Contribute to architecture decisions
- ⏳ Help improve team processes

---

## 📚 Essential Documentation

### Must Read (Week 1)
1. [Project Architecture Overview](link)
2. [Authentication System Docs](link)
3. [Development Setup Guide](link)
4. [Code Style Guide](link)
5. [Git Workflow](link)

### Important (Week 2-3)
1. [API Documentation](link)
2. [Testing Strategy](link)
3. [Security Best Practices](link)
4. [Release Process](link)
5. [Team Handbook](link)

### Reference (As Needed)
1. [Troubleshooting Guide](link)
2. [Deployment Runbook](link)
3. [Monitoring Dashboards](link)
4. [Incident Response](link)

---

## 🔗 Important Links

### Development
- **Repositories:** [Link to repositories]
- **CI/CD:** [Pipeline Dashboards]
- **Development Environment:** [Link]
- **Staging Environment:** [Link]

### Project Management
- **Project Board:** [Link to board]
- **Sprint Planning:** [Planning docs]
- **Roadmap:** [Product roadmap]

### Communication
- **Team Channels:**
  - [Team channel] - Main team channel
  - [Engineering channel] - All engineering
  - [General channel] - Company-wide
  - [Social channel] - Social/casual
- **Team Calendar:** [Link to calendar]

### Tools
- **Project Management:** [Tool and link]
- **Documentation:** [Tool and link]
- **Version Control:** [Tool and link]
- **VPN:** [Tool and link] (if applicable)

---

## ❓ Common Questions

### Development

**Q: How do I set up my development environment?**
A: Follow the [Development Setup Guide](link). If you encounter issues, ask your buddy or post in #mobile.

**Q: What's our branching strategy?**
A: We use feature branches: `feature/TICKET-ID-description`. See [Git Workflow](link).

**Q: How do I run tests locally?**
A: See [Testing Guide](link) for project-specific test commands.

### Workflow

**Q: How do I pick up a ticket?**
A: Look for tickets in "Ready for Dev" column, assign to yourself, move to "In Progress", and create a branch.

**Q: What should my merge request include?**
A: Code changes, tests, documentation updates, and a clear description. See [MR Guidelines](link).

**Q: How long does code review typically take?**
A: Usually 1-2 business days. Tag your buddy for urgent reviews.

### Team

**Q: When are standups?**
A: [Time] in [channel/location]. Check team calendar for details.

**Q: When is sprint planning?**
A: Every two weeks on Monday at 2:00 PM. Calendar invite should be sent.

**Q: Who should I ask about [topic]?**
A: See "Your Team" section above or ask in the team channel.

---

## 📝 Your Notes

**Learning Log:**
(Add your notes, questions, and learnings here)

- **Week 1:**
  - 

- **Week 2:**
  - 

- **Week 3:**
  - 

- **Questions to Ask:**
  - 

---

## 🎉 Milestones

- [ ] **Day 1:** Access to all systems ✓
- [ ] **Week 1:** Environment setup complete
- [ ] **Week 2:** First documentation read through
- [ ] **Week 3:** First starter task completed
- [ ] **Week 4:** First sprint story picked up
- [ ] **Month 1:** First production contribution
- [ ] **Month 2:** Comfortable with full workflow
- [ ] **Month 3:** Leading feature development

---

## 💬 Feedback

Your feedback helps us improve onboarding!

**What's working well?**
- 

**What could be better?**
- 

**What's missing?**
- 

---

*Last Updated: [DATE]*
*Created by: Cline Onboarding Workflow*

Need help? Ask your buddy [Buddy Name] or post in the team channel! 🚀</parameter>
  <parameter name="content_format">markdown</parameter>
</invoke>
```

**Team Introduction Message:**

```markdown
👋 **Welcome to the team, [NEWCOMER]!**

We're excited to have [NEWCOMER] joining us as a **[ROLE]**!

**About [NEWCOMER]:**
- 🎯 Role: [ROLE]
- 📅 Start Date: [START_DATE]
- 👤 Buddy: [Buddy Name]
- 📊 Manager: [Manager Name]

**Focus Areas:**
- [Area 1]
- [Area 2]
- [Area 3]

**Onboarding Resources:**
- Documentation Page: [[NEWCOMER] - Onboarding Guide](link)
- Starter Tickets: [ONBOARD-XXX](link) (if created)

Everyone, please help [NEWCOMER] feel welcome! Say hi, schedule coffee chats, and be available for questions. 

[NEWCOMER], don't hesitate to ask questions—we're all here to help! 🚀

Looking forward to working with you! 🎉
```

**Direct Message Template (for Buddy):**

```markdown
Hi [Buddy Name]! 👋

You've been assigned as [NEWCOMER]'s onboarding buddy. Here's what that involves:

**Your Role:**
- Be the main point of contact for day-to-day questions
- Help with codebase navigation
- Review first merge requests
- Schedule regular check-ins (daily first week, then weekly)
- Introduce John to the team

**Resources:**
- [NEWCOMER]'s Onboarding Page: [link]
- Starter Tickets: [ONBOARD-XXX](link) (if created)
- Buddy Guide: [Documentation link]

**First Steps:**
1. Schedule intro meeting this week
2. Help with development setup
3. Review onboarding checklist together
4. Set up recurring check-ins

**Check-in Schedule:**
- Week 1: Daily (15 min)
- Week 2-4: 3x per week
- Month 2-3: Weekly

Thanks for being an awesome buddy! 🙌

If you have questions about the buddy role, check the [Buddy Program Guide](link) or ask [Manager].
```

### Step 5: Setup Initial Meetings and Checkpoints

**Meeting Schedule:**

1. **First Week Check-ins:**
   - Day 1: Welcome meeting with manager
   - Day 2: Buddy introduction and setup session
   - Days 3-5: Daily 15-min standup with buddy

2. **Ongoing Checkpoints:**
   - Week 2-4: 3x per week with buddy
   - Month 2-3: Weekly 1:1s
   - End of Week 2: First progress check
   - End of Week 4: Month-1 retrospective
   - End of Month 3: Onboarding completion review

### Step 6: Assign Buddy/Mentor

**Buddy Assignment Process:**

1. **Identify Suitable Buddy:**
   - Same or related team
   - Available bandwidth
   - Strong communication skills
   - Good codebase knowledge

2. **Assign in Jira:**
   - Add buddy as watcher on all sub-tasks
   - Tag in comments for guidance needed
   - Assign as reviewer on first MRs

3. **Setup Check-ins:**
   - Schedule recurring 1:1s
   - First week: Daily
   - Ongoing: Weekly

4. **Buddy Responsibilities:**
   - Answer questions
   - Code review first contributions
   - Codebase walkthrough
   - Introduce to team members
   - Monitor progress

## Usage Examples

### Example 1: Complete Onboarding Setup

```
User: onboard new developer John Doe

Cline: I'll help you set up onboarding for John Doe. Let me gather some information.
      
      What is John's role/position?

User: Senior Mobile Developer

Cline: What is John's start date? (Press Enter for today)

User: 2025-03-01

Cline: Which team will John be joining?

User: Mobile Team

Cline: Who should be John's buddy/mentor?

User: jane.smith@company.com

Cline: Who is John's manager?

User: manager@company.com

Cline: Any special requirements or focus areas?

User: [Specific focus areas for this role]

Cline: Creating onboarding checklist for John Doe...
      
      ✅ Step 1: Creating Confluence Onboarding Page...
      Page created: "John Doe - Onboarding Guide"
      URL: https://confluence.company.com/display/ONBOARD/John+Doe
      
      ✅ Step 2: Generating Starter Jira Tickets...
      Optional starter tickets created:
      - ONBOARD-457: Development Environment Setup
      - ONBOARD-458: Access and Permissions
      - ONBOARD-459: Documentation Review
      
      ✅ Step 3: Preparing Team Introduction Messages...
      Team intro message ready (copy to team channel):
      [Message preview]
      
      Buddy message ready (send to Jane Smith):
      [Message preview]
      
      ✅ Step 5: Buddy Assignment...
      Buddy assigned: Jane Smith (jane.smith@company.com)
      - Added as watcher on all sub-tasks
      - Tagged for first MR reviews
      
      📋 Onboarding Checklist Complete!
      
      **Next Steps:**
      1. Share Confluence onboarding page with John
      2. Send introduction to team channel
      3. Message buddy with responsibilities
      4. Schedule first week check-ins
      5. Monitor progress on Confluence page
      
      **Resources:**
      - Onboarding Page: [Link to Confluence page]
      - Starter Tickets: [Link to Jira tickets]
      
      Good luck with John's onboarding! 🚀
```

### Example 2: Quick Onboarding (Minimal Info)

```
User: onboard Sarah Johnson

Cline: I'll create an onboarding checklist for Sarah Johnson.
      
      What is Sarah's role?

User: Backend Engineer

Cline: Using default values for other fields. Creating onboarding checklist...
      
      ✅ Confluence page: "Sarah Johnson - Onboarding Guide"
      ✅ Starter tickets created (optional)
      ✅ Slack messages prepared
      
      **Note:** You can update the following later:
      - Start date (currently set to today)
      - Team assignment
      - Buddy/mentor
      
      Would you like to assign a buddy now?

User: yes, assign alex.chen@company.com

Cline: ✅ Buddy assigned: Alex Chen
      
      Onboarding setup complete! 🎉
```

### Example 3: Onboarding with Special Requirements

```
User: onboard new developer Mike Roberts

Cline: What is Mike's role?

User: Senior Security Engineer

Cline: Start date?

User: 2025-03-15

Cline: Team?

User: Security Team

Cline: Buddy/mentor?

User: security.lead@company.com

Cline: Any special requirements?

User: Security clearance needed, focus on authentication, needs access to security tools

Cline: Creating specialized onboarding checklist...
      
      ✅ Confluence page created with security focus
      
      Note: I've added special sections for:
      - Security clearance process tracking
      - Security tools access checklist
      - Authentication deep-dive resources
      - Security-specific documentation links
      
      ✅ Buddy assigned: Security Lead
      
      Optional starter tickets created:
      - ONBOARD-471: Security Clearance Processing
      - ONBOARD-472: Security Tools Training
      - ONBOARD-473: Authentication System Deep Dive
      
      All set! The security-specific requirements have been included. 🔒
```

## Customization Options

### Custom Sub-tasks

**Add project-specific sub-tasks:**

```javascript
// For frontend/mobile development
- Device/browser setup
- Testing tools access
- Platform-specific configurations
- Mobile/frontend-specific tools

// For backend development
- Database access
- Cloud/infrastructure credentials
- Service architecture overview
- API/microservices setup

// For QA/testing roles
- Test automation framework
- Bug tracking workflow
- Test case management
- Testing environments access

// For DevOps roles
- Infrastructure access
- Deployment tools
- Monitoring and logging tools
- Cloud platform credentials
```

### Confluence Page Templates

**Customize page template per role:**

```markdown
# For Senior Engineers
- Add mentorship responsibilities
- Include architecture decision-making
- Add leadership expectations

# For Junior Engineers
- More detailed setup instructions
- Extended timeline (90-120 days)
- Additional learning resources
- Pair programming schedule

# For Contractors
- Shorter timeline
- Focus on immediate project needs
- Limited access scope
- End date and handoff plan
```

### Slack Message Variations

**Customize based on team size/culture:**

```markdown
# For large teams
- Include team structure
- Highlight key contacts
- Link to team directory

# For small teams
- More personal introduction
- Schedule group lunch
- Casual coffee chats

# For remote teams
- Virtual coffee schedule
- Communication guidelines
- Timezone considerations
```

## Advanced Features

### 1. Onboarding Progress Tracking

**Add progress dashboard:**

```javascript
// Track completion percentage
- Environment Setup: 100%
- Access & Permissions: 75%
- Documentation Review: 50%
- First Contribution: 0%

Overall Progress: 56%
```

### 2. Automated Reminders

**Setup reminder system:**

```javascript
// Day 3: Check if environment setup complete
// Day 7: Verify all access obtained
// Day 14: First starter task should be in progress
// Day 30: First production contribution check
// Day 60: Schedule performance check-in
```

### 3. Feedback Collection

**Gather onboarding feedback:**

```markdown
## Week 1 Feedback
- What worked well?
- What was confusing?
- What's missing?

## Month 1 Retrospective
- Onboarding experience rating
- Suggested improvements
- Resources usefulness
```

### 4. Team Integration Events

**Schedule key events:**

```markdown
- Day 1: Team lunch
- Week 1: Coffee chats with each team member
- Week 2: Pair programming session
- Week 4: Sprint retrospective participation
- Month 1: Team outing
```

## Integration with Other Workflows

### With Git Workflows

```
User: onboard new developer
      [Onboarding created]

User: create branch for ONBOARD-457
      [Branch created: feature/ONBOARD-457-dev-setup]
```

### With Jira Workflows

```
User: search jira tickets label:onboarding
      [Shows all onboarding-related tickets]

User: check sprint status
      [Includes onboarding tasks in sprint view]
```

### With Confluence Workflows

```
User: confluence search "onboarding"
      [Finds all onboarding pages including new one]
```

## Troubleshooting

### Issue 1: MCP Server Not Available

**Error:** MCP server not found

**Solution:**
1. Verify Atlassian MCP server is configured
2. Check environment variables
3. Restart VS Code to reload MCP servers

### Issue 2: Cannot Create Jira Tickets

**Error:** Invalid issue type

**Solution:**
1. Verify your Jira project supports the issue type (Task, Sub-task, etc.)
2. Check project configuration
3. Ensure proper permissions to create issues

### Issue 3: Confluence Page Creation Failed

**Error:** 401 Unauthorized

**Solution:**
1. Verify Confluence API token is valid
2. Check space permissions
3. Ensure space key exists

### Issue 4: Buddy Not Found

**Error:** User cannot be assigned

**Solution:**
1. Verify buddy email/username
2. Check Jira project access
3. Use account ID if needed

### Issue 5: Slack Webhook Failed

**Error:** Slack message not sent

**Solution:**
1. Verify webhook URL is correct
2. Check webhook permissions
3. Manually send prepared message

## Best Practices

### For Onboarding Coordinators

1. **Start Early** - Create checklist 1 week before start date
2. **Customize** - Tailor sub-tasks to role and experience
3. **Assign Buddy** - Choose engaged, available team member
4. **Monitor Progress** - Check Confluence page and Jira tickets regularly
5. **Collect Feedback** - Improve process continuously
6. **Follow Up** - Schedule check-ins at key milestones

### For Buddies

1. **Be Available** - Respond to questions promptly
2. **Be Proactive** - Don't wait for newcomer to ask
3. **Be Patient** - Everyone learns at different pace
4. **Be Thorough** - Review code carefully, explain why
5. **Be Encouraging** - Celebrate small wins
6. **Be Honest** - Provide constructive feedback

### For Managers

1. **Set Expectations** - Clear goals for first 90 days
2. **Provide Resources** - Ensure access to everything needed
3. **Regular Check-ins** - Weekly 1:1s at minimum
4. **Remove Blockers** - Help overcome obstacles
5. **Gather Feedback** - Learn from each onboarding
6. **Celebrate Milestones** - Recognize progress

## Configuration

### Onboarding Configuration File

**Location:** `/Users/[USER]/Documents/Cline/Settings/cline_workflow_config.json`

```json
{
  "onboardingConfig": {
    "projectTrackingTool": "ONBOARD",
    "documentationSpace": "ONBOARD",
    "teamChannel": "#team-introductions",
    "defaultBuddyDuration": "90 days",
    "checkInSchedule": {
      "week1": "daily",
      "week2-4": "3x per week",
      "month2-3": "weekly"
    },
    "starterTaskLabels": ["good-first-issue", "onboarding", "starter"],
    "requiredDocumentation": [
      "Architecture Overview",
      "Development Setup",
      "Code Style Guide",
      "Git Workflow",
      "Testing Strategy"
    ],
    "milestones": [
      {
        "day": 1,
        "title": "First day complete",
        "tasks": ["access", "accounts", "introductions"]
      },
      {
        "day": 7,
        "title": "Environment setup",
        "tasks": ["dev-setup", "build-success", "documentation-review"]
      },
      {
        "day": 30,
        "title": "First contribution",
        "tasks": ["starter-tasks", "first-mr", "production-deploy"]
      },
      {
        "day": 90,
        "title": "Fully onboarded",
        "tasks": ["feature-ownership", "team-participation", "mentor-others"]
      }
    ]
  }
}
```

### Jira Ticket Template Configuration

```json
{
  "ticketTemplates": [
    {
      "name": "Development Environment Setup",
      "issueType": "Task",
      "priority": "High",
      "estimatedDays": 2,
      "labels": ["onboarding", "setup"]
    },
    {
      "name": "Access and Permissions",
      "issueType": "Task",
      "priority": "High",
      "estimatedDays": 3,
      "labels": ["onboarding", "access"]
    },
    {
      "name": "Documentation Review",
      "issueType": "Task",
      "priority": "Medium",
      "estimatedDays": 5,
      "labels": ["onboarding", "documentation"]
    }
  ]
}
```

## Metrics and Reporting

### Onboarding Success Metrics

```markdown
**Time to First Commit:** 7 days (target: < 10 days)
**Time to First Production Deploy:** 21 days (target: < 30 days)
**Documentation Completion:** 85% (target: > 80%)
**Buddy Satisfaction:** 4.5/5 (target: > 4.0/5)
**Newcomer Satisfaction:** 4.8/5 (target: > 4.5/5)
```

### Progress Tracking

```markdown
**Active Onboardings:**
- John Doe (Day 15, 65% complete)
- Sarah Johnson (Day 8, 45% complete)
- Mike Roberts (Day 2, 20% complete)

**Completed This Quarter:** 8
**Average Time to Productivity:** 28 days
**Buddy Completion Rate:** 95%
```

## Related Workflows

- `jira-ticket-creation` - Create individual onboarding tasks
- `confluence-search` - Find onboarding documentation
- `git-branch` - Create branches for onboarding tasks
- `check-sprint-status` - Track onboarding progress in sprint

## Quick Reference

### Trigger Command
```
onboard new developer [NAME]
```

### Required Information
- Newcomer's name (required)
- Role/position (required)
- Start date (optional, default: today)
- Team (optional)
- Buddy/mentor (optional)
- Manager (optional)

### Generated Artifacts
1. Confluence onboarding page (primary tracking hub)
2. Structured checklist for all onboarding activities
3. Starter Jira tickets (optional, for specific tasks)
4. Slack introduction messages
5. Initial meeting schedule

### Key Milestones
- Day 1: Access to all systems
- Week 1: Environment setup complete
- Week 2: Documentation reviewed
- Week 3: First starter task
- Month 1: First production contribution
- Month 3: Fully onboarded

---

**Last Updated:** 2025-03-12
**Version:** 1.0
**Maintainer:** Development Team
**Feedback:** Please share onboarding feedback to improve this workflow!
