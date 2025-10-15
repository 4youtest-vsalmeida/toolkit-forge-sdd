<!-- toolkit: forge-sdd-toolkit -->
---
description: Common user story patterns for Atlassian Forge applications
applyTo: "sdd-docs/**/*.md"
---

# User Story Patterns for Forge Apps

## Story Structure (Mandatory Format)

Every user story MUST follow this exact structure:

```markdown
**As a** [specific user role]
**I want** [specific capability]
**So that** [business value/outcome]

**Acceptance Criteria**:
- [ ] [Specific, testable criterion]
- [ ] [Specific, testable criterion]
- [ ] [Edge case handling]

**Priority**: P0 | P1 | P2
```

### Role Specificity

Be specific about WHO the user is:

| ❌ Too Vague | ✅ Better | ⭐ Best |
|-------------|----------|--------|
| "As a user" | "As a developer" | "As a developer working on multiple projects" |
| "As an admin" | "As a Jira admin" | "As a Jira admin managing 50+ projects" |
| "As someone" | "As a team lead" | "As a team lead tracking sprint progress" |

### Capability Clarity

Be specific about WHAT they want to do:

| ❌ Too Vague | ✅ Better | ⭐ Best |
|-------------|----------|--------|
| "See information" | "See deployment status" | "See which deployments include my code changes" |
| "Track progress" | "Track sprint velocity" | "Track sprint velocity across multiple teams" |
| "Get notified" | "Get notified of failures" | "Get notified when my PR review is ready" |

### Value Articulation

Be specific about WHY (business value):

| ❌ Too Vague | ✅ Better | ⭐ Best |
|-------------|----------|--------|
| "To work better" | "To avoid context switching" | "To avoid switching tools 20+ times per day, saving 30 minutes" |
| "To save time" | "To reduce manual work" | "To eliminate 2 hours/week of manual status updates" |
| "To improve quality" | "To catch bugs earlier" | "To catch bugs in code review instead of production, reducing incidents by 40%" |

## Common Forge App Patterns

### Pattern 1: Contextual Information Display

**When to use**: User needs to see external data within Jira/Confluence context

**Template**:
```markdown
**As a** [user role]
**I want** to see [external data source] in [Jira/Confluence context]
**So that** I don't have to switch between [current tool] and [external tool], saving [time/effort]
```

**Example**:
```markdown
**As a** developer reviewing code
**I want** to see CI/CD build status directly in the Jira issue
**So that** I don't have to switch to Jenkins 15 times per day, saving 20 minutes of context switching

**Acceptance Criteria**:
- [ ] Build status appears in issue panel (no navigation required)
- [ ] Shows: build number, status (success/fail), timestamp, branch
- [ ] Updates automatically when new build completes
- [ ] Failed builds show error summary (not full logs)
- [ ] Link to full build details in CI/CD system

**Edge Cases**:
- [ ] EC-001: If CI/CD system is unreachable, show cached status with "Last updated: X min ago"
- [ ] EC-002: If no builds exist for issue, show "No builds found for this issue"
- [ ] EC-003: If user lacks CI/CD permissions, show "Contact admin for CI/CD access"

**Priority**: P0
```

**Common Edge Cases for this pattern**:
1. External system unavailable → Show cached data
2. No data exists → Clear "no data" message
3. User lacks permissions → Permission error
4. Data is too large → Pagination or summary view
5. Data is stale → Show timestamp + refresh option

---

### Pattern 2: Workflow Automation

**When to use**: User wants to eliminate manual, repetitive tasks

**Template**:
```markdown
**As a** [user role]
**I want** [trigger event] to automatically [automated action]
**So that** I don't have to manually [current process], saving [time] and reducing [errors]
```

