---
type: template
level: knowledge
category: forge-module
product: jira
module: jira:issuePanel
complexity: intermediate
lifecycle-stages:
  - architect
  - implement
  - test
ui-approaches:
  - ui-kit
  - custom-ui
---

# Jira Issue Panel Template

> **Module Type**: `jira:issuePanel`  
> **Product**: Jira Cloud  
> **Use Cases**: Display custom data, integrate external services, show analytics

## Overview

A Jira Issue Panel is a module that appears in the issue view, providing additional context or functionality related to that specific issue.

### When to Use Issue Panels

✅ **Good Use Cases**:
- Display external data related to the issue (GitHub PRs, deployment status, etc.)
- Show analytics or metrics derived from issue data
- Provide quick actions that don't fit in buttons/menus
- Visualize relationships or dependencies
- Embed mini-dashboards

❌ **Not Recommended For**:
- Full CRUD applications (use `jira:projectPage` instead)
- Workflows that require multiple steps (use `jira:globalPage`)
- Admin configuration (use `jira:adminPage`)

## Architecture Decision Matrices

> **IMPORTANT**: These matrices help you make informed decisions. The toolkit **never decides for you** - you evaluate trade-offs and choose based on your requirements.

### Decision 1: UI Kit vs Custom UI

**Question**: Should I use Forge UI Kit or Custom UI (React)?

#### Evaluation Criteria

| Criterion | UI Kit | Custom UI | Weight |
|-----------|--------|-----------|---------|
| **Development Speed** | ✅ Fast (2-3 days) | ❌ Slow (5-7 days) | High |
| **Learning Curve** | ✅ Easy | ⚠️ Moderate (React) | Medium |
| **Customization** | ❌ Limited | ✅ Unlimited | High |
| **Performance** | ✅ Server-rendered | ⚠️ Client bundle | Medium |
| **Maintenance** | ✅ Minimal | ⚠️ CSS/styling | Medium |
| **Rich Interactions** | ❌ Not possible | ✅ Full control | High |
| **External Libraries** | ❌ None | ✅ Any npm package | Medium |
| **Security** | ✅ Server-side | ⚠️ XSS risks | High |

#### Decision Tree

```
START: What do I need to build?
│
├─ Do I need charts, graphs, or data visualizations?
│  ├─ YES → Custom UI (UI Kit can't do this)
│  └─ NO → Continue ↓
│
├─ Do I need drag-and-drop, animations, or complex interactions?
│  ├─ YES → Custom UI (UI Kit too limited)
│  └─ NO → Continue ↓
│
├─ Do I need to use external libraries (e.g., date pickers, rich editors)?
│  ├─ YES → Custom UI (UI Kit doesn't support)
│  └─ NO → Continue ↓
│
├─ Is time-to-market critical (launch in <1 week)?
│  ├─ YES → UI Kit (2-3x faster development)
│  └─ NO → Continue ↓
│
├─ Does my team lack React/frontend expertise?
│  ├─ YES → UI Kit (easier to learn)
│  └─ NO → Continue ↓
│
├─ Will requirements grow significantly (complex features planned)?
│  ├─ YES → Custom UI (easier to evolve)
│  └─ NO → Continue ↓
│
└─ DEFAULT → UI Kit (simpler is better when both work)
```

#### Quick Reference: When to Use Each

**Use UI Kit when**:
- ✅ Displaying simple data (text, numbers, lists)
- ✅ Standard CRUD operations
- ✅ MVP or proof-of-concept
- ✅ Team lacks frontend expertise
- ✅ Performance is critical
- ✅ Requirements are stable and simple

**Use Custom UI when**:
- ✅ Building dashboards with charts
- ✅ Complex forms with rich validation
- ✅ Interactive features (drag-drop, real-time updates)
- ✅ Need specific npm libraries
- ✅ Branding requires custom styling
- ✅ Requirements will grow over time

#### Hybrid Approach

You can also **start with UI Kit** and **migrate to Custom UI later**:

1. **Phase 1**: UI Kit MVP (1 week)
2. **Phase 2**: Validate with users
3. **Phase 3**: Migrate to Custom UI if needed (2-3 weeks)

**Migration effort**: ~60% of original Custom UI development time

---

### Decision 2: Data Source Strategy

| Option | Best For | Considerations |
|--------|----------|----------------|
| **Forge Storage** | App-specific data | 250KB per entity limit |
| **Jira API** | Issue/project data | Rate limits apply |
| **External API** | Third-party integration | 25s timeout constraint |
| **Hybrid** | Complex requirements | Combine strategically |

### Decision 3: Refresh Strategy

| Strategy | Use Case | Implementation |
|----------|----------|----------------|
| **Static** | Data doesn't change during view | Simple render |
| **Manual Refresh** | User-triggered updates | Button + reload |
| **Auto Refresh** | Real-time updates | `useEffect` + interval |
| **Webhook** | External events | Forge events + storage |

