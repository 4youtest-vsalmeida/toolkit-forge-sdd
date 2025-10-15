---
description: 'Template suites for Forge SDD orchestration outputs'
cycleId: 'global'
stage: 'orchestration'
status: 'draft'
createdAt: '2025-10-15T00:00:00Z'
updatedAt: '2025-10-15T00:00:00Z'
owner: 'Forge SDD Toolkit'
reviewers: []
docId: 'SDD-global-DOC-003'
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
    - dashboard-gadget
    - jira-admin-page
    - confluence-panel
  environment:
    - development
    - staging
    - production
---

# Orchestrator Templates

This directory houses Markdown templates organized by SDD stage. Each template enforces mandatory metadata, traceability matrices, and Forge platform fit evaluations.

- Subdirectories (`ideate/`, `architect/`, `plan/`, `implement/`, `assess/`) will contain specification, decision, plan, runbook, checklist, and assessment templates with built-in ID slots (`SDD-{cycleId}-{artifactType}-{sequence}`).
- Templates must capture Forge module selections, scopes, runtime/storage constraints, and environment configurations to support automated validation.
- Scripts and prompts copy these templates when initializing a cycle to guarantee consistent document scaffolding.
