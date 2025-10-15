# vite.config.ts Template for Forge Custom UI Apps

> **Template**: Copy this to `static/<app-name>/vite.config.ts` in your Forge app

## Purpose

This Vite configuration ensures:
- Frontend source code in `static/<app>/src/`
- Build output in `static/<app>/build/`
- Relative paths for assets (CRITICAL for Forge)
- Optimal development experience with fast HMR
- Production-ready builds with code splitting

## When to Use

- ✅ **Always** for Forge Custom UI apps with React
- ✅ When ADD Decision #2 chose "Custom UI"
- ⚠️ Adjust for Vue, Svelte, or other frameworks

---

## Template Content (TypeScript)

```typescript
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { resolve } from 'path';

/**
 * Vite Configuration for Forge Custom UI
 * 
 * CRITICAL CONFIGURATION:
 * - base: './'                        → Use relative paths (REQUIRED for Forge)
 * - outDir: 'build'                   → Build inside module directory
 * 
 * LOCATION: This file should be at static/<app-name>/vite.config.ts
 * 
 * BEFORE USING:
 * 1. Place this file in static/<app-name>/ directory
 * 2. Ensure manifest.yml resources[0].path = 'static/<app-name>/build'
 * 3. Ensure static/<app-name>/public/index.html exists
 */
export default defineConfig({
  // ⚠️ REQUIRED: Use relative paths for assets
  // Without this, assets will fail to load in Forge
  base: './',
  
  // React plugin with Fast Refresh
  plugins: [react()],
  
  // Path aliases for cleaner imports
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
  
  // Build configuration
  build: {
    // Output directory (inside this module)
    outDir: 'build',
    
    // Clean output directory before building
    emptyOutDir: true,
    
    // Assets subdirectory
    assetsDir: 'assets',
    
    // Generate sourcemaps for debugging
    sourcemap: true,
    
    // Rollup options for advanced bundling
    rollupOptions: {
      output: {
        // Code splitting strategy for better caching
        manualChunks: {
          'react-vendor': ['react', 'react-dom'],
          'forge-vendor': ['@forge/bridge'],
        },
      },
    },
    
    // Target modern browsers for smaller bundles
    target: 'es2015',
    
    // Minimize in production
    minify: 'terser',
    
    // Chunk size warnings
    chunkSizeWarningLimit: 1000, // KB
  },
  
  // Development server configuration
  server: {
    port: 3000,
    strictPort: true,
    host: true,
    
    // Enable CORS for Forge tunnel
    cors: true,
    
    // HMR configuration
    hmr: {
      overlay: true,
    },
  },
  
  // Preview server (for testing production build locally)
  preview: {
    port: 3000,
  },
  
  // Define global constants
  define: {
    __APP_VERSION__: JSON.stringify(process.env.npm_package_version || '1.0.0'),
  },
});
```

---

## Alternative: JavaScript Version

If not using TypeScript, use `vite.config.js`:

```javascript
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { resolve } from 'path';
import { fileURLToPath } from 'url';

const __dirname = fileURLToPath(new URL('.', import.meta.url));

export default defineConfig({
  base: './',  // REQUIRED
  plugins: [react()],
  
  build: {
    outDir: 'build',
    emptyOutDir: true,
  },
  
  server: {
    port: 3000,
    strictPort: true,
    host: true,
  },
});
```

---

## Required package.json (in static/<app>/)

The frontend module needs its own `package.json`:

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
│   ├── index.ts
│   └── resolvers/
│
└── static/
    └── my-app/             # Frontend module
        ├── package.json    # ← Frontend dependencies
        ├── tsconfig.json   # ← Frontend TypeScript config
        ├── vite.config.ts  # ← THIS FILE
        │
        ├── public/
        │   └── index.html
        │
        ├── src/            # React source code
        │   ├── main.tsx
        │   ├── App.tsx
        │   └── components/
        │
        └── build/          # ⚠️ Vite output (DO NOT COMMIT)
            ├── index.html
            └── assets/
```

---

## Configuration Checklist

Before building:

- [ ] File is in `static/<app-name>/vite.config.ts` (NOT in project root)
- [ ] `base: './'` is set (CRITICAL for Forge)
- [ ] `build.outDir: 'build'` (relative to this file)
- [ ] Created `src/` directory with React code
- [ ] Created `public/index.html` entry point
- [ ] Created `package.json` in same directory
- [ ] Installed dependencies (`npm install`)
- [ ] Verified manifest path: `static/<app-name>/build`

---

## Common Configurations

### For Vue.js

```typescript
import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
  base: './',  // REQUIRED
  plugins: [vue()],
  build: {
    outDir: 'build',
  },
});
```

### For Svelte

```typescript
import { defineConfig } from 'vite';
import { svelte } from '@sveltejs/vite-plugin-svelte';

