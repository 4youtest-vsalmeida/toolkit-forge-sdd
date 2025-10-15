<!-- toolkit: forge-sdd-toolkit -->
---
type: instructions
category: implementation
topic: task-patterns
stage: plan
applies-to: forge-plan
created: 2025-01-05
author: VSALMEID
version: 1.0
---

# Implementation Task Patterns for Forge Apps

This guide provides **reusable task breakdown patterns** for common Forge implementation scenarios. Use these patterns to ensure consistency, completeness, and proper sizing of implementation tasks.

## Purpose

When breaking down user stories into implementation tasks:
- ✅ **Use these patterns** as starting templates
- ✅ **Adjust estimates** based on complexity and context
- ✅ **Always include** testing and error handling tasks
- ❌ **Don't skip steps** - each pattern task serves a purpose

---

## Pattern 1: Forge Module Implementation (Issue Panel)

**Use When**: Implementing a Jira issue panel, issue context, or similar UI module

**Typical Breakdown** (18-24 hours total for simple panel):

### TASK-X.1: Create Module Structure (2h)
**Description**: Set up the basic Forge module structure and routing
**Files to Create/Modify**:
- `manifest.yml` - Add module declaration
- `src/frontend/[module-name]/index.jsx` - Create entry point
- `src/frontend/[module-name]/App.jsx` - Create main component

**Acceptance Criteria**:
- [ ] Module declared in manifest with correct permissions
- [ ] Component renders "Hello World" placeholder
- [ ] Module appears in Jira at correct location

**Testing**: Manual verification in Forge tunnel

**Traces to**: ADD-UI-XXX (module selection decision)

---

### TASK-X.2: Implement UI Components (6-8h)
**Description**: Build the UI components according to design/mockups
**Files to Create**:
- `src/frontend/[module-name]/components/` (multiple components)
- `src/frontend/[module-name]/hooks/` (custom hooks if needed)
- `src/frontend/[module-name]/styles.css` (styles)

**Acceptance Criteria**:
- [ ] All UI components from design implemented
- [ ] Forge UI kit components used (Button, Table, etc.)
- [ ] Responsive layout works in different contexts
- [ ] Loading states implemented
- [ ] Empty states implemented

**Testing**: Visual testing in Forge tunnel

**Traces to**: REQ-F-XXX (functional requirement)

**Complexity Factors**:
- Simple (1-2 components): 4-6h
- Medium (3-5 components, forms): 6-8h
- Complex (6+ components, charts, tables): 8-12h (split into multiple tasks)

---

### TASK-X.3: Integrate with Forge APIs (4-6h)
**Description**: Connect UI to Forge APIs (storage, Jira API, external API)
**Files to Create/Modify**:
- `src/resolvers/[feature].js` - Backend resolver functions
- `src/frontend/[module-name]/api.js` - Frontend API client
- `manifest.yml` - Add required permissions

**Acceptance Criteria**:
- [ ] Resolver functions implemented and exported
- [ ] Frontend calls resolvers via `invoke()`
- [ ] Error handling for API failures
- [ ] Loading states while fetching data
- [ ] Permissions added to manifest

**Testing**: Integration testing in Forge tunnel

**Traces to**: ADD-INT-XXX (integration decision)

**Complexity Factors**:
- Simple (storage only): 3-4h
- Medium (Jira API reads): 4-6h
- Complex (external API + auth): 6-8h

---

### TASK-X.4: Add Error Handling (3h)
**Description**: Implement comprehensive error handling and user feedback
**Files to Modify**:
- All resolver files
- UI components with error boundaries
- Error display components

**Acceptance Criteria**:
- [ ] All API calls have try-catch blocks
- [ ] Meaningful error messages shown to users
- [ ] Errors logged for debugging
- [ ] Retry mechanisms where appropriate
- [ ] Graceful degradation for non-critical errors

**Testing**: Test error scenarios (API down, timeout, invalid data)

**Traces to**: EC-XXX (edge cases)

---

### TASK-X.5: Write Unit Tests (3-4h)
**Description**: Write unit tests for business logic and utilities
**Files to Create**:
- `src/resolvers/__tests__/[feature].test.js`
- `src/frontend/[module-name]/__tests__/utils.test.js`

**Acceptance Criteria**:
- [ ] All resolver functions have unit tests
- [ ] Utility functions tested
- [ ] Edge cases covered
- [ ] Test coverage > 80% for business logic

**Testing**: `npm test`

**Framework**: Jest + @forge/cli testing tools

---

### TASK-X.6: Write Integration Tests (2h)
**Description**: Test end-to-end module functionality
**Files to Create**:
- `src/__tests__/integration/[feature].test.js`

**Acceptance Criteria**:
- [ ] Happy path tested end-to-end
- [ ] Error scenarios tested
- [ ] Edge cases from spec tested