**Example**:
```markdown
**As a** team lead managing releases
**I want** issue status to automatically update when code is deployed to production
**So that** I don't have to manually update 20+ issues per release, saving 1 hour/week
and ensuring status is always accurate

**Acceptance Criteria**:
- [ ] When deployment to production completes, linked issues transition to "Deployed"
- [ ] Transition respects Jira workflow rules (only if valid transition exists)
- [ ] Comment added to issue: "Deployed to production on [date] at [time]"
- [ ] Notification sent to issue watchers
- [ ] Works for deployments containing multiple commits/issues

**Edge Cases**:
- [ ] EC-010: If issue already in "Deployed" status, update comment but don't transition
- [ ] EC-011: If workflow doesn't allow transition, add comment explaining why
- [ ] EC-012: If deployment partially fails, don't update status (wait for successful redeploy)
- [ ] EC-013: If multiple deployments in quick succession, only process latest

**Priority**: P1
```

**Common Edge Cases for this pattern**:
1. Automation fails midway → Retry logic, notification
2. Trigger fires multiple times → Idempotency
3. Invalid workflow transition → Graceful skip + notification
4. External dependency down → Queue for retry
5. Concurrent automations → Prevent race conditions

---

### Pattern 3: Data Synchronization

**When to use**: User needs data consistency between two systems

**Template**:
```markdown
**As a** [user role]
**I want** [data from system A] synced to [system B]
**So that** [team members] can access [unified data] without [current pain], improving [outcome]
```

**Example**:
```markdown
**As a** product manager planning releases
**I want** Jira issue estimates synced to our capacity planning spreadsheet
**So that** stakeholders can see accurate capacity data without me exporting manually
every Monday, saving 2 hours/week and preventing stale data errors

**Acceptance Criteria**:
- [ ] When issue estimate is updated in Jira, spreadsheet updates within 5 minutes
- [ ] Sync includes: issue key, summary, estimate, assignee, sprint
- [ ] Only syncs issues in active sprints (not entire backlog)
- [ ] Updates existing rows if issue already in spreadsheet
- [ ] Adds new rows for newly estimated issues

**Edge Cases**:
- [ ] EC-020: If spreadsheet is unavailable, queue updates and retry (max 3 attempts)
- [ ] EC-021: If estimate is removed from issue, update spreadsheet to "Unestimated"
- [ ] EC-022: If issue moved out of sprint, mark as "Removed" in spreadsheet
- [ ] EC-023: If spreadsheet modified manually, don't overwrite manual changes (flag conflict)

**Priority**: P2
```

**Common Edge Cases for this pattern**:
1. Data conflicts → Last write wins OR conflict resolution UI
2. One system temporarily down → Queue for retry
3. Sync frequency causes rate limits → Batch updates
4. Bidirectional sync → Detect and handle circular updates
5. Large data volumes → Incremental sync, not full export

---

### Pattern 4: Custom Field / Data Enhancement

**When to use**: User needs to add custom data to Jira/Confluence entities

**Template**:
```markdown
**As a** [user role]
**I want** to capture [custom data] on [entity type]
**So that** [team] can track [metric/information] for [purpose]
```

**Example**:
```markdown
**As a** compliance officer
**I want** to tag Jira issues with security risk level (Low/Medium/High/Critical)
**So that** security team can prioritize remediation work and report compliance metrics

**Acceptance Criteria**:
- [ ] Custom field appears in issue create/edit screens
- [ ] Dropdown with 4 options: Low, Medium, High, Critical
- [ ] Default value: Low (if not specified)
- [ ] Field is searchable in JQL: "securityRisk = High"
- [ ] Field appears in issue export (CSV, Excel)

**Edge Cases**:
- [ ] EC-030: If issue created via API without risk level, default to "Low"
- [ ] EC-031: If user lacks permission to edit, field is read-only
- [ ] EC-032: If risk level changed, add audit comment: "Risk level changed from X to Y by [user]"

**Priority**: P0
```

**Common Edge Cases for this pattern**:
1. Field not set → Sensible default
2. Invalid value → Validation error
3. Required field missing → Block save
4. Bulk update → Performance considerations
5. Permission to edit → Respect Jira permissions

---

### Pattern 5: Reporting & Analytics

**When to use**: User needs insights from aggregated data

**Template**:
```markdown
**As a** [user role]
**I want** to see [metric/trend] across [scope]
**So that** I can [make decision/take action] to [improve outcome]
```

