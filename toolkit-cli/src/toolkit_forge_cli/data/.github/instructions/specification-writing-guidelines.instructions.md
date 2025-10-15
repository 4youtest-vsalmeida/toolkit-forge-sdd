<!-- toolkit: forge-sdd-toolkit -->
---
description: Guidelines for writing clear, testable, implementation-agnostic specifications
applyTo: "sdd-docs/specification-document.md"
---

# Specification Writing Guidelines

## Core Principles

### Principle 1: WHAT, not HOW
Specifications describe **what** the app should do and **why**, never **how** to build it.

### Principle 2: User-Focused Language
Write for users and business stakeholders, not developers.

### Principle 3: Technology-Agnostic
No mention of frameworks, databases, APIs, or implementation details.

### Principle 4: Testable & Measurable
Every requirement must be verifiable with specific acceptance criteria.

## Language Rules

### ✅ MUST Use

**User-focused language**:
- "User can view deployment status"
- "System displays error message when..."
- "Team members receive notification when..."

**Business value emphasis**:
- Always explain WHY: "So that developers don't waste time asking..."
- Focus on outcomes: "Reduces manual work by 10 hours/week"
- Connect to user goals: "Enables faster decision making"

**Measurable outcomes**:
- Numbers: "Complete task in under 2 minutes"
- Percentages: "95% of users succeed on first attempt"
- Frequencies: "Updates every 5 minutes"
- Quantities: "Support up to 1000 concurrent users"

### ❌ MUST AVOID

**Implementation details**:
- ❌ "Use REST API to fetch data" → ✅ "System retrieves data from external source"
- ❌ "Store in Forge Storage API" → ✅ "System persists user preferences"
- ❌ "Implement Custom UI with React" → ✅ "Provide interactive interface with real-time updates"
- ❌ "Use jira:issuePanel module" → ✅ "Display information in issue context"

**Technical jargon without explanation**:
- ❌ "OAuth2 authentication" → ✅ "Secure user authentication" (unless OAuth is requirement)
- ❌ "GraphQL endpoint" → ✅ "Data query interface"
- ❌ "Webhook integration" → ✅ "Automatic notification when events occur"

**Vague terms without metrics**:
- ❌ "Fast response time" → ✅ "Response within 2 seconds"
- ❌ "User-friendly interface" → ✅ "95% of users complete task on first attempt"
- ❌ "Reliable system" → ✅ "99.9% uptime, automatic recovery from failures"
- ❌ "Easy to use" → ✅ "Users can complete setup in under 5 minutes without documentation"

## Requirement Format

### Structure

Every functional requirement must include:
1. **Unique ID**: REQ-F-XXX (sequential)
2. **Clear statement**: What the system must do
3. **Rationale**: Why this is needed (business value)
4. **Traceability**: Which user story it supports

### Examples

#### ✅ Good Requirement

```markdown
**REQ-F-001**: System MUST display deployment status for each issue

- **Rationale**: Developers waste 2-3 hours per week asking "is my fix deployed?" in Slack.
  Providing self-service visibility reduces interruptions and improves team efficiency.
- **Traces to**: Story 1.1 (View deployment status)
- **Acceptance Criteria**:
  - [ ] User sees list of deployments related to issue
  - [ ] Each deployment shows: timestamp, environment, status
  - [ ] Data refreshes automatically every 5 minutes
  - [ ] Historical data available for last 90 days
```