**Testing**: `forge test` or manual test plan

---

## Pattern 2: Storage Layer Implementation

**Use When**: Implementing data persistence using Forge storage API

**Typical Breakdown** (12-16 hours):

### TASK-X.1: Design Storage Schema (2h)
**Description**: Define storage keys, data structures, and partitioning strategy
**Files to Create**:
- `docs/storage-schema.md` - Document storage design

**Acceptance Criteria**:
- [ ] All data models documented with schemas
- [ ] Key naming conventions defined
- [ ] Data size validated (< 100KB per key)
- [ ] Partitioning strategy if data > 100KB

**Traces to**: ADD-DATA-XXX (data architecture decision)

---

### TASK-X.2: Implement Storage Service (4-5h)
**Description**: Create storage service layer with CRUD operations
**Files to Create**:
- `src/services/storage.js` - Storage abstraction layer
- `src/services/__tests__/storage.test.js` - Unit tests

**Acceptance Criteria**:
- [ ] CRUD functions (get, set, delete, query)
- [ ] Error handling for storage failures
- [ ] Data validation before write
- [ ] Automatic key partitioning if needed
- [ ] Unit tests with mocked storage API

**Testing**: Unit tests pass

---

### TASK-X.3: Handle Storage Edge Cases (3-4h)
**Description**: Implement edge case handling (size limits, concurrent access)
**Files to Modify**:
- `src/services/storage.js`

**Acceptance Criteria**:
- [ ] Size limit checks (warn at 90KB, error at 100KB)
- [ ] Compression for large data
- [ ] Concurrent write conflict resolution
- [ ] Data migration helpers if schema changes

**Testing**: Test with large datasets (95KB, 105KB)

**Traces to**: EC-Platform-002 (storage limit edge case)

---

### TASK-X.4: Add Storage Monitoring (2h)
**Description**: Add logging and monitoring for storage operations
**Files to Modify**:
- `src/services/storage.js`

**Acceptance Criteria**:
- [ ] Log storage operations (writes, reads, deletes)
- [ ] Track storage usage per key
- [ ] Alert on approaching size limits

**Testing**: Verify logs in Forge console

---

### TASK-X.5: Write Integration Tests (3h)
**Description**: Test storage service end-to-end
**Files to Create**:
- `src/__tests__/integration/storage.test.js`

**Acceptance Criteria**:
- [ ] Test CRUD operations against real storage
- [ ] Test data persistence across invocations
- [ ] Test edge cases (size limits, partitioning)
- [ ] Test concurrent operations

**Testing**: Integration tests pass

---

## Pattern 3: External API Integration

**Use When**: Integrating with external services (GitHub, GitLab, etc.)

**Typical Breakdown** (16-20 hours):

### TASK-X.1: Set Up API Client (3-4h)
**Description**: Create API client with authentication
**Files to Create**:
- `src/services/[service]-client.js` - API client
- `src/services/__tests__/[service]-client.test.js`

**Acceptance Criteria**:
- [ ] HTTP client configured (fetch or axios)
- [ ] Authentication implemented (OAuth, API key, etc.)
- [ ] Base URL and endpoints defined
- [ ] Request/response logging
- [ ] Unit tests with mocked responses

**Traces to**: ADD-INT-XXX (integration decision)

---

### TASK-X.2: Implement API Operations (5-6h)
**Description**: Implement required API operations
**Files to Modify**:
- `src/services/[service]-client.js`

**Acceptance Criteria**:
- [ ] All required endpoints implemented
- [ ] Request validation
- [ ] Response parsing and mapping to internal models
- [ ] Rate limit headers parsed
- [ ] Pagination handling if needed

**Testing**: Unit tests with mocked API

---

### TASK-X.3: Add Error Handling & Retry Logic (3-4h)
**Description**: Handle API failures gracefully
**Files to Modify**:
- `src/services/[service]-client.js`

**Acceptance Criteria**:
- [ ] HTTP error codes handled (4xx, 5xx)
- [ ] Network timeout handling (max 20s)
- [ ] Exponential backoff retry (3 attempts)
- [ ] Circuit breaker pattern for repeated failures
- [ ] User-friendly error messages

**Testing**: Test with mocked failures (timeout, 500, 429)

**Traces to**: EC-XXX (API failure edge cases)

---

### TASK-X.4: Implement Rate Limiting (2-3h)
**Description**: Respect API rate limits
**Files to Modify**:
- `src/services/[service]-client.js`

**Acceptance Criteria**:
- [ ] Track rate limit headers
- [ ] Queue requests when limit approached
- [ ] Delay between requests if needed
- [ ] Alert user when rate limited

**Testing**: Test with rate limit simulation