**Example**:
```markdown
**As a** engineering manager
**I want** to see average PR review time across all repositories
**So that** I can identify bottlenecks and improve team velocity by 20%

**Acceptance Criteria**:
- [ ] Dashboard shows: average time to first review, average time to merge
- [ ] Breakdown by repository and reviewer
- [ ] Trend over last 30/60/90 days (selectable)
- [ ] Identify outliers: PRs taking > 2 days for first review
- [ ] Export to CSV for leadership reports

**Edge Cases**:
- [ ] EC-040: If repository has < 5 PRs, show "Insufficient data"
- [ ] EC-041: If date range includes weekends/holidays, account for non-work days
- [ ] EC-042: If very large dataset (>1000 PRs), show aggregates only (not individual PRs)

**Priority**: P1
```

**Common Edge Cases for this pattern**:
1. Insufficient data → Clear message
2. Very large datasets → Pagination, aggregation
3. Outliers skew averages → Show median, highlight outliers
4. Date range considerations → Business days vs calendar days
5. Export limits → Batch export or streaming

---

## Acceptance Criteria Patterns

### Format: Given/When/Then

For complex scenarios, use Given/When/Then format:

```markdown
**Acceptance Criteria**:
- [ ] **Given** user is viewing issue AND deployment has completed
      **When** page refreshes (manual or auto)
      **Then** deployment appears in issue panel within 5 seconds

- [ ] **Given** external deployment system is down
      **When** user views issue
      **Then** cached deployment data shown with "Last updated: X min ago" banner
```

### Always Include

For every user story, include at least:

1. **Happy path** (successful scenario)
   ```
   - [ ] User can [perform action] and sees [expected result]
   ```

2. **Error path** (what if it fails?)
   ```
   - [ ] If [error condition], user sees [helpful error message]
   ```

3. **Edge case** (boundary conditions)
   ```
   - [ ] If [boundary condition], system handles gracefully with [behavior]
   ```

4. **Permission check** (unauthorized access)
   ```
   - [ ] If user lacks [permission], show [permission error] and [next steps]
   ```

### Example: Complete Acceptance Criteria

```markdown
**Acceptance Criteria**:

**Happy Path**:
- [ ] User clicks "Trigger Deployment" button
- [ ] Deployment starts within 10 seconds
- [ ] User sees progress: "Deploying to staging... 30% complete"
- [ ] On success: "Deployed to staging successfully. Build #123"

**Error Paths**:
- [ ] If deployment fails, show: "Deployment failed: [reason]. [Retry] [View Logs]"
- [ ] If external CI/CD unavailable, show: "Deployment service unavailable. Try again in 5 minutes."

**Edge Cases**:
- [ ] If deployment already in progress, disable button and show: "Deployment #122 in progress"
- [ ] If user triggers multiple times quickly, queue but don't duplicate
- [ ] If deployment takes > 25 seconds, continue in background, show status page

**Permissions**:
- [ ] If user lacks deploy permission, button is disabled with tooltip: "Contact admin for deployment access"
- [ ] If environment requires approval, show: "Deployment to prod requires [approver] approval"
```

## Independent Testability

Each user story should be **independently testable** - meaning:

1. **Can implement just this story** → Have a working feature
2. **Can test without other stories** → Standalone verification
3. **Delivers value on its own** → User gets benefit

### Example: Independent Story

```markdown
#### Story 1.1: View Deployment Status ✅ INDEPENDENT

**As a** developer
**I want** to see deployment status in the issue
**So that** I can verify my code is deployed

**Can implement standalone**: YES
- Just need to fetch and display deployment data
- Doesn't depend on Story 1.2 (triggering deployments)

**Can test standalone**: YES
- Create test issue
- Trigger test deployment externally
- Verify deployment appears in issue

**Delivers value standalone**: YES
- Even without triggering deployments from Jira,
  users get visibility into deployment status
```

### Example: Dependent Story (Avoid This)

```markdown
#### Story 1.2: Trigger Deployment ❌ DEPENDS ON 1.1

**As a** developer
**I want** to trigger deployment from the issue
**And see the deployment status update**  ← Depends on Story 1.1

**Problem**: Can't test Story 1.2 without Story 1.1 implemented

**Better approach**: Split into:
- Story 1.1: View deployment status (independent)
- Story 2.1: Trigger deployment (independent, but enhanced by 1.1)
```

