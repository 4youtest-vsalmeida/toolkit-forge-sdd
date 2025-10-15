---
description: 'Deep guidance packs for Forge SDD orchestration stages'
cycleId: 'global'
stage: 'orchestration'
status: 'draft'
createdAt: '2025-10-15T00:00:00Z'
updatedAt: '2025-10-15T00:00:00Z'
owner: 'Forge SDD Toolkit'
reviewers: []
docId: 'SDD-global-DOC-002'
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
    - workflow-condition
    - workflow-validator
    - trigger
  environment:
    - development
    - staging
    - production
---

# Orchestrator Instruction Packs

Stage-specific instruction packs live here. They provide decision frameworks, validation rules, question banks, and examples that the orchestrator prompts reference at run time.

- Each instruction file mirrors its prompt's workflow, expanding on Forge-specific considerations such as module selection, manifest requirements, scopes, and timeout handling.
- Include walkthroughs for Jira, Confluence, Bitbucket, and Compass scenarios; cover UI Kit vs Custom UI trade-offs, storage strategies, and deployment environment caveats.
- Document success criteria and exit gates that automation scripts (`scripts/sdd/`) verify during `validate-stage` execution.
