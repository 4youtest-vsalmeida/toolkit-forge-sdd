---
description: 'Forge SDD orchestrator prompts overview and usage guidance'
cycleId: 'global'
stage: 'orchestration'
status: 'draft'
createdAt: '2025-10-15T00:00:00Z'
updatedAt: '2025-10-15T00:00:00Z'
owner: 'Forge SDD Toolkit'
reviewers: []
docId: 'SDD-global-DOC-001'
sourceStage: 'orchestration'
relatedIds: []
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
    - issue-panel
    - trigger
  environment:
    - development
    - staging
    - production
---

# Orchestrator Prompts

This directory will contain the refreshed Specification-Driven Development (SDD) prompts for Atlassian Forge projects. Each prompt guides Copilot Chat through a single SDD stage (Ideate, Architect, Plan, Implement, Assess) and enforces the metadata, traceability, and quality gates defined in `docs/sdd-system-overview.md`.

- Prompts must comply with `.github/instructions/prompt.instructions.md` and reference their corresponding instruction packs under `instructions/orchestrators/`.
- Every prompt collects cycle metadata, validates Forge-specific prerequisites (runtime limits, scopes, storage), and blocks progression until checks pass.
- Use these prompts via VS Code "Chat: Run Prompt" to keep conversations anchored to Forge policies and the SDD workflow.