export default defineConfig({
  base: './',  // REQUIRED
  plugins: [svelte()],
  build: {
    outDir: 'build',
  },
});
```

### With Environment Variables

```typescript
export default defineConfig(({ mode }) => ({
  base: './',
  plugins: [react()],
  build: {
    outDir: 'build',
    sourcemap: mode === 'development',
  },
  define: {
    'import.meta.env.VITE_APP_VERSION': JSON.stringify(process.env.npm_package_version),
  },
}));
```

---

## Verification Steps

### 1. Test Development Server

```bash
cd static/my-app
npm run dev

# Expected output:
#  VITE v5.x.x  ready in XXX ms
#
#  ➜  Local:   http://localhost:3000/
#  ➜  Network: use --host to expose
```

### 2. Test Build

```bash
cd static/my-app
npm run build

# Expected output:
# vite v5.x.x building for production...
# ✓ XX modules transformed.
# build/index.html                  X.XX kB
# build/assets/index-XXXXX.js      XX.XX kB │ gzip: XX.XX kB
# ✓ built in XXXms
```

### 3. Verify Build Output

```bash
ls -la static/my-app/build/

# Expected files:
# index.html
# assets/
#   ├── main-[hash].js
#   └── main-[hash].css
```

### 4. Test with Forge

```bash
# Terminal 1
cd static/my-app
npm run dev

# Terminal 2 (from project root)
forge tunnel

# Verify app loads in Atlassian product
```

---

## Troubleshooting

### Issue: Assets not loading (404 errors)

**Problem**: Missing `base: './'` configuration.

**Solution**:
```typescript
export default defineConfig({
  base: './',  // Add this line
  // ... rest of config
});
```

### Issue: Blank page after deploy

**Symptoms**: App loads but renders nothing in Forge.

**Common causes**:
1. Missing `base: './'`
2. Absolute paths in imports
3. Incorrect manifest path

**Solution**:
- Verify `base: './'` in vite.config.ts
- Check manifest: `path: static/<app>/build` (not just `static/<app>`)
- Use relative imports for assets

### Issue: HMR not working

**Problem**: CORS or port conflicts.

**Solution**:
```typescript
server: {
  port: 3000,
  strictPort: true,
  host: true,
  cors: true,
}
```

### Issue: Build fails with "Cannot find module '@'"

**Problem**: Path aliases not working.

**Solution**:
Ensure tsconfig.json has matching paths:
```json
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./src/*"],
      "@components/*": ["./src/components/*"]
    }
  }
}
```

---

## Performance Optimization

### Code Splitting

```typescript
build: {
  rollupOptions: {
    output: {
      manualChunks: {
        'react-vendor': ['react', 'react-dom'],
        'forge-vendor': ['@forge/bridge'],
        'ui-components': ['./src/components/ui/Button.tsx', './src/components/ui/Modal.tsx'],
      },
    },
  },
}
```

### Bundle Analysis

```bash
npm install --save-dev rollup-plugin-visualizer

# Add to vite.config.ts:
import { visualizer } from 'rollup-plugin-visualizer';

plugins: [
  react(),
  visualizer({
    open: true,
    filename: 'stats.html',
    gzipSize: true,
  }),
]
```

### Compression

```bash
npm install --save-dev vite-plugin-compression

# Add to vite.config.ts:
import viteCompression from 'vite-plugin-compression';

plugins: [
  react(),
  viteCompression({
    algorithm: 'gzip',
    ext: '.gz',
  }),
]
```

---

## Related Files

- `static/<app>/.gitignore` - Must include `build/` directory
- `static/<app>/tsconfig.json` - Frontend TypeScript config
- `static/<app>/package.json` - Frontend dependencies
- `manifest.yml` - References `static/<app>/build/` in resources
- `public/index.html` - HTML entry point

## References

- [Vite Configuration Reference](https://vitejs.dev/config/)
- [Vite React Plugin](https://github.com/vitejs/vite-plugin-react)
- [Forge Custom UI](https://developer.atlassian.com/platform/forge/custom-ui/)
- [Forge Custom UI Architecture Guide](../../../docs/best-practices/forge-custom-ui-architecture.md)
- [forge-architect.prompt.md](../../prompts/orchestrators/forge-architect.prompt.md) - Build tool decision
- [forge-implement.prompt.md](../../prompts/orchestrators/forge-implement.prompt.md) - Custom UI setup
