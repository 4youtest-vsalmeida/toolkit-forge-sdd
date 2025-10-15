<!-- toolkit: forge-sdd-toolkit -->
---
description: Forge platform constraints and defaults for specification phase
applyTo: "sdd-docs/**/*.md"
---

# Forge Platform Constraints & Defaults

When creating specifications for Forge apps, use these constraints and defaults for informed guesses.

## Platform Limitations

### Execution & Performance
- **Maximum execution time**: 25 seconds per function invocation
- **Timeout behavior**: Function terminates, no partial results saved
- **Async events**: Required for operations > 20 seconds
- **Concurrent invocations**: Limited by Atlassian infrastructure

### Storage & Data
- **Storage per key**: 100KB maximum
- **Total storage**: 5GB per app installation
- **Entity properties**: 32KB per property (alternative to Forge Storage)
- **Query capabilities**: Limited - no complex queries on Forge Storage

### Runtime Environment
- **Node.js sandbox**: Limited native modules available
- **Network access**: Outbound HTTPS only, no incoming connections
- **File system**: No persistent file system access
- **Environment variables**: Available but limited

### API & Integration
- **Rate limits**: Vary by Atlassian API (typically 100-1000 req/min)
- **Webhook delivery**: Best effort, may retry on failure
- **External APIs**: Must be HTTPS, consider timeouts

## Default Assumptions for Specifications

### Authentication & Authorization

**Default**: Forge provides automatic user context
- User identity available via `context.accountId`
- No need to implement authentication
- Assume single sign-on with Atlassian account

**Scope Strategy**:
- Start with read-only scopes (`read:jira-work`, `read:confluence-content`)
- Add write scopes only when explicitly needed
- Never assume admin scopes unless critical requirement
- Document why each scope is necessary

**When to ask user**:
- If admin-level access seems required
- If write operations on sensitive data (issues, pages)
- If cross-product data access needed

### Data Storage Strategy

**< 10KB per entity**:
- Default: Forge Storage API
- Fast access, simple key-value
- Good for user preferences, cache, settings

**10-100KB per entity**:
- Default: Forge Storage with compression consideration
- May need data partitioning strategy
- Flag if approaching limit

**> 100KB per entity**:
- Cannot use Forge Storage directly
- Assumption: Will need external storage OR data restructuring
- Document as: [ASSUMPTION: Data will be partitioned/external - to be decided in ARCHITECT]

**Real-time data**:
- Assumption: Caching strategy needed (5-15 min cache typical)
- If < 1 min freshness required, flag for Custom UI consideration

### Performance Expectations

**User-facing operations**:
- UI response: < 2 seconds for user actions
- Loading indicators: Required if > 500ms
- Progressive loading: Consider for large data sets

**Background processing**:
- < 10 seconds: Synchronous is acceptable
- 10-20 seconds: Consider async, warn about timeout risk
- > 20 seconds: Must use async events (note in requirements)

**External API calls**:
- Assume 3-5 second timeout
- Include retry logic in requirements (3 attempts with backoff)
- Cache responses when possible (document TTL)

### User Interface Patterns

**If user describes need for**:
- Real-time updates → Note: "Real-time data display required"
- Live collaboration → Note: "Multi-user concurrent access needed"
- Rich interactions → Note: "Interactive UI with dynamic updates"
- Complex forms → Note: "Multi-step form with validation"

