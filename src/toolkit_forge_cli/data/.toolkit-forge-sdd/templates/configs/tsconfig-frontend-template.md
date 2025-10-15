# tsconfig.json Template for Forge Custom UI Frontend

> **Template**: Copy this to `static/<app-name>/tsconfig.json` for your frontend module

## Purpose

This TypeScript configuration ensures:
- Frontend targets browsers (with DOM types)
- React JSX compilation works correctly
- Vite bundler compatibility
- Strict type checking for safer code

## When to Use

- ✅ **Always** for Custom UI frontend with TypeScript
- ✅ When using React with Vite
- ⚠️ Adjust for Vue, Svelte, or vanilla TypeScript

---

## Template Content

```json
{
  "compilerOptions": {
    // ============================================
    // Target and Module
    // ============================================
    
    // Target modern browsers (ES2020 features)
    "target": "ES2020",
    
    // Browser APIs (DOM, web standards)
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    
    // Use ESNext modules (Vite handles bundling)
    "module": "ESNext",
    
    // React JSX compilation (modern transform)
    "jsx": "react-jsx",
    
    // ============================================
    // Module Resolution
    // ============================================
    
    // Vite-compatible module resolution
    "moduleResolution": "bundler",
    
    // Allow importing .ts/.tsx without extension
    "allowImportingTsExtensions": true,
    
    // Allow importing JSON files
    "resolveJsonModule": true,
    
    // Enable default imports from CJS modules
    "esModuleInterop": true,
    
    // Allow default imports from modules with no default export
    "allowSyntheticDefaultImports": true,
    
    // ============================================
    // Type Checking (Strict Mode)
    // ============================================
    
    // Enable all strict type checks
    "strict": true,
    
    // Error on implicit 'any' type
    "noImplicitAny": true,
    
    // Strict null checks
    "strictNullChecks": true,
    
    // Strict function types
    "strictFunctionTypes": true,
    
    // Error on unused local variables
    "noUnusedLocals": true,
    
    // Error on unused function parameters
    "noUnusedParameters": true,
    
    // Error on fallthrough cases in switch
    "noFallthroughCasesInSwitch": true,
    
    // ============================================
    // Output (Vite handles compilation)
    // ============================================
    
    // Don't emit files (Vite does the bundling)
    "noEmit": true,
    
    // Ensure each file can be transpiled independently
    "isolatedModules": true,
    
    // ============================================
    // Other
    // ============================================
    
    // Skip type checking of declaration files
    "skipLibCheck": true,
    
    // Enforce consistent casing in file names
    "forceConsistentCasingInFileNames": true,
    
    // Include Vite client types
    "types": ["vite/client"]
  },
  
  // Files to include in compilation
  "include": [
    "src"
  ],
  
  // Files to exclude from compilation
  "exclude": [
    "node_modules",
    "build",
    "dist"
  ]
}
```

---

## With Path Aliases

If using path aliases (e.g., `@/components`), add `paths`:

```json
{
  "compilerOptions": {
    // ... other options ...
    
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@components/*": ["./src/components/*"],
      "@hooks/*": ["./src/hooks/*"],
      "@services/*": ["./src/services/*"],
      "@utils/*": ["./src/utils/*"],
      "@types/*": ["./src/types/*"]
    }
  }
}
```

**Note**: Path aliases must match those in `vite.config.ts`:

```typescript
// vite.config.ts
export default defineConfig({
  resolve: {
    alias: {
      '@': resolve(__dirname, './src'),
      '@components': resolve(__dirname, './src/components'),
      // ... etc
    }
  }
});
```

---

## Directory Structure Context

This config assumes the following structure:

```
my-forge-app/
├── manifest.yml
├── package.json            # Backend dependencies
├── tsconfig.json           # Backend TypeScript config
│
├── src/                    # Backend code
│   └── index.ts
│
└── static/
    └── my-app/             # Frontend module
        ├── package.json    # Frontend dependencies
        ├── tsconfig.json   # ← THIS FILE (Frontend config)
        ├── vite.config.ts
        │
        ├── public/
        │   └── index.html
        │
        └── src/            # TypeScript/React source
            ├── main.tsx
            ├── App.tsx
            └── components/
```

**Key Differences from Backend tsconfig.json**:

| Feature | Backend (root) | Frontend (static/app/) |
|---------|----------------|------------------------|
| Target | `ES2020` | `ES2020` |
| Lib | `["ES2020"]` | `["ES2020", "DOM", "DOM.Iterable"]` |
| Module | `commonjs` | `ESNext` |
| JSX | Not set | `"react-jsx"` |
| moduleResolution | `node` | `bundler` |
| noEmit | `false` | `true` (Vite emits) |
| types | `["node"]` | `["vite/client"]` |

---

## Configuration Checklist

Before using:

