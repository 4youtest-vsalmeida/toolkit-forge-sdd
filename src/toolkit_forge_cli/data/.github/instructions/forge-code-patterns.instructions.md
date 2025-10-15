<!-- toolkit: forge-sdd-toolkit -->
---
type: instructions
category: implementation
topic: code-patterns
stage: implement
applies-to: forge-implement
created: 2025-01-05
author: VSALMEID
version: 1.0
---

# Forge Code Patterns

Reusable code patterns for common Forge implementation scenarios. Use these patterns to ensure consistency, quality, and compliance with Forge platform constraints.

## Purpose

- ✅ Accelerate development with proven patterns
- ✅ Ensure Forge platform compliance (timeout, storage, API limits)
- ✅ Maintain code consistency across projects
- ✅ Include proper error handling and traceability

---

## Pattern 1: Resolver Function (Basic CRUD)

**Use When**: Creating backend resolver functions for API operations

```typescript
/**
 * Resolver function pattern with error handling
 *
 * @requirement REQ-F-001
 * @task TASK-2.1.1
 */
import Resolver from '@forge/resolver';
import api, { route } from '@forge/api';

const resolver = new Resolver();

resolver.define('getData', async (req) => {
  try {
    // Extract parameters
    const { issueKey } = req.payload;
    
    // Validate input
    if (!issueKey) {
      throw new Error('issueKey is required');
    }
    
    // Call Jira API
    const response = await api.asUser().requestJira(route`/rest/api/3/issue/${issueKey}`);
    const data = await response.json();
    
    // Return success
    return {
      success: true,
      data,
    };
  } catch (error) {
    // Log error for debugging
    console.error('getData failed:', error);
    
    // Return user-friendly error
    return {
      success: false,
      error: 'Unable to fetch data. Please try again.',
    };
  }
});

export const handler = resolver.getDefinitions();
```

---

## Pattern 2: Storage Service (with Size Validation)

**Use When**: Implementing Forge storage operations

```typescript
/**
 * Storage service with 100KB limit validation
 *
 * @requirement REQ-NF-003 (Storage management)
 * @architecture ADD-DATA-001
 */
import { storage } from '@forge/api';

const MAX_STORAGE_SIZE = 100000; // 100KB limit

export class StorageService {
  /**
   * Set data in storage with size validation
   * Traces to: EC-Platform-002 (Storage limit)
   */
  async set(key: string, value: any): Promise<void> {
    try {
      const serialized = JSON.stringify(value);
      const size = new Blob([serialized]).size;
      
      // Check size limit
      if (size > MAX_STORAGE_SIZE) {
        throw new Error(`Data size (${size}b) exceeds 100KB limit`);
      }
      
      await storage.set(key, value);
      console.log(`Stored ${key}: ${size} bytes`);
    } catch (error) {
      console.error(`Storage.set failed for ${key}:`, error);
      throw error;
    }
  }

  /**
   * Get data from storage with fallback
   */
  async get<T>(key: string, defaultValue: T): Promise<T> {
    try {
      const value = await storage.get(key);
      return value !== undefined ? value : defaultValue;
    } catch (error) {
      console.error(`Storage.get failed for ${key}:`, error);
      return defaultValue;
    }
  }

  /**
   * Delete data from storage
   */
  async delete(key: string): Promise<void> {
    try {
      await storage.delete(key);
    } catch (error) {
      console.error(`Storage.delete failed for ${key}:`, error);
    }
  }
}

export const storageService = new StorageService();
```

---

## Pattern 3: API Client with Retry Logic

**Use When**: Calling external APIs with retry and timeout handling