## Priority Guidelines

### P0 (Must Have) - MVP Core
- Essential for app to provide basic value
- Users can't accomplish primary goal without it
- Blocking other stories

**Example**: "View deployment status" for a deployment tracking app

### P1 (Should Have) - Enhances MVP
- Important but not critical for v1
- Significantly improves user experience
- Addresses common use cases

**Example**: "Filter deployments by environment"

### P2 (Could Have) - Nice to Have
- Valuable but can be deferred to v2
- Addresses edge cases or advanced users
- Optimization or convenience features

**Example**: "Export deployment history to CSV"

### Priority Justification

Always explain priority:

```markdown
**Priority**: P0

**Why this priority**: This is the core value proposition of the app.
Without the ability to see deployment status in Jira, the app provides
no value. All other stories build on this foundation. Blocks: Story 2.1, 3.1
```

## Traceability

Every user story should trace to:

1. **Persona**: Which user type benefits?
2. **Pain Point**: What problem does it solve?
3. **Business Value**: What's the measurable impact?
4. **Requirements**: Which REQ-F-XXX does it generate?

### Example with Full Traceability

```markdown
#### Story 1.1: View Deployment Status

**As a** developer (Primary Persona)
**I want** to see deployment status in the issue
**So that** I verify my code is deployed without asking teammates (Pain Point)

**Business Value**:
- Saves 30 min/day per developer (15 developers = 7.5 hours/day team-wide)
- Reduces Slack interruptions by 80%
- Improves deployment confidence

**Acceptance Criteria**: [...]

**Priority**: P0

**Generated Requirements**:
- REQ-F-001: Display deployment list
- REQ-F-002: Show deployment details
- REQ-F-003: Auto-refresh data
- REQ-NFR-001: Response time < 2 seconds

**Traces from**:
- Persona: Developer (Primary)
- Pain Point: "Wasting time asking deployment status"
- User Research: 15/15 developers mentioned this in interviews
```

## Anti-Patterns to Avoid

### ❌ Technical User Stories

**Bad**:
```
As a developer, I want a REST API endpoint
So that I can fetch deployment data
```

**Why bad**: Describes implementation (REST API), not user value

**Good**:
```
As a developer, I want to see deployment status in the issue
So that I can verify my code is deployed without leaving Jira
```

### ❌ Too Broad

**Bad**:
```
As a user, I want a deployment tracking system
So that I can track deployments
```

**Why bad**: Not specific, not testable, covers entire app

**Good**:
```
As a developer, I want to see which environment my code is deployed to
So that I can verify the fix reached production
```

### ❌ Missing "So That"

**Bad**:
```
As a PM, I want to see sprint velocity
```

**Why bad**: No business value, doesn't explain WHY

**Good**:
```
As a PM, I want to see sprint velocity trends
So that I can set realistic release dates and improve team planning accuracy
```

### ❌ No Acceptance Criteria

**Bad**:
```
As a developer, I want deployment notifications
[No acceptance criteria]
```

**Why bad**: Not testable, unclear what "done" means

**Good**:
```
As a developer, I want deployment notifications
So that I know immediately when my code reaches production

Acceptance Criteria:
- [ ] Notification appears within 1 minute of deployment
- [ ] Includes: issue key, environment, timestamp
- [ ] User can dismiss or click to view details
```

## Summary Checklist

For every user story, verify:

- [ ] **Format**: Follows "As a... I want... So that..." structure
- [ ] **Specificity**: Role, capability, and value are specific
- [ ] **Acceptance Criteria**: At least 3 criteria (happy, error, edge)
- [ ] **Priority**: P0/P1/P2 with justification
- [ ] **Independence**: Can be implemented and tested standalone
- [ ] **Value**: Delivers measurable business value
- [ ] **Testability**: Clear definition of "done"
- [ ] **Traceability**: Links to persona, pain point, requirements
- [ ] **Edge Cases**: Covers errors, boundaries, permissions
- [ ] **No Implementation**: Describes WHAT not HOW
