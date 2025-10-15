<!-- toolkit: forge-sdd-toolkit -->
---
description: Architectural patterns for handling edge cases in Forge applications
applyTo: "**"
---

# Edge Case Architecture Patterns for Forge Apps

When designing architecture for Forge applications, always map specification edge cases to architectural decisions. This file provides proven patterns for common edge case scenarios.

## Core Principle

**Every edge case from the specification MUST have a corresponding architectural decision** that explains:
1. Detection strategy (how we know the edge case occurred)
2. Handling approach (what we do about it)
3. User experience (how it appears to the user)
4. Implementation reference (which ADD-XXX decision covers it)

## Mandatory Platform Edge Cases

These 5 edge cases must be addressed in EVERY Forge app architecture:

### 1. Timeout Edge Case (25-Second Limit)

**When to address**: Any operation that might take > 10 seconds

**Architectural Patterns**:

**Pattern A: Async Event Processing**
```
Use when: Operation takes 10-25 seconds
Implementation: scheduled:trigger or webtrigger:trigger
User experience: "Processing... check status page"
```

**Pattern B: Chunked Processing**
```
Use when: Operation is parallelizable
Implementation: Process in batches < 10s each
User experience: Progress bar showing completion %
```

**Pattern C: Timeout Prevention**
```
Use when: External API might be slow
Implementation: Set aggressive client timeout (10s)
User experience: Fast failure with retry option
```

**Decision Template**:
```markdown
### ADD-PERF-XXX: Timeout Handling

**Edge Case**: EC-001 (25s timeout on bulk sync)
**Pattern**: Async Event Processing
**Implementation**: Use `scheduled:trigger` for > 100 items
**User Experience**: Show "Sync queued" + status page
```

---

### 2. Storage Limit Edge Case (100KB per key)

**When to address**: When storing > 50KB per entity (50% safety margin)

**Architectural Patterns**:

**Pattern A: Data Partitioning**
```
Use when: Data naturally splits (e.g., per-issue, per-user)
Implementation: Separate storage keys
Key format: `{entity-type}-{entity-id}`
```

**Pattern B: Compression**
```
Use when: Data is text-heavy or repetitive
Implementation: gzip compression before storage
Trade-off: CPU cost for compress/decompress
```

**Pattern C: Data Archival**
```
Use when: Historical data not frequently accessed
Implementation: Delete data > 90 days old
User experience: "Showing last 90 days"
```

**Pattern D: External Storage**
```
Use when: Data regularly exceeds 100KB
Implementation: S3, DynamoDB, or other external DB
Trade-off: Additional infrastructure cost
```

**Decision Template**:
```markdown
### ADD-DATA-XXX: Storage Limit Handling

**Edge Case**: EC-002 (Storage limit per issue)
**Pattern**: Data Partitioning + Archival
**Capacity Planning**:
- Current: ~50KB/issue ✅
- Max: 100KB/issue (Forge limit)
- Archival: Delete after 90 days
```

---

### 3. External API Failure Edge Case

**When to address**: ALWAYS (any external API integration)

**Architectural Pattern: Multi-Tier Fallback**

**Tier 1: Retry with Exponential Backoff**
```
Attempts: 3 retries
Delays: 1s, 2s, 4s (exponential)
Total time: ~7 seconds
When: 5xx errors, timeouts, network errors
```

**Tier 2: Serve Stale Cache**
```
Max stale age: 1 hour (configurable)
When: Tier 1 exhausted
User experience: "⚠️ Using cached data from 15 min ago"
```

**Tier 3: Graceful Degradation**
```
Fallback: Empty state or error message
When: No cache available
User experience: "❌ Unable to load. [Retry]"
```

**Decision Template**:
```markdown
### ADD-REL-XXX: API Failure Handling

**Edge Case**: EC-003 (GitHub API unavailable)
**Pattern**: Multi-Tier Fallback
**Tier 1**: 3 retries (1s, 2s, 4s)
**Tier 2**: Stale cache (max 1h old)
**Tier 3**: Error message + manual retry
**Cache TTL**: 5 minutes (normal)
```

---

### 4. Missing Configuration/Credentials Edge Case

**When to address**: When app requires user-provided config (API tokens, URLs, etc.)

**Architectural Patterns**:

**Pattern A: Setup Wizard (Recommended)**
```
Detection: On app first load, check for required config
Implementation: Redirect to setup page if missing
User experience: Step-by-step wizard
Storage: Encrypted in Forge Storage
```

**Pattern B: Graceful Degradation**
```
Detection: Before each API call, check credentials
Implementation: App works in limited mode
User experience: "Connect to [Service] for full features"
```

**Pattern C: Default Configuration**
```
Use when: Reasonable defaults exist
Implementation: Ship with defaults, allow override
User experience: Works out-of-box, customizable
```

**Decision Template**:
```markdown
### ADD-REL-XXX: Missing Credentials Handling

**Edge Case**: EC-007 (BitBucket token not configured)
**Pattern**: Setup Wizard + Graceful Mode
**First Run**: Show setup wizard
**Subsequent**: Display "Connect BitBucket" banner
**Limited Mode**: Show cached data only
```

---

### 5. Rate Limit Exceeded Edge Case

**When to address**: When using third-party APIs with rate limits

**Architectural Patterns**:

