<!-- toolkit: forge-sdd-toolkit -->
---
description: Mandatory architecture policies for Forge Custom UI applications
applyTo: "**"
---

# Forge Custom UI Architecture Policies

These rules are MANDATORY for all Forge Custom UI applications.

## Directory Structure

- Place backend code ONLY in `src/`
- Place frontend code ONLY in `static/[module-name]/`
- Each Custom UI module must have its own `package.json`
- Use separate `tsconfig.json` for backend and each frontend module
- Never mix frontend code in `src/` or backend code in `static/`

## Asset Paths (CRITICAL)

- Always configure `base: './'` in `vite.config.ts`
- Use relative paths for all assets
- Import assets in React: `import logo from './assets/logo.png'`
- Never use absolute paths like `/assets/logo.png`

## Build Artifacts

- Add `static/*/build/` to `.gitignore`
- Add `static/*/dist/` to `.gitignore`
- Always build frontend before deploying: `npm run build:frontend`
- Never commit build directories to git

## Manifest Configuration

- `resources[].path` must point to directory (not file)
- Point to `static/[module-name]/build` (not `static/[module-name]/build/index.html`)
- Resource key must match directory name in `static/`

## Security

- Use resolvers as proxies for sensitive operations
- Validate all input in resolvers
- Store secrets on backend only (never in frontend code)
- Never expose API keys in frontend code (they will be visible in bundle)
- Never trust user input without validation

## TypeScript Configuration

Backend `tsconfig.json`:
- Use `"module": "commonjs"` (required for Node.js)
- Include `"lib": ["ES2020"]` (NO DOM)
- Never include `jsx` in backend config

Frontend `static/[module]/tsconfig.json`:
- Use `"jsx": "react-jsx"` (required for React)
- Include `"lib": ["ES2020", "DOM", "DOM.Iterable"]`
- Use `"moduleResolution": "bundler"`

## Resolver Communication

- Register all resolvers in `src/index.ts`
- Export handler: `export const handler = resolver.getDefinitions()`
- Use consistent naming between registration and invocation
- Always return typed response: `{ success: boolean, data?, error? }`
- Handle errors with try/catch in all resolvers

## Forge Platform Constraints

- Backend runs in Node.js sandbox (limited APIs, no native modules)
- Frontend must be pre-built (no on-the-fly bundling)
- Asset paths must be relative (Forge serves from dynamic URLs)
- Security via resolvers (frontend has no direct API access)
- 25-second execution timeout for all operations