**Traces to**: EC-Platform-005 (rate limit edge case)

---

### TASK-X.5: Write Integration Tests (3h)
**Description**: Test API integration end-to-end
**Files to Create**:
- `src/__tests__/integration/[service].test.js`

**Acceptance Criteria**:
- [ ] Test successful API calls
- [ ] Test error scenarios
- [ ] Test rate limiting behavior
- [ ] Test authentication flow

**Testing**: Integration tests pass (may use sandbox API)

---

## Pattern 4: Async Job Processing (Timeout Handling)

**Use When**: Operations may exceed 25-second timeout limit

**Typical Breakdown** (14-18 hours):

### TASK-X.1: Design Async Job System (2-3h)
**Description**: Design job queue and processing architecture
**Files to Create**:
- `docs/async-jobs-design.md`

**Acceptance Criteria**:
- [ ] Job states defined (pending, processing, completed, failed)
- [ ] Storage schema for job queue
- [ ] Trigger mechanism defined (scheduled event or queue)
- [ ] Job result retrieval design

**Traces to**: ADD-PERF-XXX (timeout handling decision)

---

### TASK-X.2: Implement Job Queue (4-5h)
**Description**: Create job queue service
**Files to Create**:
- `src/services/job-queue.js` - Job queue manager
- `src/services/__tests__/job-queue.test.js`

**Acceptance Criteria**:
- [ ] enqueueJob(jobType, params) function
- [ ] getJobStatus(jobId) function
- [ ] Job persistence in storage
- [ ] Job state transitions
- [ ] Unit tests

**Testing**: Unit tests pass

---

### TASK-X.3: Implement Job Processor (4-5h)
**Description**: Process jobs in background
**Files to Create**:
- `src/jobs/processor.js` - Main job processor
- `src/jobs/handlers/[job-type].js` - Job-specific handlers
- `manifest.yml` - Add scheduled event trigger

**Acceptance Criteria**:
- [ ] Scheduled event registered (every 1 minute)
- [ ] Processor fetches pending jobs
- [ ] Job handlers execute business logic
- [ ] Job status updated (completed/failed)
- [ ] Timeout protection (max 20s per job)

**Testing**: Test in Forge tunnel with scheduled events

---

### TASK-X.4: Add Job Monitoring & Cleanup (2-3h)
**Description**: Monitor job health and clean up old jobs
**Files to Modify**:
- `src/jobs/processor.js`

**Acceptance Criteria**:
- [ ] Log job execution (start, end, duration)
- [ ] Detect stuck jobs (processing > 5 minutes)
- [ ] Retry failed jobs (max 3 attempts)
- [ ] Delete completed jobs after 24 hours
- [ ] Alert on repeated failures

**Testing**: Test with stuck jobs and failures

**Traces to**: EC-Platform-001 (timeout edge case)

---

### TASK-X.5: Update UI for Async Operations (2h)
**Description**: Update UI to handle async job status
**Files to Modify**:
- UI components that trigger long operations

**Acceptance Criteria**:
- [ ] Show "Job started" message after enqueue
- [ ] Poll for job status
- [ ] Show progress indicator
- [ ] Display results when complete
- [ ] Handle job failures gracefully

**Testing**: Test long-running operations

---

## Pattern 5: Testing Tasks

**Use When**: Adding comprehensive test coverage

### TASK-X.1: Unit Tests (2-4h per module)
**Scope**: Pure functions, utilities, business logic
**Framework**: Jest
**Coverage Target**: > 80%

**Example Structure**:
```javascript
describe('MyService', () => {
  describe('functionName', () => {
    it('should handle valid input', () => { /* ... */ });
    it('should throw error for invalid input', () => { /* ... */ });
    it('should handle edge case X', () => { /* ... */ });
  });
});
```

---

### TASK-X.2: Integration Tests (3-5h per feature)
**Scope**: Resolver → Storage → API flows
**Framework**: Jest + @forge/cli
**Coverage**: Happy path + error scenarios

---

### TASK-X.3: E2E Tests (4-6h)
**Scope**: Full user flows (manual or automated)
**Tool**: Manual test plan or Playwright
**Coverage**: Critical user journeys

---

## Pattern 6: Refactoring Tasks

**Use When**: Technical debt or code quality improvements

### TASK-X.1: Extract Service Layer (3-4h)
**Description**: Extract business logic from resolvers to services
**Pattern**: Resolvers should be thin, services contain logic

---

### TASK-X.2: Add TypeScript Types (2-3h per module)
**Description**: Add TypeScript for type safety
**Files**: Convert .js to .ts, add interfaces

---

### TASK-X.3: Performance Optimization (4-6h)
**Description**: Optimize slow operations
**Focus**: Caching, batching, query optimization

---

## Pattern 7: Documentation Tasks

