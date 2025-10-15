---
description: 'Operating guide for the Forge Specification-Driven Development toolkit'
cycleId: 'global'
stage: 'orchestration'
status: 'draft'
createdAt: '2025-10-15T00:00:00Z'
updatedAt: '2025-10-15T00:00:00Z'
owner: 'Forge SDD Toolkit'
docId: 'SDD-global-DOC-030'
sourceStage: 'orchestration'
relatedIds:
  - 'SDD-global-DOC-001'
  - 'SDD-global-DOC-003'
  - 'SDD-global-DOC-004'
forgeContext:
  product:
    - jira
    - confluence
    - bitbucket
    - compass
  module:
    - ui-kit
    - custom-ui
    - trigger
    - function
    - workflow-extension
  environment:
    - development
    - staging
    - production
---

# Forge SDD Toolkit Usage Guide

This guide outlines how to run Specification-Driven Development cycles for Atlassian Forge apps using the orchestrator prompts, templates, and automation scripts.

## Workflow Overview
1. **Ideate** – Clarify product vision and capture requirements using `prompts/forge-ideate.prompt.md`. Outputs live under `docs/sdd/<cycleId>/ideate/`.
2. **Architect** – Translate requirements into architecture decisions with `prompts/forge-architect.prompt.md`.
3. **Plan** – Build the delivery roadmap via `prompts/forge-plan.prompt.md`.
4. **Implement** – Execute plan tasks and capture evidence using `prompts/forge-implement.prompt.md`.
5. **Assess** – Validate readiness for release through `prompts/forge-assess.prompt.md`.

Each stage produces Markdown artifacts and updates `docs/sdd/<cycleId>/traceability.json` to maintain Requirement → Decision → Plan → Implementation → Assessment linkage.

## Automation Scripts
| Script | Purpose | Example |
| --- | --- | --- |
| `scripts/sdd/check-prereqs.sh` | Verify Forge CLI, tooling, manifest presence, and auth. | `./scripts/sdd/check-prereqs.sh --stage plan --cycle sdd-01` |
| `scripts/sdd/init-cycle.sh` | Create cycle folders, copy templates, update metadata. | `./scripts/sdd/init-cycle.sh --stage ideate --cycle new --feature "Release Health Dashboard" --product-context "jira,bitbucket"` |
| `scripts/sdd/validate-stage.sh` | Confirm stage artifacts exist, run linting, validate traceability. | `./scripts/sdd/validate-stage.sh --stage implement --cycle sdd-01` |
| `scripts/sdd/forge-actions.sh` | Wrap Forge CLI commands with logging and safeguards. | `./scripts/sdd/forge-actions.sh --command deploy --environment staging --cycle sdd-01 --stage implement` |

All scripts log to `logs/sdd/<cycleId>/<stage>/`. Investigate failures there before re-running.

## Prompt Execution Tips
- Launch prompts via VS Code **Chat: Run Prompt**, selecting the appropriate orchestrator file.
- Provide `featureName`, `productContext`, and `cycleId` inputs when prompted; use `new` for fresh cycles.
- Allow prompts to ask follow-up questions—do not skip mandatory metadata (scopes, integrations, compliance).
- Re-run prompts only after resolving validation failures to keep artifacts synchronized.

## Template Usage
- Templates reside under `templates/orchestrators/<stage>/`. They include required sections: Overview, Metadata, Traceability Matrix, Forge Platform Fit, Content Core, Quality Gates, Next Steps.
- `init-cycle.sh` copies templates automatically; fill metadata fields (cycleId, docId, owner) before populating body content.
- Maintain ASCII characters unless upstream artifacts require Unicode.

## Traceability Management
- `traceability.json` is the single source of truth for artifact linkage. Automation scripts append or update entries via prompts.
- When adding artifacts manually, include fields: `id`, `stage`, `artifactType`, `upstream`, `forgeContext`, `status`, `notes`.
- The `metadata-schema.md` document provides field definitions and validation rules.

## Quality Assurance
- Run `check-prereqs.sh` at the start of every stage to catch missing tooling or auth issues early.
- Execute `validate-stage.sh` before progressing to the next stage; it blocks on missing files or malformed traceability.
- Use `ShellCheck` (`shellcheck scripts/sdd/*.sh`) and `mdformat` to keep scripts and Markdown consistent.
- Capture validation results and any outstanding risks in stage quality checklists.

## Troubleshooting
- **Forge CLI authentication failed**: Run `forge login` and re-execute `check-prereqs.sh`.
- **Traceability errors**: Ensure upstream IDs exist and match the `SDD-<cycleId>-<TYPE>-###` pattern. Update `traceability.json` via prompts or manual edit with `jq`.
- **Template duplication**: Scripts skip existing files; delete the target file if you intentionally want a fresh copy.
- **Markdown formatting warnings**: Install `mdformat` (`pip install mdformat`) to enable automatic formatting checks.

## Outstanding Risks & Verification
- Scripts assume Unix tooling available on macOS or Linux; Windows users should run via WSL.
- `forge-actions.sh` does not currently support interactive prompts (e.g., site selection during install). Pass `--site` explicitly.
- Before production deployment, re-run Assess stage validation and confirm logs in `logs/sdd/<cycleId>/assess/` reflect successful checks.

Stay aligned with Atlassian Forge platform policies referenced in `instructions/forge-platform-constraints.instructions.md` and `instructions/forge-architecture-policies.instructions.md` when updating this toolkit.