**Why it's good**:
- Clear what system must do (display deployment status)
- Explains business value (saves 2-3 hours/week)
- Specific acceptance criteria (testable)
- No implementation details (doesn't say how to fetch/store data)

#### ❌ Bad Requirement

```markdown
**REQ-F-001**: Implement REST API endpoint to fetch deployment data from GitHub Actions

- **Rationale**: Need to get deploy info
- **Traces to**: Story 1.1
```

**Why it's bad**:
- Specifies HOW (REST API, GitHub Actions) not WHAT
- Vague rationale (doesn't explain business value)
- No acceptance criteria
- Technology-specific (GitHub Actions)

### Rewriting Bad to Good

**Bad**: "Implement database to store user settings"

**Good**:
```markdown
**REQ-F-005**: System MUST persist user preferences across sessions

- **Rationale**: Users need to configure which information they see.
  Remembering preferences saves time (users reported spending 5 min/day
  reconfiguring after each login).
- **Traces to**: Story 2.3 (Customize display preferences)
- **Acceptance Criteria**:
  - [ ] User selections are saved automatically
  - [ ] Preferences persist across browser sessions
  - [ ] User can reset to default settings
  - [ ] Changes take effect immediately without page reload
```

## Non-Functional Requirements

### Categories

1. **Performance**: Response time, throughput, scalability
2. **Security**: Authentication, authorization, data protection
3. **Usability**: Accessibility, learning curve, error recovery
4. **Reliability**: Uptime, error handling, data consistency

### Format

```markdown
**REQ-NFR-XXX**: [Category] requirement statement

- **Rationale**: Business justification
- **Measurement**: How to verify
- **Priority**: P0 / P1 / P2
```

### Examples

#### Performance

```markdown
**REQ-NFR-001**: User actions MUST complete within 2 seconds

- **Rationale**: Users abandon tasks if response time exceeds 3 seconds
  (industry standard for web applications)
- **Measurement**: 95th percentile response time measured in production
- **Priority**: P0
```

#### Security

```markdown
**REQ-NFR-003**: System MUST use minimum required permissions

- **Rationale**: Principle of least privilege - reduces security risk
  and user concerns about app access
- **Measurement**: Security review confirms no unnecessary scopes requested
- **Priority**: P0
```

#### Usability

```markdown
**REQ-NFR-005**: Interface MUST be accessible to users with disabilities

- **Rationale**: Compliance with WCAG 2.1 AA standards, inclusive design
- **Measurement**: Automated accessibility testing + manual screen reader testing
- **Priority**: P1
```

## Success Criteria Guidelines

Success criteria define **how to measure** if the app is successful.

### Rules

1. **Technology-agnostic**: Describe from user perspective
2. **Measurable**: Include specific numbers
3. **User-focused**: Describe outcomes, not system internals
4. **Verifiable**: Can be tested without implementation knowledge

### ✅ Good Examples

```markdown
**SC-001**: Users can complete checkout in under 3 minutes
- Measurable: Time to completion
- User-focused: User experience metric
- Verifiable: User testing or analytics

**SC-002**: 95% of searches return relevant results in under 1 second
- Measurable: Percentage and time
- User-focused: Search quality and speed
- Verifiable: Search analytics and user feedback

**SC-003**: Support tickets related to deployment questions decrease by 60%
- Measurable: Ticket reduction percentage
- User-focused: Business outcome
- Verifiable: Support ticket analytics
```

### ❌ Bad Examples (Too Technical)

```markdown
❌ **SC-001**: API response time is under 200ms
   Problem: Too technical, user doesn't care about API
   Better: "Users see search results in under 1 second"

❌ **SC-002**: Database can handle 1000 transactions per second
   Problem: Implementation detail
   Better: "System supports 1000 concurrent users without degradation"

❌ **SC-003**: React components render efficiently
   Problem: Framework-specific
   Better: "Interface responds to user actions within 500ms"

❌ **SC-004**: Redis cache hit rate above 80%
   Problem: Technology-specific
   Better: "Frequently accessed data loads instantly (< 200ms)"
```

### Rewriting Technical Criteria

| Bad (Technical) | Good (User-Focused) |
|----------------|---------------------|
| "API latency < 100ms" | "Users see results appear instantly" |
| "Database query optimized" | "Search results appear in under 1 second" |
| "Serverless function scales to 1000 invocations" | "Supports 1000 concurrent users" |
| "Cache TTL set to 5 minutes" | "Data refreshes every 5 minutes" |
| "Webhook delivery guaranteed" | "Notifications arrive within 30 seconds of event" |

## User Story Format

### Standard Structure

```markdown
**As a** [specific user role]
**I want** [specific capability]
**So that** [business value/outcome]

**Acceptance Criteria**:
- [ ] [Specific, testable criterion]
- [ ] [Specific, testable criterion]
- [ ] [Edge case or error scenario]

**Priority**: P0 | P1 | P2
```

### Role Specificity

**Too vague**: "As a user"
**Better**: "As a developer", "As a project manager", "As a team admin"
**Best**: "As a developer working on multiple projects simultaneously"

### Capability Clarity

**Too vague**: "I want to see information"
**Better**: "I want to see deployment status"
**Best**: "I want to see which deployments include my code changes"

### Value Articulation

**Too vague**: "So that I can work better"
**Better**: "So that I don't have to ask in Slack"
**Best**: "So that I can verify my fix is deployed without interrupting teammates, saving 30 minutes per day"

### Example User Story

```markdown
#### Story 1.1: View Deployment Status in Issue Context

**As a** developer working on bug fixes
**I want** to see deployment status directly in the Jira issue
**So that** I can verify my fix reached production without asking teammates in Slack,
saving 30 minutes per day in back-and-forth communication

**Acceptance Criteria**:
- [ ] Deployment list appears in issue view (no need to navigate elsewhere)
- [ ] Shows: commit SHA, timestamp, environment (dev/staging/prod), status
- [ ] Production deployments are visually highlighted
- [ ] Updates automatically when new deployment occurs (no manual refresh)
- [ ] Historical deployments visible for last 90 days
- [ ] Error message displayed if deployment data unavailable: "Unable to load deployment data. Last updated: [timestamp]"

**Priority**: P0

**Traces to**:
- REQ-F-001 (Display deployment status)
- REQ-F-002 (Show deployment details)
- REQ-NFR-001 (Auto-refresh data)
```

## Edge Cases Documentation

### Format

```markdown
### Edge Case: [Brief Description]

**EC-XXX**: [Unique ID for traceability]

**Scenario**: [What triggers this edge case]

**Expected Behavior**: [How system should handle it]

**Why It Matters**: [Business impact if not handled]
```

### Example

```markdown
### Edge Case: External API Unavailable

**EC-003**: External deployment service (GitHub Actions) is unreachable

**Scenario**:
- User views issue to check deployment status
- App attempts to fetch latest deployment data from GitHub Actions API
- GitHub Actions API returns error or times out after 5 seconds

**Expected Behavior**:
- Display cached deployment data (if available) with timestamp: "Last updated: 10 minutes ago"
- Show banner message: "Unable to fetch latest deployments. Showing cached data. [Retry]"
- Provide manual retry button
- Log error for administrator review
- Do NOT show technical error messages to user

**Why It Matters**:
- Users still need deployment visibility even during external outages
- Prevents frustration from blank screens or cryptic errors
- Maintains app usability during partial failures
```

## Assumptions Documentation

### Format

```markdown
[ASSUMPTION: Clear statement of assumption - basis for assumption]
```

### Examples

```markdown
[ASSUMPTION: Users have Jira issue keys in commit messages - standard practice for Jira-Git integration]

[ASSUMPTION: Deployment frequency is < 100 per day per project - based on typical CI/CD patterns]

[ASSUMPTION: Deploy data size < 5KB per deployment - includes commit SHA, timestamp, environment, status only]

[ASSUMPTION: Users prefer read-only view initially - can add deployment triggering in v2 if requested]
```

### When to Document Assumptions

**Always document assumptions about**:
- Data sources or integrations
- User behavior or workflows
- Performance characteristics
- Data volumes or frequencies
- Feature priorities or scope

**Validate assumptions by asking user when**:
- Assumption significantly impacts scope
- Multiple reasonable interpretations exist
- Assumption affects security or compliance
- Assumption determines technical complexity

## Checklist for Every Specification

Before considering specification complete:

### Content Quality
- [ ] No implementation details (no tech stack, frameworks, modules)
- [ ] All requirements explain WHY (business value)
- [ ] Written for non-technical stakeholders
- [ ] No [TODO] or placeholder text

### Requirements
- [ ] All requirements have unique IDs (REQ-F-XXX, REQ-NFR-XXX)
- [ ] All requirements are testable
- [ ] All requirements trace to user stories
- [ ] No vague terms without metrics

### Success Criteria
- [ ] All criteria are measurable (include numbers)
- [ ] All criteria are technology-agnostic
- [ ] All criteria are user-focused
- [ ] All criteria are verifiable

### User Stories
- [ ] Follow standard format (As a... I want... So that...)
- [ ] Have specific acceptance criteria
- [ ] Include edge cases
- [ ] Have defined priorities

### Edge Cases
- [ ] Platform-specific edge cases covered (timeout, storage, API failures)
- [ ] User error scenarios included
- [ ] Permission/authorization cases addressed
- [ ] Concurrent access considered

### Traceability
- [ ] Requirements trace to stories
- [ ] Stories trace to personas
- [ ] Out-of-scope explicitly listed
- [ ] Dependencies identified
- [ ] Assumptions documented

## Examples: Before and After

### Example 1: Deployment Tracking

#### Before (Implementation-Focused)
```markdown
Build a REST API to integrate with GitHub Actions webhooks,
store deploy events in Forge Storage using JSON format,
and display in Custom UI panel using React components.
```

#### After (Specification-Focused)
```markdown
## User Story
As a developer, I want to see deployment status for my issues
so that I can verify my code reached production without asking teammates.

## Requirements
REQ-F-001: System MUST display deployment events associated with each issue
- Rationale: Saves 30 min/day in status update requests
- Traces to: Story 1.1

REQ-F-002: System MUST show deployment timestamp, environment, and status
- Rationale: Developers need to know which environment has their changes
- Traces to: Story 1.1

## Success Criteria
SC-001: Developers can see deployment status without leaving Jira (no tool switching)
SC-002: Deployment data is visible within 1 minute of deployment completion
SC-003: Questions in Slack about "is this deployed?" decrease by 80%
```

### Example 2: Confluence Integration

#### Before (Implementation-Focused)
```markdown
Create Confluence macro using forge:macro module with
GraphQL queries to fetch page metadata and render with
@atlaskit components in Custom UI.
```

#### After (Specification-Focused)
```markdown
## User Story
As a content manager, I want to see page metadata and statistics
so that I can track content performance without exporting to spreadsheets.

## Requirements
REQ-F-010: System MUST display page view count, last edit date, and contributors
- Rationale: Content managers currently export to Excel, taking 2 hours/week
- Traces to: Story 3.1

REQ-F-011: System MUST update metrics automatically
- Rationale: Manual exports become stale quickly
- Traces to: Story 3.1

## Success Criteria
SC-010: Content managers can view page metrics without leaving Confluence
SC-011: Metrics are current within last 24 hours (no stale data)
SC-012: Time spent on content reporting decreases by 75% (from 2 hours to 30 min/week)
```

## Remember

1. **Focus on user value** - Every requirement answers "why does user care?"
2. **Be specific and measurable** - Replace vague terms with numbers
3. **Avoid implementation** - Describe WHAT, never HOW
4. **Make it testable** - Each requirement has clear acceptance criteria
5. **Document assumptions** - Mark what you're inferring vs what user specified
6. **Consider edge cases** - Platform limits, errors, concurrent access
7. **Maintain traceability** - Requirements → Stories → Personas → Business Value