**Use When**: Documenting implementation for maintainability

### TASK-X.1: Code Documentation (1-2h)
**Scope**: JSDoc comments for public APIs
**Standard**: Document params, returns, throws

---

### TASK-X.2: Architecture Documentation (2-3h)
**Scope**: Update docs/ with implementation details
**Files**: Architecture diagrams, data flows

---

### TASK-X.3: User Documentation (2-4h)
**Scope**: User-facing docs (README, guides)
**Audience**: End users and admins

---

## Pattern 8: Edge Case Implementation Tasks

**Use When**: Implementing specific edge cases from specification

### TASK-X.1: Platform Edge Case (EC-Platform-XXX) (2-4h each)

**EC-Platform-001: Timeout Handling**
- Implement async job pattern (see Pattern 4)
- Estimate: 14-18h total

**EC-Platform-002: Storage Limit**
- Implement data partitioning or compression
- Estimate: 3-4h

**EC-Platform-003: API Failure**
- Implement retry logic with exponential backoff
- Estimate: 3-4h

**EC-Platform-004: Configuration Errors**
- Implement validation and user feedback
- Estimate: 2-3h

**EC-Platform-005: Rate Limiting**
- Implement request throttling
- Estimate: 2-3h

---

### TASK-X.2: Specification Edge Case (EC-XXX) (1-3h each)

**Template**:
```markdown
TASK-X.X: Implement Edge Case EC-XXX
Description: [Edge case description from spec]
Files: [Affected files]
Acceptance Criteria:
- [ ] Edge case scenario detected
- [ ] Appropriate handling implemented
- [ ] User feedback provided
- [ ] Test case added
Estimate: [1-3h based on complexity]
Traces to: EC-XXX, ADD-XXX (if mapped)
```

---

## Estimation Guidelines

### Base Estimates by Complexity:

| Task Type | Simple | Medium | Complex |
|-----------|--------|--------|---------|
| **UI Component** | 4h | 6h | 8h+ (split) |
| **API Integration** | 3h | 5h | 7h+ (split) |
| **Storage Layer** | 2h | 4h | 6h |
| **Business Logic** | 2h | 4h | 6h |
| **Testing (Unit)** | 1h | 2h | 3h |
| **Testing (Integration)** | 2h | 3h | 4h |
| **Edge Case Handling** | 1h | 2h | 3h |
| **Documentation** | 1h | 2h | 3h |

### Task Sizing Rules:

1. **2-8 hour range**: All tasks must fit this range
2. **If > 8 hours**: Split into multiple tasks
3. **Include testing time**: Add 30-50% for testing
4. **Include buffer**: Add 20% for unknowns

### Example Calculation:

```
Task: "Implement issue panel with PR list"

Breakdown:
- Create module structure: 2h
- Build UI components (medium): 6h
- Integrate GitHub API (medium): 5h
- Error handling: 3h
- Unit tests: 3h
- Integration tests: 2h

Total: 21h → Split into 3 tasks:
  TASK-1: Module + UI (8h)
  TASK-2: API integration + errors (8h)
  TASK-3: Testing (5h)
```

---

## Common Anti-Patterns to Avoid

❌ **Don't**: Create "Implement feature X" (20h)
✅ **Do**: Break down into module, API, testing tasks (6h, 8h, 6h)

❌ **Don't**: Forget testing tasks
✅ **Do**: Add unit + integration test tasks (30-50% of development time)

❌ **Don't**: Skip error handling tasks
✅ **Do**: Add explicit error handling task (2-3h per feature)

❌ **Don't**: Ignore edge cases
✅ **Do**: Create task for each edge case from spec (1-3h each)

❌ **Don't**: Estimate without considering complexity
✅ **Do**: Use base estimates + complexity multipliers

---

## Usage in forge-plan Prompt

When breaking down user stories (Step 2), reference specific patterns:

**Example**:
```markdown
Story: "As a user, I want to see a list of PRs in the issue panel"

Tasks (using Pattern 1: Forge Module Implementation):
- TASK-2.1.1: Create issue panel module structure (2h) [Pattern 1, Task 1]
- TASK-2.1.2: Build PR list UI components (6h) [Pattern 1, Task 2]
- TASK-2.1.3: Integrate GitHub API (5h) [Pattern 3, Tasks 1-2]
- TASK-2.1.4: Add error handling (3h) [Pattern 1, Task 4]
- TASK-2.1.5: Write unit tests (3h) [Pattern 1, Task 5]
- TASK-2.1.6: Write integration tests (2h) [Pattern 1, Task 6]

Total: 21h (within 18-24h estimate for Pattern 1)
```

---

**Remember**: These patterns are starting points. Adjust based on:
- Specific requirements
- Team experience
- Project complexity
- Technical constraints
