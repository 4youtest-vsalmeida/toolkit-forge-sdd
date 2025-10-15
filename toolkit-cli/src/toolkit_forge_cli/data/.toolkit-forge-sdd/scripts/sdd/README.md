---
description: 'Automation entry points for Forge SDD orchestration'
cycleId: 'global'
stage: 'orchestration'
status: 'draft'
createdAt: '2025-10-15T00:00:00Z'
updatedAt: '2025-10-15T00:00:00Z'
owner: 'Forge SDD Toolkit'
reviewers: []
docId: 'SDD-global-DOC-004'
sourceStage: 'orchestration'
relatedIds:
  - 'SDD-global-DOC-001'
forgeContext:
  product:
    - jira
    - confluence
    - bitbucket
    - compass
  module:
    - ui-kit
    - custom-ui
    - module-tunnel
    - workflow-trigger
    - storage
  environment:
    - development
    - staging
    - production
---

# SDD Automation Scripts

Shell automation supporting the SDD workflow lives here. Target scripts:

- `init-cycle.sh`: bootstrap cycle folders, copy templates, seed metadata JSON.
- `check-prereqs.sh`: verify Forge CLI, `jq`, `shellcheck`, manifest presence, and required environment variables.
- `validate-stage.sh`: lint Markdown, enforce metadata schema, confirm traceability links, and run Forge manifest checks.
- `forge-actions.sh`: wrap Forge CLI commands (`forge lint|deploy|install|tunnel`) with safeguards, logging outputs under `logs/sdd/`.

All scripts must be idempotent, POSIX-compliant, and pass ShellCheck on macOS. Document usage patterns in `docs/sdd/USAGE.md` once implementation stabilizes.