```typescript
/**
 * API client with retry logic and timeout protection
 *
 * @requirement REQ-F-002 (External API integration)
 * Traces to: EC-Platform-003 (API failure), EC-Platform-005 (Rate limiting)
 */

interface RetryOptions {
  maxAttempts?: number;
  delayMs?: number;
  timeoutMs?: number;
}

export class ApiClient {
  private baseUrl: string;
  private apiToken: string;

  constructor(baseUrl: string, apiToken: string) {
    this.baseUrl = baseUrl;
    this.apiToken = apiToken;
  }

  /**
   * Execute request with retry logic
   */
  async request<T>(
    endpoint: string,
    options: RetryOptions = {}
  ): Promise<T> {
    const {
      maxAttempts = 3,
      delayMs = 1000,
      timeoutMs = 15000, // Max 15s (well under 25s limit)
    } = options;

    let lastError: Error;

    for (let attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        // Timeout protection (Traces to: EC-Platform-001)
        const controller = new AbortController();
        const timeout = setTimeout(() => controller.abort(), timeoutMs);

        const response = await fetch(`${this.baseUrl}${endpoint}`, {
          headers: {
            'Authorization': `Bearer ${this.apiToken}`,
            'Content-Type': 'application/json',
          },
          signal: controller.signal,
        });

        clearTimeout(timeout);

        // Handle rate limiting (Traces to: EC-Platform-005)
        if (response.status === 429) {
          const retryAfter = parseInt(response.headers.get('Retry-After') || '60');
          console.warn(`Rate limited. Waiting ${retryAfter}s`);
          await this.sleep(retryAfter * 1000);
          continue;
        }

        if (!response.ok) {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        return await response.json();

      } catch (error) {
        lastError = error as Error;
        console.error(`API request failed (attempt ${attempt}/${maxAttempts}):`, error);

        // Don't retry on last attempt
        if (attempt < maxAttempts) {
          // Exponential backoff
          const backoff = delayMs * Math.pow(2, attempt - 1);
          await this.sleep(backoff);
        }
      }
    }

    throw new Error(`API request failed after ${maxAttempts} attempts: ${lastError.message}`);
  }

  private sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}
```

---

## Pattern 4: Caching Layer

**Use When**: Implementing caching to reduce API calls

```typescript
/**
 * Caching service with TTL
 *
 * @requirement REQ-NF-002 (Performance - caching)
 */
import { storage } from '@forge/api';

interface CacheEntry<T> {
  data: T;
  timestamp: number;
  ttl: number;
}

export class CacheService {
  /**
   * Get cached data or fetch fresh
   */
  async getOrFetch<T>(
    key: string,
    fetchFn: () => Promise<T>,
    ttlMs: number = 300000 // 5 minutes default
  ): Promise<T> {
    try {
      // Check cache
      const cached = await storage.get(key) as CacheEntry<T> | undefined;
      
      if (cached) {
        const age = Date.now() - cached.timestamp;
        
        // Return cached if still valid
        if (age < cached.ttl) {
          console.log(`Cache hit for ${key} (age: ${Math.round(age/1000)}s)`);
          return cached.data;
        }
      }

      // Cache miss or expired - fetch fresh
      console.log(`Cache miss for ${key}, fetching fresh data`);
      const data = await fetchFn();

      // Store in cache
      const entry: CacheEntry<T> = {
        data,
        timestamp: Date.now(),
        ttl: ttlMs,
      };

      await storage.set(key, entry);
      return data;

    } catch (error) {
      console.error(`Cache error for ${key}:`, error);
      
      // Fallback to stale cache if available
      const stale = await storage.get(key) as CacheEntry<T> | undefined;
      if (stale) {
        console.warn(`Returning stale cache for ${key}`);
        return stale.data;
      }

      throw error;
    }
  }

  /**
   * Invalidate cache
   */
  async invalidate(key: string): Promise<void> {
    await storage.delete(key);
  }
}

export const cacheService = new CacheService();
```

---

## Pattern 5: Error Boundary (React Custom UI)

**Use When**: Building Custom UI with React

```typescript
/**
 * Error boundary component for Custom UI
 *
 * @requirement REQ-NFR-007 (Error handling)
 */
import React, { Component, ErrorInfo, ReactNode } from 'react';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
  error?: Error;
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error: Error): State {
    return {
      hasError: true,
      error,
    };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('ErrorBoundary caught error:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback || (
        <div style={{ padding: '20px', color: 'red' }}>
          <h2>Something went wrong</h2>
          <p>Unable to load this component. Please refresh the page.</p>
        </div>
      );
    }

    return this.props.children;
  }
}

// Usage:
// <ErrorBoundary>
//   <MyComponent />
// </ErrorBoundary>
```

---

## Pattern 6: Async Job Processing (Timeout Handling)