**Pattern A: Aggressive Caching (Prevention)**
```
Cache TTL: 5-15 minutes
Cache hit target: > 80%
Result: Reduces API calls by 80-90%
```

**Pattern B: Rate Limit Detection**
```
Detection: Parse HTTP 429 response
Retry-After: Read header value
Implementation: Queue request for later
```

**Pattern C: Request Throttling**
```
Max concurrent: 5 requests
Queue pattern: Process sequentially
Backpressure: Slow down when 429 detected
```

**Decision Template**:
```markdown
### ADD-API-XXX: Rate Limit Handling

**Edge Case**: EC-009 (GitHub rate limit: 5000/hour)
**Pattern**: Aggressive Caching + Detection
**Cache TTL**: 5 minutes
**Expected calls**: ~500/hour (10% of limit)
**On 429**: Respect Retry-After + serve cache
**Monitoring**: Alert if > 80% of limit used
```

---

## Specification-Specific Edge Cases

Map each edge case from the specification (EC-001 to EC-0XX) to architectural decisions:

### Mapping Template

```markdown
| Edge Case ID | Description | Architectural Decision | Pattern | Status |
|--------------|-------------|------------------------|---------|--------|
| EC-001 | [Description from spec] | ADD-XXX-001 | [Pattern name] | ✅ Addressed |
```

### Common Specification Edge Cases

#### User Input Validation

**Pattern: Resolver-Side Validation**
```
Where: Backend resolver (never trust frontend)
What: Type checking, range validation, sanitization
When: Before any database write or external API call
Error: Return structured error to frontend
```

**Example**:
```typescript
// Resolver validation
export async function updateConfig(input: ConfigInput) {
  // Validate
  if (!input.apiUrl.startsWith('https://')) {
    return { error: 'API URL must use HTTPS' };
  }

  // Sanitize
  const sanitized = sanitizeInput(input.description);

  // Process
  await storage.set('config', { ...input, description: sanitized });
}
```

---

#### Concurrent Modifications

**Pattern: Optimistic Locking**
```
Approach: Version number or timestamp
Detection: Compare before write
Handling: Reject with conflict error
User experience: "Data changed by another user. Reload?"
```

**Example**:
```typescript
interface CachedData {
  value: any;
  version: number;
}

async function updateWithLocking(key: string, newValue: any) {
  const cached = await storage.get(key) as CachedData;

  // Check version
  if (cached.version !== expectedVersion) {
    return { error: 'Data was modified. Please refresh.' };
  }

  // Update with new version
  await storage.set(key, {
    value: newValue,
    version: cached.version + 1
  });
}
```

---

#### Unauthorized Access

**Pattern: Permission Inheritance**
```
Principle: Inherit Jira/Confluence permissions
Implementation: Use Forge context for user info
Never: Implement custom authorization
```

**Example**:
```typescript
import { requestJira } from '@forge/bridge';

export async function getIssue(issueKey: string) {
  // Forge automatically applies user's Jira permissions
  const response = await requestJira(`/rest/api/3/issue/${issueKey}`);

  // If user can't view issue, Jira returns 403
  if (response.status === 403) {
    return { error: 'You do not have permission to view this issue' };
  }

  return response.json();
}
```

---

## Edge Case Coverage Validation

When reviewing architecture decisions, validate:

### Completeness Checklist
- [ ] All 5 mandatory platform edge cases addressed
- [ ] All specification edge cases (EC-XXX) mapped to ADD-XXX
- [ ] Each edge case has detection strategy
- [ ] Each edge case has handling approach
- [ ] User experience defined for each
- [ ] No edge cases left unaddressed

### Quality Checklist
- [ ] Patterns are specific (not vague "we'll handle it")
- [ ] Implementation references valid ADD decisions
- [ ] Trade-offs documented (e.g., stale cache vs fresh data)
- [ ] Monitoring/alerting considered
- [ ] User experience is graceful (not crash or blank screen)

---

## Anti-Patterns to Avoid

### ❌ Ignoring Edge Cases
```
Bad: "API failure is rare, we won't handle it"
Why bad: Users see crashes in production
Good: Multi-tier fallback with cache
```

### ❌ Vague Handling
```
Bad: "We'll handle timeouts appropriately"
Why bad: No actionable implementation
Good: "Operations > 10s use async events (ADD-PERF-002)"
```

### ❌ Silent Failures
```
Bad: Catch error, log it, show nothing to user
Why bad: Users think it worked but it didn't
Good: Show clear error + retry option
```

### ❌ Forgetting User Experience
```
Bad: "Retry 3x with 10s delays" (30s spinner)
Why bad: User thinks app is frozen
Good: "Retrying... (Attempt 2 of 3)" with progress
```

### ❌ No Monitoring
```
Bad: Handle edge case, never track it
Why bad: Can't detect systemic issues
Good: Log edge case occurrence + alert on threshold
```

---

## Summary

**For every edge case**:
1. ✅ Identify from specification or platform constraints
2. ✅ Choose appropriate architectural pattern
3. ✅ Map to specific ADD-XXX decision
4. ✅ Define user experience
5. ✅ Document implementation approach
6. ✅ Add monitoring/alerting (for OPERATE stage)

**Mandatory coverage**: 5 platform edge cases + all specification edge cases = 100% addressed.
