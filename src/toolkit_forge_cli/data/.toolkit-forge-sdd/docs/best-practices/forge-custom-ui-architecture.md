# Forge Custom UI Architecture Guide

> **Complete guide for building Atlassian Forge apps with Custom UI, React, Vite, and TypeScript**  
> **Part of the forge-sdd-toolkit project**

**Version**: 1.0  
**Last Updated**: 2025-01-07  
**Compatibility**: Forge CLI 10+, Node.js 20.x, React 18+, Vite 5+  
**Source**: [Atlassian Forge Documentation](https://developer.atlassian.com/platform/forge/)

---

## 📚 Table of Contents

1. [Architecture Principles](#architecture-principles)
2. [Directory Structure](#directory-structure)
3. [Essential Configurations](#essential-configurations)
4. [Backend (Resolvers)](#backend-resolvers)
5. [Frontend (Custom UI)](#frontend-custom-ui)
6. [Manifest Configuration](#manifest-configuration)
7. [Development Workflows](#development-workflows)
8. [Anti-Patterns](#anti-patterns)
9. [Troubleshooting](#troubleshooting)
10. [References](#references)

---

## Architecture Principles

### Core Concepts

1. **Complete Separation**: Backend (`src/`) and Frontend (`static/`) are completely independent
2. **Independent Compilation**: Backend compiled by Forge CLI, frontend by Vite
3. **Relative Paths**: ALWAYS use relative paths for assets in frontend
4. **Isolated Dependencies**: Backend and frontend have separate package.json files

### Forge Custom UI Architecture

```
┌─────────────────────────────────────────────┐
│     Atlassian Product (Jira/Confluence)     │
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │     Custom UI (React in iframe)       │ │
│  │     - Rendered in secure iframe       │ │
│  │     - Uses @forge/bridge API          │ │
│  │     - Assets served by Forge CDN      │ │
│  └───────────────┬───────────────────────┘ │
│                  │                          │
│                  │ invoke(resolverName)     │
│                  ▼                          │
│  ┌───────────────────────────────────────┐ │
│  │  Resolvers (Node.js Functions)        │ │
│  │     - Executes on Forge backend       │ │
│  │     - Accesses Atlassian APIs         │ │
│  │     - Processes business logic        │ │
│  └───────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

### Data Flow

```
Frontend (React)
    │
    │ invoke('resolverName', { data })
    ▼
@forge/bridge
    │
    │ HTTP Request to Forge Backend
    ▼
Backend (Resolver Function)
    │
    │ 1. Validate input
    │ 2. Call Atlassian API (if needed)
    │ 3. Process business logic
    ▼
Return { success, data?, error? }
    │
    ▼
Frontend receives response
```

---

## Directory Structure

### ✅ CORRECT Structure (Official Atlassian Pattern)

```
my-forge-app/
├── .gitignore                   # Root gitignore
├── manifest.yml                 # Forge app configuration
├── package.json                 # BACKEND dependencies only
├── tsconfig.json                # TypeScript config for BACKEND
│
├── src/                         # ✅ BACKEND: Forge code
│   ├── index.ts                 # Entry point for resolvers
│   ├── resolvers/               # Business logic functions
│   │   ├── issue.ts
│   │   ├── user.ts
│   │   └── index.ts
│   ├── services/                # External integrations
│   │   └── atlassian-api.ts
│   ├── utils/                   # Shared utilities
│   │   ├── helpers.ts
│   │   └── validators.ts
│   └── types/                   # TypeScript types for backend
│       └── index.ts
│
└── static/                      # ✅ FRONTEND: Custom UI modules
    └── my-app/                  # Module name (= resource key in manifest)
        ├── .gitignore           # Frontend-specific gitignore
        ├── package.json         # FRONTEND dependencies only
        ├── tsconfig.json        # TypeScript config for FRONTEND
        ├── vite.config.ts       # Vite configuration
        │
        ├── public/              # Static assets (copied as-is)
        │   ├── index.html       # HTML entry point
        │   ├── favicon.ico
        │   └── images/
        │
        ├── src/                 # ✅ React source code
        │   ├── main.tsx         # React entry point
        │   ├── App.tsx          # Root component
        │   ├── components/      # React components
        │   │   ├── ui/
        │   │   └── features/
        │   ├── hooks/           # Custom React hooks
        │   │   └── useIssueData.ts
        │   ├── services/        # API calls to resolvers
        │   │   └── forge-api.ts
        │   ├── types/           # TypeScript types for frontend
        │   │   └── index.ts
        │   ├── utils/           # Frontend utilities
        │   │   └── helpers.ts
        │   └── styles/          # Global styles
        │       └── index.css
        │
        └── build/               # ⚠️ Vite OUTPUT (DO NOT COMMIT)
            ├── index.html
            └── assets/
                ├── main-[hash].js
                └── main-[hash].css
```

### Why This Structure?

**Why `src/` is ONLY for backend?**
- Forge CLI automatically compiles TypeScript files in `src/`
- Mixing frontend here causes compilation conflicts
- This is the convention followed by official docs and community

**Why `static/` contains frontend?**
- Forge serves static files from `static/` via CDN
- Each subdirectory represents an independent Custom UI module
- Directory name MUST match the resource key in manifest.yml

**Why each module has its own package.json?**
- Frontend dependencies are different from backend
- Allows multiple modules with different library versions
- Prevents dependency conflicts

**Why separate tsconfig.json files?**
- Backend targets Node.js (CommonJS, ES2020)
- Frontend targets browsers (ESM, DOM, JSX)
- Different compiler options for each environment

---

## Essential Configurations

### 1. Root `.gitignore`

```gitignore
# Dependencies
node_modules/
static/*/node_modules/

# Build outputs (DO NOT COMMIT)
static/*/build/
static/*/dist/
dist/

# Logs
*.log
npm-debug.log*
forge-debug.log

# Environment variables
.env
.env.local
.env.*.local

# IDE
.vscode/*
!.vscode/extensions.json
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Forge
.forge-*
.tunnel
```

### 2. Root `package.json` (Backend)

```json
{
  "name": "my-forge-app",
  "version": "1.0.0",
  "description": "Forge app with Custom UI",
  "main": "src/index.ts",
  "scripts": {
    "build:frontend": "cd static/my-app && npm run build",
    "dev:frontend": "cd static/my-app && npm run dev",
    "tunnel": "npm run build:frontend && forge tunnel",
    "deploy:dev": "npm run build:frontend && forge deploy -e development",
    "deploy:prod": "npm run build:frontend && forge deploy -e production",
    "logs": "forge logs --follow",
    "lint": "eslint src --ext .ts",
    "test": "jest"
  },
  "dependencies": {
    "@forge/api": "^3.0.0",
    "@forge/resolver": "^1.5.0"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "typescript": "^5.3.0",
    "eslint": "^8.0.0",
    "@typescript-eslint/parser": "^6.0.0",
    "@typescript-eslint/eslint-plugin": "^6.0.0"
  },
  "engines": {
    "node": ">=20.0.0"
  }
}
```

### 3. Root `tsconfig.json` (Backend)

```json
{
  "compilerOptions": {
    // Target and Module
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    
    // Module Resolution
    "moduleResolution": "node",
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "resolveJsonModule": true,
    
    // Type Checking (strict mode)
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    
    // Output
    "outDir": "./dist",
    "rootDir": "./src",
    "sourceMap": true,
    "declaration": true,
    
    // Other
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "types": ["node"]
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "static", "dist"]
}
```

### 4. `static/my-app/package.json` (Frontend)

```json
{
  "name": "my-app-frontend",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "lint": "eslint src --ext .ts,.tsx",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "@forge/bridge": "^3.0.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "@vitejs/plugin-react": "^4.2.0",
    "typescript": "^5.3.0",
    "vite": "^5.0.0",
    "eslint": "^8.0.0",
    "eslint-plugin-react": "^7.33.0",
    "@typescript-eslint/parser": "^6.0.0",
    "@typescript-eslint/eslint-plugin": "^6.0.0"
  }
}
```

### 5. `static/my-app/tsconfig.json` (Frontend)

```json
{
  "compilerOptions": {
    // Target and Module
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "jsx": "react-jsx",
    
    // Module Resolution
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    
    // Type Checking (strict mode)
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    
    // Output
    "noEmit": true,
    "isolatedModules": true,
    
    // Other
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "types": ["vite/client"]
  },
  "include": ["src"],
  "exclude": ["node_modules", "build", "dist"]
}
```

### 6. `static/my-app/vite.config.ts` ⚠️ CRITICAL

```typescript
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { resolve } from 'path';

export default defineConfig({
  // ⚠️ REQUIRED: Use relative paths
  // Without this, assets will fail to load in Forge
  base: './',
  
  plugins: [react()],
  
  resolve: {
    alias: {
      '@': resolve(__dirname, './src'),
      '@components': resolve(__dirname, './src/components'),
      '@hooks': resolve(__dirname, './src/hooks'),
      '@services': resolve(__dirname, './src/services'),
      '@utils': resolve(__dirname, './src/utils'),
      '@types': resolve(__dirname, './src/types'),
    },
  },
  
  build: {
    outDir: 'build',
    emptyOutDir: true,
    assetsDir: 'assets',
    sourcemap: true,
    
    rollupOptions: {
      output: {
        manualChunks: {
          'react-vendor': ['react', 'react-dom'],
          'forge-vendor': ['@forge/bridge'],
        },
      },
    },
  },
  
  server: {
    port: 3000,
    strictPort: true,
    host: true,
  },
  
  preview: {
    port: 3000,
  },
});
```

### 7. `static/my-app/public/index.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My Forge App</title>
    
    <!-- Favicon -->
    <link rel="icon" type="image/svg+xml" href="./favicon.ico" />
    
    <!-- Optional: Atlassian Design Tokens -->
    <link
      rel="stylesheet"
      href="https://unpkg.com/@atlaskit/css-reset@6.6.1/dist/bundle.css"
    />
  </head>
  <body>
    <div id="root"></div>
    
    <!-- ⚠️ REQUIRED: Relative path to script -->
    <script type="module" src="../src/main.tsx"></script>
  </body>
</html>
```

---

## Backend (Resolvers)

### Entry Point: `src/index.ts`

```typescript
import Resolver from '@forge/resolver';
import { getIssueData } from './resolvers/issue';
import { getUserData } from './resolvers/user';
import { updateIssueField } from './resolvers/issue';

const resolver = new Resolver();

// Register resolvers
resolver.define('getIssueData', getIssueData);
resolver.define('getUserData', getUserData);
resolver.define('updateIssueField', updateIssueField);

// Export handler for Forge
export const handler = resolver.getDefinitions();
```

### Resolver Example: `src/resolvers/issue.ts`

```typescript
import api, { route } from '@forge/api';
import type { ResolverRequest, ResolverResponse } from '../types';

/**
 * Fetches issue data from Jira
 */
export async function getIssueData(
  req: ResolverRequest<{ issueKey: string }>
): Promise<ResolverResponse> {
  try {
    const { issueKey } = req.payload;
    
    // Validation
    if (!issueKey) {
      return {
        success: false,
        error: 'issueKey is required',
      };
    }
    
    // Call Atlassian API
    const response = await api.asApp().requestJira(
      route`/rest/api/3/issue/${issueKey}`
    );
    
    if (!response.ok) {
      throw new Error(`API returned status ${response.status}`);
    }
    
    const issue = await response.json();
    
    return {
      success: true,
      data: {
        key: issue.key,
        summary: issue.fields.summary,
        status: issue.fields.status.name,
        assignee: issue.fields.assignee?.displayName || 'Unassigned',
      },
    };
  } catch (error) {
    console.error('Error fetching issue:', error);
    
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error',
    };
  }
}
```

### Type Definitions: `src/types/index.ts`

```typescript
/**
 * Resolver types
 */
export interface ResolverRequest<T = any> {
  payload: T;
  context: {
    accountId?: string;
    localId?: string;
    cloudId?: string;
    moduleKey?: string;
  };
}

export interface ResolverResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
}

/**
 * Domain types
 */
export interface JiraIssue {
  key: string;
  summary: string;
  status: string;
  assignee: string | null;
}
```

---

## Frontend (Custom UI)

### React Entry Point: `static/my-app/src/main.tsx`

```typescript
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import './styles/index.css';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
```

### Root Component: `static/my-app/src/App.tsx`

```typescript
import { useEffect, useState } from 'react';
import { invoke, view } from '@forge/bridge';

interface Issue {
  key: string;
  summary: string;
  status: string;
  assignee: string;
}

function App() {
  const [issue, setIssue] = useState<Issue | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  
  useEffect(() => {
    loadIssueData();
  }, []);
  
  async function loadIssueData() {
    try {
      setLoading(true);
      
      // Get context from Forge
      const context = await view.getContext();
      const issueKey = context.extension.issue.key;
      
      // Call resolver
      const response = await invoke<{
        success: boolean;
        data?: Issue;
        error?: string;
      }>('getIssueData', { issueKey });
      
      if (response.success && response.data) {
        setIssue(response.data);
      } else {
        setError(response.error || 'Unknown error');
      }
    } catch (err) {
      console.error('Error loading issue:', err);
      setError('Failed to load data');
    } finally {
      setLoading(false);
    }
  }
  
  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;
  if (!issue) return <div>No data found</div>;
  
  return (
    <div className="app">
      <h1>{issue.summary}</h1>
      <p>Key: {issue.key}</p>
      <p>Status: {issue.status}</p>
      <p>Assignee: {issue.assignee}</p>
    </div>
  );
}

export default App;
```

### Service Layer: `static/my-app/src/services/forge-api.ts`

```typescript
import { invoke } from '@forge/bridge';

/**
 * Typed wrapper for Forge invoke calls
 */
class ForgeAPI {
  async getIssueData(issueKey: string) {
    const response = await invoke<{
      success: boolean;
      data?: {
        key: string;
        summary: string;
        status: string;
        assignee: string;
      };
      error?: string;
    }>('getIssueData', { issueKey });
    
    if (!response.success) {
      throw new Error(response.error || 'Error fetching issue');
    }
    
    return response.data!;
  }
}

export const forgeAPI = new ForgeAPI();
```

### Custom Hook: `static/my-app/src/hooks/useIssueData.ts`

```typescript
import { useState, useEffect } from 'react';
import { view } from '@forge/bridge';
import { forgeAPI } from '@services/forge-api';

interface Issue {
  key: string;
  summary: string;
  status: string;
  assignee: string;
}

export function useIssueData() {
  const [issue, setIssue] = useState<Issue | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  
  useEffect(() => {
    loadData();
  }, []);
  
  async function loadData() {
    try {
      setLoading(true);
      setError(null);
      
      const context = await view.getContext();
      const issueKey = context.extension.issue.key;
      
      const data = await forgeAPI.getIssueData(issueKey);
      setIssue(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  }
  
  return { issue, loading, error, refresh: loadData };
}
```

---

## Manifest Configuration

### Complete Example: `manifest.yml`

```yaml
# App metadata
app:
  id: ari:cloud:ecosystem::app/[app-id]
  runtime:
    name: nodejs20.x
  egress:
    - '*.example.com'

# Custom UI modules
modules:
  # Jira Issue Panel
  jira:issuePanel:
    - key: my-issue-panel
      resource: main-ui
      resolver:
        function: resolver
      title: My Panel
      icon: https://example.com/icon.png

  # Jira Admin Page
  jira:adminPage:
    - key: my-admin-page
      resource: admin-ui
      resolver:
        function: resolver
      title: Administration

# Functions (Resolvers)
function:
  - key: resolver
    handler: index.handler

# Resources (Custom UI)
resources:
  # Main UI
  - key: main-ui
    path: static/my-app/build
  
  # Admin UI
  - key: admin-ui
    path: static/admin-panel/build

# Permissions
permissions:
  scopes:
    - read:jira-work
    - write:jira-work
    - read:jira-user
  external:
    images:
      - '*.atlassian.com'
    fetch:
      backend:
        - 'api.example.com'
```

---

## Development Workflows

### Initial Setup

```bash
# 1. Create Forge app
forge create
cd my-forge-app

# 2. Create directory structure
mkdir -p src/resolvers src/services src/utils src/types
mkdir -p static/my-app/{src,public,build}

# 3. Install backend dependencies
npm install @forge/api @forge/resolver
npm install -D @types/node typescript

# 4. Setup frontend
cd static/my-app
npm init -y
npm install react react-dom @forge/bridge
npm install -D vite @vitejs/plugin-react typescript
npm install -D @types/react @types/react-dom

# 5. Create config files (tsconfig, vite.config, etc)

# 6. Initial deploy
cd ../..
forge deploy

# 7. Install on development site
forge install
```

### Development Workflow

**Terminal 1: Frontend Dev Server**
```bash
cd static/my-app
npm run dev
# Vite runs on http://localhost:3000
# Hot reload enabled
```

**Terminal 2: Forge Tunnel**
```bash
# At project root
forge tunnel
# Connects to local dev server
# Enables backend hot reload
```

### Build and Deploy

```bash
# Build frontend
cd static/my-app
npm run build

# Verify build
ls -la build/

# Deploy to development
cd ../..
forge deploy --environment development

# Deploy to production
forge deploy --environment production
```

---

## Anti-Patterns

### ❌ 1. Frontend in `src/frontend/`

**WRONG:**
```
src/
├── index.ts
├── resolvers/
└── frontend/      # ❌ Don't put frontend here!
    ├── App.tsx
    └── ...
```

**Problem**: Forge CLI tries to compile as backend code.

**Solution**: Frontend ALWAYS in `static/`.

### ❌ 2. Absolute Paths

**WRONG:**
```tsx
<img src="/assets/logo.png" />
<link href="/styles/main.css" />
```

**CORRECT:**
```tsx
import logo from './assets/logo.png';
<img src={logo} />
```

### ❌ 3. Missing `base: './'` in Vite

**WRONG:**
```typescript
export default defineConfig({
  // base not configured
});
```

**CORRECT:**
```typescript
export default defineConfig({
  base: './',  // REQUIRED!
});
```

### ❌ 4. Committing `build/` Directory

**Problem**: Build artifacts in git cause conflicts.

**Solution**: Add to `.gitignore`:
```gitignore
static/*/build/
```

### ❌ 5. Exposing Secrets in Frontend

**WRONG:**
```typescript
const API_KEY = 'secret123';  // Visible in bundle!
```

**CORRECT:**
```typescript
// Use resolver as proxy
async function getData() {
  return await invoke('getDataFromAPI');
}
```

---

## Troubleshooting

### Blank Page After Deploy

**Symptoms**: App loads but renders nothing.

**Common causes**:
1. Missing `base: './'` in vite.config.ts
2. Absolute paths in assets
3. Incorrect manifest.yml path

**Solution**:
```typescript
// vite.config.ts
export default defineConfig({
  base: './',  // Add this
});
```

### 403 Forbidden on Assets

**Symptoms**: Console shows 403 errors loading JS/CSS.

**Cause**: Absolute paths generated by Vite.

**Solution**: Verify `base: './'` in vite.config.ts.

### "Custom UI resource must be a directory"

**Symptoms**: Deploy fails with this error.

**Cause**: manifest.yml path points to file instead of directory.

**Solution**:
```yaml
# ❌ WRONG
resources:
  - key: main-ui
    path: static/my-app/build/index.html

# ✅ CORRECT
resources:
  - key: main-ui
    path: static/my-app/build
```

### invoke() Returns Undefined

**Checklist**:
- [ ] Resolver registered in src/index.ts?
- [ ] Resolver name matches invoke() call?
- [ ] Handler exported correctly?
- [ ] Resolver returns correct object format?

**Correct pattern**:
```typescript
// Backend
resolver.define('myResolver', myResolverFunction);
export const handler = resolver.getDefinitions();

// Frontend
await invoke('myResolver', { data });
```

---

## References

### Official Documentation

- **Forge Platform**: https://developer.atlassian.com/platform/forge/
- **Custom UI**: https://developer.atlassian.com/platform/forge/custom-ui/
- **Manifest Reference**: https://developer.atlassian.com/platform/forge/manifest-reference/
- **Bridge API**: https://developer.atlassian.com/platform/forge/runtime-reference/ui-bridge/
- **CLI Reference**: https://developer.atlassian.com/platform/forge/cli-reference/

### Community

- **Developer Community**: https://community.developer.atlassian.com/
- **Forge Tag**: Use tag `forge` or `custom-ui`

### Useful Libraries

- **@atlaskit/**: Atlassian Design System components
  - https://atlassian.design/components

### forge-sdd-toolkit Resources

- [forge-architect.prompt.md](../../../.github/prompts/forge-architect.prompt.md) - Architecture decisions
- [forge-implement.prompt.md](../../../.github/prompts/forge-implement.prompt.md) - Implementation guide
- [vite-config-template.md](../../structure/templates/configs/vite-config-template.md) - Vite template
- [gitignore-template.md](../../structure/templates/configs/gitignore-template.md) - Gitignore template

---

## Final Checklist

Before deploying your Forge app:

### Structure
- [ ] Backend in `src/`, frontend in `static/`
- [ ] Each Custom UI module has own package.json
- [ ] Build outputs in `.gitignore`
- [ ] Relative paths for all assets

### Configuration
- [ ] `base: './'` in vite.config.ts
- [ ] Separate tsconfig.json files (correct settings)
- [ ] manifest.yml paths point to directories
- [ ] Resource keys match directory names

### Code Quality
- [ ] Resolvers validate input
- [ ] Error handling in all resolvers
- [ ] Frontend uses invoke() for communication
- [ ] No secrets exposed in frontend
- [ ] Adequate logging for debugging

### Testing
- [ ] Frontend builds without errors
- [ ] Deploy works in development
- [ ] App renders correctly
- [ ] All features tested
- [ ] README documentation updated

---

## Conclusion

This guide provides the complete architecture and best practices for developing Atlassian Forge apps with Custom UI using React, Vite, and TypeScript.

**Key takeaways:**

1. **Separation is fundamental**: Backend (src/) and Frontend (static/) are separate worlds
2. **Relative paths always**: Use `base: './'` and correct imports
3. **Isolated dependencies**: Each module has its own package.json
4. **Strict validation**: Always validate input in resolvers
5. **Follow the patterns**: Use the official structure, don't invent

For specific questions, consult the [official documentation](https://developer.atlassian.com/platform/forge/) or the [developer community](https://community.developer.atlassian.com/).

**Good luck with your Forge app! 🚀**