**Don't specify**:
- Custom UI vs UI Kit (that's ARCHITECT decision)
- Specific UI framework (React, etc.)
- Component libraries

**Do document**:
- User interaction patterns needed
- Data refresh frequency
- Collaborative features

## Edge Cases to Always Consider

### 1. Timeout Scenarios
**Question to document**: What happens if operation approaches 25-second limit?

**Default assumptions**:
- Show progress indicator to user
- Queue long operations for async processing
- Provide status updates via polling or webhooks

**Example edge case**:
```
EC-001: Operation timeout
- Given: User triggers operation that may take > 25 seconds
- When: Execution approaches timeout
- Then: Operation queued for async processing, user sees status page
```

### 2. Storage Limit Scenarios
**Question to document**: What happens if data exceeds storage limits?

**Default assumptions**:
- Implement data retention policy (30-90 days typical)
- Archive or compress old data
- Warn user when approaching limits

**Example edge case**:
```
EC-002: Storage limit reached
- Given: App has stored 95% of available data (95KB/100KB per key)
- When: New data needs to be stored
- Then: Archive oldest data, notify admin if critical
```

### 3. External API Failures
**Question to document**: What happens when integrated system is unavailable?

**Default assumptions**:
- Show cached/stale data with timestamp
- Display user-friendly error message
- Provide manual retry option
- Log failure for admin review

**Example edge case**:
```
EC-003: External API unavailable
- Given: App integrates with external system (GitHub, etc.)
- When: External API returns error or times out
- Then: Display cached data (if available) with "Last updated: X min ago"
      AND show banner: "Unable to fetch latest data. Retry?"
```

### 4. Permission Issues
**Question to document**: What if user lacks required permissions?

**Default assumptions**:
- Check permissions before attempting operation
- Show clear error: "You need [permission] to perform this action"
- Provide link to admin or help documentation
- Gracefully degrade (hide features user can't use)

**Example edge case**:
```
EC-004: Insufficient permissions
- Given: User lacks required OAuth scope
- When: User attempts action requiring that scope
- Then: Display message: "Admin must grant [scope name] permission"
      AND provide link to app configuration
```

### 5. Concurrent Access
**Question to document**: What if multiple users modify same data simultaneously?

**Default assumptions**:
- Last write wins (for simple cases)
- Optimistic locking (for critical data)
- Show conflict resolution UI if needed

**Example edge case**:
```
EC-005: Concurrent modifications
- Given: Two users edit same configuration simultaneously
- When: Both save changes
- Then: System detects conflict, shows merge UI
      OR applies last write with notification to both users
```

## Platform-Specific Patterns

### Jira Apps

**Common constraints**:
- Issue panel: Limited screen space (consider collapsible sections)
- Bulk operations: May hit timeout (use async for > 50 issues)
- Custom fields: Data persisted in issue, consider size limits
- Automation rules: Execution frequency limits

**Default assumptions**:
- Users are familiar with Jira terminology
- Data should integrate with existing Jira workflows
- Permissions follow Jira project permissions

### Confluence Apps

**Common constraints**:
- Page macros: Content size limits (consider pagination)
- Real-time editing: Confluence handles, don't duplicate
- Storage: Page properties have size limits (32KB)

**Default assumptions**:
- Users create/edit content in Confluence editor
- Data tied to specific pages or spaces
- Permissions follow Confluence space permissions

## When to Flag as Potentially Impossible

Immediately flag these scenarios:

1. **Requires persistent connections**:
   - WebSockets to external services (Forge doesn't support)
   - Long-polling from external sources

2. **Requires file system access**:
   - Storing large files (> 100KB) locally
   - File-based processing without external storage

3. **Requires native binaries**:
   - Image processing libraries not available in Node.js sandbox
   - Native database drivers

4. **Requires incoming connections**:
   - Direct webhooks to Forge function (must proxy through Atlassian)
   - Public API endpoints on Forge app

5. **Exceeds execution time**:
   - Batch processing > 25 seconds without async strategy
   - Complex computations that can't be partitioned

## Informed Guess Examples

### Example 1: User says "Track deploys in Jira"

**Informed Guesses**:
- [ASSUMPTION: Deploy data comes from CI/CD webhooks - Forge can receive via Atlassian proxy]
- [ASSUMPTION: Store last 90 days of deploys (average 5KB per deploy = ~450KB well within limits)]
- [ASSUMPTION: Display in issue panel (contextual to specific issues)]
- [ASSUMPTION: Read-only view (users see deploys but don't trigger them from Jira)]

**Questions to Ask** (if unclear):
- Source of deploy data? (CI/CD system, manual entry, etc.)
- What deploy information to track? (commit, timestamp, environment, status)

### Example 2: User says "Sync Confluence pages to external system"

**Informed Guesses**:
- [ASSUMPTION: Sync triggered by page updates (using trigger:confluencePageUpdated)]
- [ASSUMPTION: Incremental sync (only changed pages, not full export)]
- [ASSUMPTION: Async processing if > 10 pages to sync]

**Flags to Raise**:
- ⚠️ Bidirectional sync may have conflict resolution complexity
- ⚠️ Large pages (> 100KB content) need special handling
- ⚠️ Sync frequency impacts API rate limits

**Questions to Ask**:
- Sync direction? (Confluence → External, bidirectional?)
- Conflict handling? (if bidirectional)
- Frequency? (real-time, hourly, daily?)

### Example 3: User says "Real-time collaboration features"

**Flags to Raise**:
- 🔴 Forge doesn't support WebSockets for real-time bidirectional communication
- 🔴 Polling every few seconds possible but not true real-time
- 🔴 May need to use Confluence/Jira's built-in collaboration features

**Alternative Assumptions**:
- [ASSUMPTION: Use polling every 5-10 seconds for "near real-time" updates]
- [ASSUMPTION: Leverage existing Jira/Confluence collaboration (comments, @mentions)]

**Questions to Ask**:
- What specifically needs to be real-time? (cursor position, typing indicators, or just data updates?)
- Is 5-10 second delay acceptable? (polling interval)

## Using These Constraints in IDEATE

### Step 1: Check user requirements against constraints
- Do requirements violate any hard limits?
- Are there timeout risks?
- Is storage strategy feasible?

### Step 2: Make informed assumptions
- Use defaults from this document
- Document as [ASSUMPTION: X because Y]
- Base on platform best practices

### Step 3: Flag impossible requirements
- Clearly mark: [PLATFORM LIMITATION: Cannot do X because Forge doesn't support Y]
- Suggest alternatives: [ALTERNATIVE: Use Z approach instead]

### Step 4: Document edge cases
- Include platform-specific edge cases
- Use templates from this document
- Add to "Edge Cases & Error Scenarios" section

### Step 5: Validate feasibility
- Cross-check requirements against platform limits
- Ensure no single operation exceeds 25s timeout
- Verify storage strategy is within limits
- Confirm external integrations are HTTPS-based