**Use When**: Operations might exceed 25-second timeout

```typescript
/**
 * Async job queue for long-running operations
 *
 * Traces to: EC-Platform-001 (25-second timeout)
 * @architecture ADD-PERF-002 (Async processing decision)
 */
import { storage } from '@forge/api';

export enum JobStatus {
  PENDING = 'pending',
  PROCESSING = 'processing',
  COMPLETED = 'completed',
  FAILED = 'failed',
}

interface Job {
  id: string;
  type: string;
  params: any;
  status: JobStatus;
  createdAt: number;
  updatedAt: number;
  result?: any;
  error?: string;
  attempts: number;
}

export class JobQueue {
  /**
   * Enqueue a new job
   */
  async enqueue(type: string, params: any): Promise<string> {
    const jobId = `job-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    
    const job: Job = {
      id: jobId,
      type,
      params,
      status: JobStatus.PENDING,
      createdAt: Date.now(),
      updatedAt: Date.now(),
      attempts: 0,
    };

    await storage.set(`job:${jobId}`, job);
    
    // Add to pending queue
    const queue = await storage.get('job:queue') || [];
    queue.push(jobId);
    await storage.set('job:queue', queue);

    console.log(`Enqueued job ${jobId} (type: ${type})`);
    return jobId;
  }

  /**
   * Get job status
   */
  async getStatus(jobId: string): Promise<Job | null> {
    return await storage.get(`job:${jobId}`) || null;
  }

  /**
   * Process next job (called by scheduled event)
   */
  async processNext(): Promise<void> {
    const queue = await storage.get('job:queue') || [];
    
    if (queue.length === 0) {
      return;
    }

    const jobId = queue.shift();
    await storage.set('job:queue', queue);

    const job = await storage.get(`job:${jobId}`) as Job;
    if (!job) return;

    job.status = JobStatus.PROCESSING;
    job.updatedAt = Date.now();
    job.attempts++;
    await storage.set(`job:${jobId}`, job);

    try {
      // Execute job (max 20s to leave buffer)
      const result = await this.executeJob(job);

      job.status = JobStatus.COMPLETED;
      job.result = result;
      job.updatedAt = Date.now();
      await storage.set(`job:${jobId}`, job);

    } catch (error) {
      console.error(`Job ${jobId} failed:`, error);

      // Retry logic (max 3 attempts)
      if (job.attempts < 3) {
        job.status = JobStatus.PENDING;
        queue.push(jobId); // Re-queue
        await storage.set('job:queue', queue);
      } else {
        job.status = JobStatus.FAILED;
        job.error = error.message;
      }

      job.updatedAt = Date.now();
      await storage.set(`job:${jobId}`, job);
    }
  }

  private async executeJob(job: Job): Promise<any> {
    // Implement job-specific logic based on job.type
    switch (job.type) {
      case 'bulk-sync':
        return await this.bulkSync(job.params);
      default:
        throw new Error(`Unknown job type: ${job.type}`);
    }
  }

  private async bulkSync(params: any): Promise<any> {
    // Implementation here
    return { synced: params.count };
  }
}

export const jobQueue = new JobQueue();
```

---

## Pattern 7: Testing with Mocks

**Use When**: Writing unit tests for resolvers

```typescript
/**
 * Unit test pattern with mocks
 *
 * @task TASK-2.1.5 (Unit tests)
 */
import { describe, it, expect, jest, beforeEach } from '@jest/globals';
import { handler } from '../resolver';

// Mock Forge API
jest.mock('@forge/api', () => ({
  storage: {
    get: jest.fn(),
    set: jest.fn(),
  },
  fetch: jest.fn(),
}));