## Manifest Configuration

### Basic Issue Panel (UI Kit)

\`\`\`yaml
modules:
  jira:issuePanel:
    - key: my-issue-panel
      title: My Issue Panel
      description: Display custom information about this issue
      icon: https://example.com/icon.png
      resolver:
        function: panel-resolver
      viewportSize: medium  # small | medium | large | xlarge

function:
  - key: panel-resolver
    handler: index.run

permissions:
  scopes:
    - read:jira-work  # Minimum scope for issue data
\`\`\`

### Advanced Issue Panel (Custom UI)

\`\`\`yaml
modules:
  jira:issuePanel:
    - key: my-custom-panel
      title: My Custom Panel
      icon: https://example.com/icon.png
      resource: main
      resolver:
        function: panel-resolver
      render: native  # Required for Custom UI
      viewportSize: xlarge

function:
  - key: panel-resolver
    handler: index.run

resources:
  - key: main
    path: static/hello-world/build

permissions:
  scopes:
    - read:jira-work
    - storage:app  # If using Forge Storage
\`\`\`

## Implementation Patterns

### Pattern 1: Simple Data Display (UI Kit)

**Use Case**: Show issue metadata or derived information

\`\`\`typescript
import ForgeUI, { render, Fragment, Text, Strong, useProductContext } from '@forge/ui';
import api, { route } from '@forge/api';

const App = () => {
  const context = useProductContext();
  const issueKey = context.platformContext.issueKey;

  // Fetch issue data
  const [issue, setIssue] = useState(async () => {
    const response = await api.asUser().requestJira(
      route\`/rest/api/3/issue/\${issueKey}\`
    );
    return await response.json();
  });

  return (
    <Fragment>
      <Strong>Issue Summary:</Strong>
      <Text>{issue.fields.summary}</Text>
      <Text>Created: {new Date(issue.fields.created).toLocaleDateString()}</Text>
    </Fragment>
  );
};

export const run = render(<App />);
\`\`\`

### Pattern 2: External API Integration (UI Kit)

**Use Case**: Display data from external service (GitHub, deployment status, etc.)

\`\`\`typescript
import ForgeUI, { render, Fragment, Text, Strong, Link, useProductContext, useState, useEffect } from '@forge/ui';
import api, { fetch } from '@forge/api';

const App = () => {
  const context = useProductContext();
  const issueKey = context.platformContext.issueKey;
  const [prData, setPrData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(async () => {
    // Get custom field from issue (e.g., GitHub PR URL)
    const issue = await getIssue(issueKey);
    const prUrl = issue.fields.customfield_10001; // GitHub PR URL

    if (prUrl) {
      // Fetch PR data from GitHub API
      const response = await fetch(prUrl, {
        headers: {
          'Authorization': \`token \${process.env.GITHUB_TOKEN}\`,
          'Accept': 'application/vnd.github.v3+json'
        }
      });
      
      const data = await response.json();
      setPrData(data);
    }
    
    setLoading(false);
  }, [issueKey]);

  if (loading) return <Text>Loading PR status...</Text>;
  if (!prData) return <Text>No PR linked to this issue</Text>;

  return (
    <Fragment>
      <Strong>Pull Request:</Strong>
      <Link href={prData.html_url}>{prData.title}</Link>
      <Text>Status: {prData.state}</Text>
      <Text>+{prData.additions} -{prData.deletions}</Text>
    </Fragment>
  );
};

async function getIssue(issueKey: string) {
  const response = await api.asUser().requestJira(
    route\`/rest/api/3/issue/\${issueKey}\`
  );
  return await response.json();
}

export const run = render(<App />);
\`\`\`

### Pattern 3: Interactive Actions (UI Kit)

**Use Case**: Perform actions on issue or external systems

\`\`\`typescript
import ForgeUI, { 
  render, 
  Fragment, 
  Text, 
  Button, 
  useProductContext, 
  useState 
} from '@forge/ui';
import api, { route, fetch } from '@forge/api';

const App = () => {
  const context = useProductContext();
  const issueKey = context.platformContext.issueKey;
  const [status, setStatus] = useState('Ready to deploy');
  const [deploying, setDeploying] = useState(false);

  const handleDeploy = async () => {
    setDeploying(true);
    setStatus('Deploying...');

    try {
      // Call external deployment API
      await fetch('https://api.example.com/deploy', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ issueKey })
      });

      // Update issue with deployment info
      await api.asUser().requestJira(
        route\`/rest/api/3/issue/\${issueKey}\`,
        {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            fields: {
              customfield_10002: 'Deployed'
            }
          })
        }
      );

      setStatus('Deployed successfully!');
    } catch (error) {
      setStatus(\`Error: \${error.message}\`);
    } finally {
      setDeploying(false);
    }
  };

  return (
    <Fragment>
      <Text>Deployment Status: {status}</Text>
      <Button 
        text="Deploy to Production" 
        onClick={handleDeploy}
        disabled={deploying}
      />
    </Fragment>
  );
};

export const run = render(<App />);
\`\`\`

### Pattern 4: Forge Storage for Caching (UI Kit)

**Use Case**: Cache expensive API calls or store app-specific data

\`\`\`typescript
import ForgeUI, { render, Fragment, Text, Button, useProductContext, useState } from '@forge/ui';
import { storage } from '@forge/api';

const App = () => {
  const context = useProductContext();
  const issueKey = context.platformContext.issueKey;
  
  const [analysisResult, setAnalysisResult] = useState(async () => {
    // Try to get from storage first
    const cached = await storage.get(\`analysis-\${issueKey}\`);
    if (cached) return cached;

    // If not cached, compute (expensive operation)
    const result = await performExpensiveAnalysis(issueKey);
    
    // Cache for 1 hour
    await storage.set(\`analysis-\${issueKey}\`, result);
    
    return result;
  });

  const refreshAnalysis = async () => {
    const result = await performExpensiveAnalysis(issueKey);
    await storage.set(\`analysis-\${issueKey}\`, result);
    setAnalysisResult(result);
  };

  return (
    <Fragment>
      <Text>Risk Score: {analysisResult.riskScore}/10</Text>
      <Text>Confidence: {analysisResult.confidence}%</Text>
      <Button text="Refresh Analysis" onClick={refreshAnalysis} />
    </Fragment>
  );
};

async function performExpensiveAnalysis(issueKey: string) {
  // Simulate expensive analysis
  return {
    riskScore: 7,
    confidence: 85,
    analyzedAt: new Date().toISOString()
  };
}

export const run = render(<App />);
\`\`\`

### Pattern 5: Custom UI with React

**Use Case**: Complex visualizations, charts, or advanced interactions

\`\`\`typescript
// index.tsx (Forge function - bridge)
import Resolver from '@forge/resolver';
import api, { route } from '@forge/api';

const resolver = new Resolver();

resolver.define('getData', async (req) => {
  const issueKey = req.context.extension.issue.key;
  
  const response = await api.asUser().requestJira(
    route\`/rest/api/3/issue/\${issueKey}\`
  );
  
  return await response.json();
});

export const handler = resolver.getDefinitions();
\`\`\`

\`\`\`typescript
// App.tsx (React component)
import React, { useEffect, useState } from 'react';
import { invoke } from '@forge/bridge';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip } from 'recharts';

function App() {
  const [issue, setIssue] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    invoke('getData').then((data) => {
      setIssue(data);
      setLoading(false);
    });
  }, []);

  if (loading) return <div>Loading...</div>;

  // Transform issue history into chart data
  const chartData = issue.changelog.histories.map((h) => ({
    date: h.created,
    changes: h.items.length
  }));

  return (
    <div>
      <h2>{issue.fields.summary}</h2>
      <LineChart width={600} height={300} data={chartData}>
        <CartesianGrid strokeDasharray="3 3" />
        <XAxis dataKey="date" />
        <YAxis />
        <Tooltip />
        <Line type="monotone" dataKey="changes" stroke="#8884d8" />
      </LineChart>
    </div>
  );
}

export default App;
\`\`\`

## Performance Considerations

### Viewport Size Impact

| Size | Dimensions | Best For | Performance |
|------|-----------|----------|-------------|
| `small` | ~300px | Simple text/status | ⚡️ Fastest |
| `medium` | ~600px | Standard panels | ⚡️ Fast |
| `large` | ~900px | Rich content | ⚠️ Moderate |
| `xlarge` | ~1200px | Dashboards | ⚠️ Can be slow |

**Tip**: Start with `medium` and only increase if necessary.

### Optimization Strategies

1. **Lazy Load**: Use `useState(async () => ...)` for initial data
2. **Cache**: Store expensive computations in Forge Storage
3. **Debounce**: Limit refresh rate for auto-updating panels
4. **Pagination**: Don't load all data at once
5. **Minimize API Calls**: Batch requests when possible

### 25-Second Timeout

Forge functions have a 25-second execution limit. For long-running tasks:

\`\`\`typescript
// ❌ BAD: Synchronous long operation
const data = await veryLongOperation(); // Could timeout

// ✅ GOOD: Use async events
import { events } from '@forge/api';

// Trigger async job
await events.trigger('long-operation', { issueKey });

// Job runs in background via scheduled function
export async function scheduledLongOperation(event) {
  const result = await veryLongOperation();
  await storage.set(\`result-\${event.payload.issueKey}\`, result);
}
\`\`\`

## Security Best Practices

### Scope Minimization

Only request scopes you actually need:

\`\`\`yaml
permissions:
  scopes:
    # ✅ Minimal scopes
    - read:jira-work          # Read issue data
    
    # ⚠️ Add only if needed
    - write:jira-work         # Modify issues
    - storage:app             # Use Forge Storage
    
    # ❌ Avoid if possible
    - read:jira-user          # User data (PII concerns)
    - manage:jira-project     # Admin capabilities
\`\`\`

### Data Protection

\`\`\`typescript
// ❌ BAD: Exposing sensitive data
console.log('API Key:', process.env.SECRET_API_KEY);

// ✅ GOOD: Use environment variables securely
const response = await fetch('https://api.example.com/data', {
  headers: {
    'Authorization': \`Bearer \${process.env.API_KEY}\`
  }
});
// API key never leaves backend
\`\`\`

### User Context

Always use `api.asUser()` for user-specific data:

\`\`\`typescript
// ✅ User sees only what they have permission to see
const response = await api.asUser().requestJira(route\`/rest/api/3/issue/\${issueKey}\`);

// ❌ App-level access (use carefully)
const response = await api.asApp().requestJira(route\`/rest/api/3/issue/\${issueKey}\`);
\`\`\`

## Testing Strategies

### Unit Tests

\`\`\`typescript
// __tests__/panel.test.ts
import { render, screen } from '@testing-library/react';
import { App } from '../src/App';

jest.mock('@forge/bridge', () => ({
  invoke: jest.fn().mockResolvedValue({
    fields: {
      summary: 'Test Issue',
      created: '2025-01-01T00:00:00Z'
    }
  })
}));

describe('Issue Panel', () => {
  it('displays issue summary', async () => {
    render(<App />);
    expect(await screen.findByText('Test Issue')).toBeInTheDocument();
  });
});
\`\`\`

### Integration Tests

\`\`\`typescript
// Use Forge CLI tunnel for live testing
// forge tunnel --upgrade

describe('Issue Panel Integration', () => {
  it('fetches real issue data', async () => {
    const issueKey = 'PROJ-123';
    const response = await api.asUser().requestJira(
      route\`/rest/api/3/issue/\${issueKey}\`
    );
    
    expect(response.status).toBe(200);
    const issue = await response.json();
    expect(issue.key).toBe(issueKey);
  });
});
\`\`\`

## Common Pitfalls

### ❌ Pitfall 1: Not Handling Loading States

\`\`\`typescript
// Bad: No loading indicator
const [data] = useState(async () => await fetchData());
return <Text>{data.value}</Text>; // Error if data not loaded
\`\`\`

\`\`\`typescript
// Good: Handle loading
const [data, setData] = useState(null);
useEffect(async () => {
  const result = await fetchData();
  setData(result);
}, []);

if (!data) return <Text>Loading...</Text>;
return <Text>{data.value}</Text>;
\`\`\`

### ❌ Pitfall 2: Ignoring Rate Limits

\`\`\`typescript
// Bad: Could hit rate limits
for (const issue of issues) {
  await api.asUser().requestJira(route\`/rest/api/3/issue/\${issue.key}\`);
}
\`\`\`

\`\`\`typescript
// Good: Batch requests
const response = await api.asUser().requestJira(
  route\`/rest/api/3/search?jql=key in (\${issueKeys.join(',')})\`
);
\`\`\`

### ❌ Pitfall 3: Not Considering Mobile

Issue panels should work on mobile:

- Use responsive viewport sizes
- Avoid horizontal scrolling
- Test on narrow screens
- Use appropriate font sizes

## Troubleshooting

### Panel Not Appearing

1. Check manifest syntax
2. Verify app is installed on the Jira site
3. Check browser console for errors
4. Ensure permissions are granted

### Slow Loading

1. Check network tab for slow API calls
2. Add loading indicators
3. Consider caching with Forge Storage
4. Reduce data fetched on initial load

### Permission Errors

1. Verify scopes in manifest match API calls
2. Check if user has permission to view issue
3. Use `api.asUser()` instead of `api.asApp()`

## References

- [Forge Issue Panel Documentation](https://developer.atlassian.com/platform/forge/manifest-reference/modules/jira-issue-panel/)
- [Jira REST API](https://developer.atlassian.com/cloud/jira/platform/rest/v3/)
- [Forge Storage API](https://developer.atlassian.com/platform/forge/runtime-reference/storage-api/)
- [UI Kit Components](https://developer.atlassian.com/platform/forge/ui-kit/)

---

**Next Steps**:
1. Review this template during ARCHITECT stage
2. Choose UI approach based on requirements
3. Reference appropriate patterns during IMPLEMENT stage
4. Use testing strategies during TEST stage
