# 🏗️ Forge Project Setup - Best Practices

> **CRITICAL**: Always use official Forge templates. Never create structure manually.

---

## 🎯 Why Use Templates?

### ✅ Official Templates Provide

1. **Correct Structure**: Pre-configured for each module type
2. **Working Examples**: Sample code showing best practices
3. **Build Configuration**: Webpack, TypeScript, etc. pre-configured
4. **Manifest Boilerplate**: Valid YAML with all required fields
5. **Testing Setup**: Jest configuration and sample tests
6. **Type Definitions**: TypeScript types for Forge APIs
7. **Development Scripts**: npm scripts for dev, build, deploy

### ❌ Manual Setup Risks

- Missing required files (`manifest.yml`, `package.json`)
- Incorrect directory structure (Forge won't find modules)
- Invalid manifest format (deployment fails)
- No build pipeline (can't bundle Custom UI)
- No type safety (TypeScript not configured)
- Inconsistent with community standards

---

## 📚 Available Templates

### Quick Reference

```bash
# List all available templates
forge create --help

# Interactive mode (recommended for beginners)
forge create

# Direct template selection
forge create --template <template-name> <app-name>
```

### Template Catalog

#### Jira Templates

| Template | Module Type | UI Approach | Use When |
|----------|-------------|-------------|----------|
| `jira-issue-panel` | Issue Panel | UI Kit | Simple panels, read-only views |
| `jira-issue-panel-ui-kit-custom-ui` | Issue Panel | Custom UI (React) | Rich interactions, forms, complex UI |
| `jira-custom-field` | Custom Field | UI Kit | Custom field types |
| `jira-dashboard-gadget` | Dashboard Gadget | UI Kit | Configurable widgets |
| `jira-global-page` | Global Page | Custom UI | Admin settings, reports |
| `jira-project-page` | Project Page | Custom UI | Project-level features |

#### Confluence Templates

| Template | Module Type | UI Approach | Use When |
|----------|-------------|-------------|----------|
| `confluence-hello-world` | Macro | UI Kit | Content macros, simple embeds |
| `confluence-custom-ui` | Various | Custom UI | Rich content, interactive pages |

#### Bitbucket Templates

| Template | Module Type | Use When |
|----------|-------------|----------|
| `bitbucket-hello-world` | Various | Repository hooks, PR checks |

#### Multi-Product Templates

| Template | Products | Use When |
|----------|----------|----------|
| `forge-ui` | Any | Starting point for UI Kit apps |
| `forge-custom-ui` | Any | Starting point for Custom UI apps |

---

## 🚀 Recommended Workflow

### 1. Review Architecture Decision Document (ADD)

Before creating project, check ADD for:
- **Module Type** (Issue Panel, Macro, etc.)
- **UI Approach** (UI Kit vs Custom UI)
- **Additional Requirements** (APIs, storage, etc.)

### 2. Select Template from Decision Matrix

Use this decision tree:

```
Is it Jira?
├─ Yes → Which module?
│  ├─ Issue Panel
│  │  ├─ Simple UI? → jira-issue-panel
│  │  └─ Rich UI? → jira-issue-panel-ui-kit-custom-ui
│  ├─ Custom Field → jira-custom-field
│  ├─ Dashboard → jira-dashboard-gadget
│  └─ Global Page → jira-global-page
│
├─ Is it Confluence?
│  ├─ Macro → confluence-hello-world
│  └─ Page/Custom → confluence-custom-ui
│
└─ Is it Bitbucket?
   └─ Any → bitbucket-hello-world
```

### 3. Create Project from Template

```bash
# Example: Jira Issue Panel with Custom UI
forge create --template jira-issue-panel-ui-kit-custom-ui my-awesome-app

# Output:
# ✔ Creating Forge app...
# ✔ Installing dependencies...
# ✔ Project created successfully!

cd my-awesome-app
```

### 4. Verify Template Structure

Expected structure (example for Custom UI):

```
my-awesome-app/
├── manifest.yml           # ✅ Pre-configured
├── package.json          # ✅ Dependencies included
├── src/
│   ├── index.jsx         # ✅ Sample resolver
│   └── frontend/         # ✅ React app
│       ├── index.jsx
│       └── App.jsx
├── static/               # ✅ Custom UI resources
│   └── hello-world/
│       └── index.html
└── README.md             # ✅ Template documentation
```

### 5. Customize Per ADD

Now customize the template to match your ADD:

#### A. Update `manifest.yml`

```yaml
# Original (from template)
modules:
  jira:issuePanel:
    - key: my-awesome-app-hello-world-panel
      function: main
      title: Hello World

# Customized (per ADD)
modules:
  jira:issuePanel:
    - key: pr-status-panel
      function: main
      title: Pull Request Status
      icon: https://example.com/icon.png  # From ADD Design
```

#### B. Add Permissions (from ADD Decision #5)

```yaml
permissions:
  scopes:
    - read:jira-work          # REQ-F-001
    - storage:app             # REQ-NFR-001
  external:
    fetch:
      backend:
        - 'https://api.github.com/*'  # REQ-F-002
```

#### C. Install Additional Dependencies (from ADD)

```bash
# If ADD specifies charting
npm install chart.js

# If ADD specifies date handling
npm install date-fns

# If ADD specifies HTTP client
npm install axios

# Always install dev dependencies
npm install --save-dev @forge/cli-tests jest
```

### 6. Implement Features

Now you have a solid foundation. Implement per Implementation Plan:
- Replace sample code with real logic
- Add API calls per ADD
- Build UI components
- Add error handling
- Write tests

---

## 📖 Template Customization Patterns

### Pattern 1: Adding New Modules

Template provides one module, but you need multiple:

```yaml
# Template has:
modules:
  jira:issuePanel:
    - key: panel-1

# Add more:
modules:
  jira:issuePanel:
    - key: panel-1
    - key: panel-2       # Add another panel
  jira:dashboardGadget:  # Add different module type
    - key: gadget-1
```

### Pattern 2: Reorganizing File Structure

Template structure is basic. For complex apps, reorganize:

```bash
# Template structure:
src/
├── index.jsx
└── frontend/
    └── App.jsx

# Reorganize to:
src/
├── resolvers/
│   ├── panel.js
│   └── gadget.js
├── services/
│   ├── github.js
│   └── cache.js
├── frontend/
│   ├── components/
│   ├── hooks/
│   └── utils/
└── types/
    └── index.d.ts

# Update manifest.yml function paths accordingly
```

### Pattern 3: Custom UI Build Configuration

Template uses basic webpack config. Customize for needs:

```javascript
// Create webpack.config.js
module.exports = {
  // Add custom loaders
  // Add optimizations
  // Add source maps for debugging
};
```

---

## 🔧 Common Template Issues & Solutions

### Issue 1: Template Outdated

**Problem**: Template uses old Forge APIs

**Solution**:
```bash
# Update Forge dependencies
npm update @forge/api @forge/ui @forge/resolver

# Check for breaking changes
npm run build
```

### Issue 2: Missing Type Definitions

**Problem**: TypeScript complains about Forge types

**Solution**:
```bash
npm install --save-dev @types/node
npm install --save-dev @forge/api
```

Add to `tsconfig.json`:
```json
{
  "compilerOptions": {
    "types": ["node", "@forge/api"]
  }
}
```

### Issue 3: Template Too Basic

**Problem**: Need more sophisticated structure

**Solution**: Keep template as starting point, then:
1. Identify reusable patterns in your codebase
2. Extract to separate modules
3. Create internal library structure
4. Document your patterns for team

---

## 📋 Pre-Implementation Checklist

Before running `forge create`:

- [ ] Read specification document (know what you're building)
- [ ] Review ADD (know technical decisions)
- [ ] Check implementation plan (know task order)
- [ ] Identify correct template from decision matrix
- [ ] Note any special dependencies needed
- [ ] Prepare development environment (Node.js, npm, Forge CLI)

After `forge create`:

- [ ] Verify structure matches template documentation
- [ ] Run `npm install` successfully
- [ ] Run `npm run build` successfully
- [ ] Customize `manifest.yml` per ADD
- [ ] Add required permissions
- [ ] Install additional dependencies
- [ ] Update README with project specifics
- [ ] Initialize git repository (if needed)
- [ ] Create first commit with template baseline

---

## 🎓 Learning Resources

### Official Docs
- [Forge CLI Reference](https://developer.atlassian.com/platform/forge/cli-reference/)
- [Forge Templates](https://developer.atlassian.com/platform/forge/cli-reference/create/)
- [Getting Started](https://developer.atlassian.com/platform/forge/getting-started/)

### Template Examples
- [Forge Samples](https://bitbucket.org/atlassian/forge-samples/src/master/)
- [Community Apps](https://developer.atlassian.com/platform/forge/example-apps/)

### Best Practices
- [Forge Best Practices Guide](https://developer.atlassian.com/platform/forge/best-practices/)
- [Security Best Practices](https://developer.atlassian.com/platform/forge/security-overview/)

---

## 🚫 Anti-Patterns to Avoid

### ❌ DON'T: Create Structure Manually

```bash
# ❌ WRONG
forge create
mkdir -p src/{resolvers,ui,utils}
touch manifest.yml
npm init -y
```

### ✅ DO: Use Template

```bash
# ✅ CORRECT
forge create --template jira-issue-panel-ui-kit-custom-ui my-app
```

---

### ❌ DON'T: Copy Files from Another Project

```bash
# ❌ WRONG
cp -r ../old-project/src ./
cp ../old-project/manifest.yml ./
```

### ✅ DO: Use Fresh Template + Reuse Logic

```bash
# ✅ CORRECT
forge create --template <appropriate-template> new-app
# Then copy only business logic, not boilerplate
cp ../old-project/src/services/github.js ./src/services/
```

---

### ❌ DON'T: Ignore Template Structure

```bash
# ❌ WRONG
# Template expects src/index.jsx but you create:
touch app.js  # Forge won't find your code
```

### ✅ DO: Follow Template Conventions

```bash
# ✅ CORRECT
# If template has src/index.jsx, keep it as entry point
# Add new files within template structure
```

---

## 📊 Template Selection Flowchart

```
┌─────────────────────────────────────────┐
│   Start: Review ADD Decision #1         │
│   (What module type?)                   │
└──────────────────┬──────────────────────┘
                   │
         ┌─────────┴─────────┐
         │                   │
    Jira Module?      Confluence Module?
         │                   │
         ├─ Issue Panel ────→ UI Kit? ─→ jira-issue-panel
         │                   │
         │                   └─→ Custom UI? ─→ jira-issue-panel-ui-kit-custom-ui
         │
         ├─ Custom Field ───→ jira-custom-field
         │
         ├─ Dashboard ──────→ jira-dashboard-gadget
         │
         └─ Global Page ────→ jira-global-page

(Similar branches for Confluence, Bitbucket, etc.)
```

---

## 🎯 Summary

**Golden Rule**: 
> **ALWAYS start with `forge create --template`. NEVER create structure manually.**

**Template Selection**:
1. Check ADD Decision #1 (module type)
2. Check ADD Decision #2 (UI approach)
3. Use decision matrix to select template
4. Customize generated structure

**After Template Creation**:
1. Update manifest per ADD
2. Add dependencies per ADD
3. Implement features per plan
4. Test and validate

---

**Questions?** Check [Forge Community](https://community.developer.atlassian.com/c/forge/) or file an issue.
