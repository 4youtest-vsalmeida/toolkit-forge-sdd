---
description: 'Reference schema for Forge SDD metadata and frontmatter'
cycleId: 'global'
stage: 'orchestration'
status: 'draft'
createdAt: '2025-10-15T00:00:00Z'
updatedAt: '2025-10-15T00:00:00Z'
owner: 'Forge SDD Toolkit'
reviewers: []
docId: 'SDD-global-DOC-007'
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
    - storage
    - trigger
    - dashboard-gadget
  environment:
    - development
    - staging
    - production
---

# Metadata Schema Reference

Use this schema for prompts, instructions, templates, automation outputs, and generated SDD artifacts.

## Mandatory Fields

| Field | Type | Description | Example |
| --- | --- | --- | --- |
| `description` | string | One-sentence actionable summary of the artifact purpose. | `Forge plan checklist for cycle sdd-03` |
| `cycleId` | string | SDD cycle identifier (`sdd-XX` or `global` for shared assets). | `sdd-01` |
| `stage` | string | SDD stage (`ideate`, `architect`, `plan`, `implement`, `assess`, `orchestration`). | `plan` |
| `status` | string | Artifact state (`draft`, `in-progress`, `ready`, `approved`, `archived`). | `draft` |
| `createdAt` | string | ISO-8601 timestamp of creation. | `2025-10-15T00:00:00Z` |
| `updatedAt` | string | ISO-8601 timestamp of latest update. | `2025-10-15T00:00:00Z` |
| `owner` | string | Team or individual accountable. | `Forge SDD Toolkit` |
| `docId` | string | Unique ID following `SDD-{cycleId}-{artifactType}-{sequence}`. | `SDD-sdd-01-REQ-002` |
| `sourceStage` | string | Stage where the artifact originated (matches `stage` for prompts/templates, differs for generated docs reused downstream). | `architect` |
| `relatedIds` | array | Upstream/downstream IDs associated with this artifact. | `["SDD-sdd-01-REQ-001"]` |
| `forgeContext.product` | array | Atlassian products targeted. | `["jira","confluence"]` |
| `forgeContext.module` | array | Forge modules or capabilities addressed. | `["issue-panel","function","trigger"]` |
| `forgeContext.environment` | array | Deployment environments impacted. | `["development","production"]` |

## Conditional Fields

| Field | Applies To | Notes |
| --- | --- | --- |
| `mode` | prompts | `ask`, `edit`, or `agent` per Copilot guidelines. |
| `tools` | prompts | Minimal required tool bundles (e.g., `terminal`, `workspace`, `git`). |
| `validationFocus` | instructions | Outline validation or QA emphasis. |
| `artifactType` | templates, generated docs | One of `REQ`, `DEC`, `PLAN`, `TASK`, `TEST`, `DOC`, `RISK`. |
| `statusHistory` | generated docs | Chronological log of status changes. |
| `reviewers` | optional | Named reviewers for accountability. |

## ID Strategy

- Format: `SDD-{cycleId}-{artifactType}-{sequence}`.
- `cycleId`: `sdd-01`, `sdd-02`, ..., or `global` for reusable assets.
- `artifactType`: `REQ`, `DEC`, `PLAN`, `TASK`, `TEST`, `DOC`, `RISK`.
- `sequence`: three-digit zero-padded integer starting at `001` per cycle and artifact type.
- Example progression: `SDD-sdd-05-REQ-001` (requirement) → `SDD-sdd-05-DEC-001` (decision referencing that requirement) → `SDD-sdd-05-PLAN-001` (plan task derived from decision).

## Traceability Table Template

```
| Upstream ID | Downstream ID | Artifact Type | Forge Module | Scopes | Environment | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| SDD-sdd-05-REQ-001 | SDD-sdd-05-DEC-001 | DEC | issue-panel | read:jira-work | development | UI Kit decision for requirements panel |
| SDD-sdd-05-DEC-001 | SDD-sdd-05-PLAN-001 | PLAN | custom-ui | read:jira-work, write:jira-work | staging | Implementation task for Custom UI migration |
| SDD-sdd-05-PLAN-001 | SDD-sdd-05-TASK-001 | TASK | trigger | manage:jira-project | production | Deploy scheduled trigger job |
```

## Metadata Validation Rules

1. `cycleId` must match `sdd-[0-9]{2}` except for shared assets using `global`.
2. `docId` must be unique across the repository and include the same `cycleId` as the artifact.
3. `relatedIds` must reference existing upstream IDs; downstream tools validate presence during `validate-stage`.
4. `forgeContext` arrays must not be empty; use `['n/a']` only when a context genuinely does not apply and document rationale in body text.
5. Automation scripts populate or update timestamps and status fields; manual edits should maintain ISO formatting.