- [ ] File is at `static/<app-name>/tsconfig.json` (NOT root)
- [ ] `"jsx": "react-jsx"` is set (for React)
- [ ] `"lib"` includes `"DOM"` (for browser APIs)
- [ ] `"noEmit": true` is set (Vite handles output)
- [ ] `"include": ["src"]` points to frontend src/
- [ ] Path aliases match `vite.config.ts` (if using)
- [ ] Installed `typescript` in frontend module

---

## Common Variations

### For Vue.js

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "jsx": "preserve",           // Vue handles JSX
    "moduleResolution": "bundler",
    "strict": true,
    "noEmit": true,
    "types": ["vite/client"]
  },
  "include": ["src"]
}
```

### For Vanilla TypeScript (No JSX)

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    // No "jsx" property
    "moduleResolution": "bundler",
    "strict": true,
    "noEmit": true,
    "types": ["vite/client"]
  },
  "include": ["src"]
}
```

### With Less Strict Checking

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "jsx": "react-jsx",
    "moduleResolution": "bundler",
    
    // Relaxed type checking
    "strict": false,
    "noImplicitAny": false,
    "noUnusedLocals": false,
    "noUnusedParameters": false,
    
    "noEmit": true,
    "types": ["vite/client"]
  },
  "include": ["src"]
}
```

---

## Verification Steps

### 1. Test Type Checking

```bash
cd static/my-app

# Check for type errors
npx tsc --noEmit

# Expected: No errors, or only errors in your code
```

### 2. Test with IDE

Open any `.tsx` file in VS Code:
- Hover over React components → Should show types
- Import from `@/components` → Should autocomplete (if using path aliases)
- Use DOM APIs → Should have correct types

### 3. Test Build

```bash
cd static/my-app
npm run build

# Expected: Build succeeds with no type errors
```

---

## Troubleshooting

### Issue: "Cannot find module 'react'" or similar

**Problem**: Missing type declarations.

**Solution**:
```bash
npm install --save-dev @types/react @types/react-dom
```

### Issue: "Cannot find name 'document'" or "window"

**Problem**: Missing DOM types.

**Solution**:
Ensure `"lib"` includes `"DOM"`:
```json
{
  "compilerOptions": {
    "lib": ["ES2020", "DOM", "DOM.Iterable"]
  }
}
```

### Issue: "Cannot use JSX unless '--jsx' flag is provided"

**Problem**: Missing or wrong JSX configuration.

**Solution**:
```json
{
  "compilerOptions": {
    "jsx": "react-jsx"  // For React 17+
  }
}
```

### Issue: Path aliases not working

**Problem**: `paths` not configured or doesn't match vite.config.ts.

**Solution**:
1. Add to tsconfig.json:
```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  }
}
```

2. Match in vite.config.ts:
```typescript
export default defineConfig({
  resolve: {
    alias: {
      '@': resolve(__dirname, './src')
    }
  }
});
```

### Issue: Slow type checking

**Problem**: TypeScript checking too many files.

**Solution**:
1. Ensure `"skipLibCheck": true`
2. Add more to `"exclude"`:
```json
{
  "exclude": [
    "node_modules",
    "build",
    "dist",
    "**/*.spec.ts",
    "**/*.test.ts"
  ]
}
```

---

## Backend vs Frontend TypeScript Configs

**Root `tsconfig.json`** (Backend):
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",        // Node.js uses CommonJS
    "lib": ["ES2020"],           // Node.js APIs only
    "outDir": "./dist",          // Forge compiles output
    "rootDir": "./src"
  },
  "include": ["src/**/*"],
  "exclude": ["static", "node_modules"]
}
```

**`static/<app>/tsconfig.json`** (Frontend):
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",          // Modern ESM
    "lib": ["ES2020", "DOM"],    // Browser APIs
    "jsx": "react-jsx",          // React support
    "noEmit": true               // Vite handles output
  },
  "include": ["src"],
  "exclude": ["node_modules", "build"]
}
```

---

## Related Files

- `vite.config.ts` - Vite configuration (must be in same directory)
- `package.json` - Frontend dependencies (must be in same directory)
- `.eslintrc.json` - ESLint config (optional, uses this tsconfig)
- Root `tsconfig.json` - Backend TypeScript config (separate!)

## References

- [TypeScript Configuration Reference](https://www.typescriptlang.org/tsconfig)
- [Vite TypeScript Guide](https://vitejs.dev/guide/features.html#typescript)
- [React TypeScript Cheatsheet](https://react-typescript-cheatsheet.netlify.app/)
- [Forge Custom UI Architecture Guide](../../../docs/best-practices/forge-custom-ui-architecture.md)
- [vite-config-template.md](./vite-config-template.md) - Vite configuration template
- [forge-implement.prompt.md](../../../.github/prompts/forge-implement.prompt.md) - Implementation guide