describe('Resolver: getData', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should fetch and return data successfully', async () => {
    // Arrange
    const mockData = { id: 'PROJ-123', summary: 'Test issue' };
    const mockRequest = {
      payload: { issueKey: 'PROJ-123' },
    };

    global.fetch = jest.fn().mockResolvedValue({
      ok: true,
      json: async () => mockData,
    });

    // Act
    const result = await handler.getData(mockRequest);

    // Assert
    expect(result.success).toBe(true);
    expect(result.data).toEqual(mockData);
  });

  it('should handle API failure gracefully (EC-Platform-003)', async () => {
    // Arrange
    const mockRequest = {
      payload: { issueKey: 'PROJ-123' },
    };

    global.fetch = jest.fn().mockRejectedValue(new Error('Network error'));

    // Act
    const result = await handler.getData(mockRequest);

    // Assert
    expect(result.success).toBe(false);
    expect(result.error).toBeDefined();
  });

  it('should validate required parameters', async () => {
    // Arrange
    const mockRequest = {
      payload: {}, // Missing issueKey
    };

    // Act
    const result = await handler.getData(mockRequest);

    // Assert
    expect(result.success).toBe(false);
    expect(result.error).toContain('required');
  });
});
```

---

## Pattern 8: Input Validation

**Use When**: Validating user inputs (security)

```typescript
/**
 * Input validation utilities
 *
 * @requirement REQ-NFR-006 (Security - input validation)
 */

export class InputValidator {
  /**
   * Validate Jira issue key format
   */
  static isValidIssueKey(key: string): boolean {
    const pattern = /^[A-Z][A-Z0-9]*-[0-9]+$/;
    return pattern.test(key);
  }

  /**
   * Sanitize string input (prevent injection)
   */
  static sanitizeString(input: string): string {
    return input
      .replace(/[<>]/g, '') // Remove HTML tags
      .replace(/['";]/g, '') // Remove quotes/semicolons
      .trim();
  }

  /**
   * Validate email format
   */
  static isValidEmail(email: string): boolean {
    const pattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return pattern.test(email);
  }

  /**
   * Validate number range
   */
  static isInRange(value: number, min: number, max: number): boolean {
    return value >= min && value <= max;
  }
}

// Usage in resolver:
resolver.define('updateData', async (req) => {
  const { issueKey, email, priority } = req.payload;

  if (!InputValidator.isValidIssueKey(issueKey)) {
    return { success: false, error: 'Invalid issue key format' };
  }

  if (!InputValidator.isValidEmail(email)) {
    return { success: false, error: 'Invalid email format' };
  }

  if (!InputValidator.isInRange(priority, 1, 5)) {
    return { success: false, error: 'Priority must be between 1 and 5' };
  }

  // Proceed with validated inputs
  // ...
});
```

---

## Anti-Patterns to Avoid

### ❌ Hardcoded Secrets
```typescript
// BAD
const API_KEY = 'abc123secret';

// GOOD
const API_KEY = process.env.BITBUCKET_API_KEY;
```

### ❌ No Error Handling
```typescript
// BAD
async function fetchData() {
  const response = await fetch(url);
  return await response.json(); // Crashes if fetch fails
}

// GOOD
async function fetchData() {
  try {
    const response = await fetch(url);
    if (!response.ok) throw new Error('Fetch failed');
    return await response.json();
  } catch (error) {
    console.error('fetchData failed:', error);
    return null; // Graceful fallback
  }
}
```

### ❌ Missing Traceability
```typescript
// BAD
function processData(data) {
  return data.map(x => x * 2);
}

// GOOD
/**
 * Process data per business logic
 *
 * @requirement REQ-F-003
 * @task TASK-2.3.1
 */
function processData(data) {
  return data.map(x => x * 2);
}
```

### ❌ Long Synchronous Operations
```typescript
// BAD - Will timeout on large datasets
async function syncAll(keys) {
  for (const key of keys) {
    await syncItem(key); // 100 items × 500ms = 50s (TIMEOUT!)
  }
}

// GOOD - Use async job pattern
async function syncAll(keys) {
  const jobId = await jobQueue.enqueue('bulk-sync', { keys });
  return { jobId, status: 'Processing in background' };
}
```

---

## Usage Guidelines

1. **Copy pattern as starting point** - Adapt to your specific needs
2. **Maintain traceability** - Update @requirement and @task comments
3. **Add tests** - Every pattern should have corresponding test
4. **Handle errors** - Never let exceptions crash the app
5. **Log appropriately** - console.error for errors, console.log for info
6. **Respect limits** - 25s timeout, 100KB storage, rate limits

---

**Remember**: These patterns ensure Forge compliance and production quality. Don't reinvent the wheel - use proven patterns.
