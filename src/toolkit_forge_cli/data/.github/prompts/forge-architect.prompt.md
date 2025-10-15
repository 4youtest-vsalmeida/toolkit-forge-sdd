---
description: 'Drive the Forge SDD Architect stage to produce traceable architecture decisions'
mode: 'agent'
tools: ['runCommands', 'edit', 'search', 'new']
---

# Forge SDD Architect Orchestrator

## Metadata
| Field | Value |
| --- | --- |
| docId | `SDD-global-DOC-011` |
| stage | `architect` |
| owner | Forge SDD Toolkit |
| upstreamArtifacts | `SDD-{cycleId}-REQ-*` from Ideate stage |
| forgeContext.product | `jira`, `confluence`, `bitbucket`, `compass` |
| forgeContext.module | `ui-kit`, `custom-ui`, `function`, `trigger`, `event-listener` |
| forgeContext.environment | `development`, `staging`, `production` |

## Mission
Convert approved specifications into architecture decisions optimized for Atlassian Forge. Select modules, data flows, and integration patterns while respecting platform constraints (timeouts, storage, scopes) and establishing traceability for downstream planning.

## Scope & Preconditions
- Applies after Ideate artifacts are approved and validated (`./.toolkit-forge-sdd/scripts/sdd/validate-stage.sh --stage ideate` succeeded).
- Requires `./.toolkit-forge-sdd/scripts/sdd/check-prereqs.sh --stage architect` to pass, confirming Forge CLI auth, manifest presence, and required tooling (`jq`, `shellcheck`, `mdformat`).
- Expects access to Ideate outputs within `toolkit-forge-docs/${cycleId}/ideate/` and an up-to-date `toolkit-forge-docs/${cycleId}/traceability.json`.
- Follow guidance in `../instructions/orchestrators/forge-architect.instructions.md` for question flow and decision heuristics.

## Inputs
- `${input:cycleId:Existing SDD cycle (sdd-XX)}`
- `${input:architectureDrivers:Key drivers or quality attributes to emphasize}` (optional)
- `${input:deploymentTargets:Forge environments to support}` (e.g., development, staging, production)

Confirm upstream artifacts exist; if any are missing, ask the user to resolve before continuing.

## Workflow
1. **Prerequisite Validation**
   - Execute `./.toolkit-forge-sdd/scripts/sdd/check-prereqs.sh --stage architect` and remediate failures.
   - Run `forge whoami` to ensure CLI authentication.

2. **Cycle Context & Metadata Refresh**
   - Load `toolkit-forge-docs/${cycleId}/metadata.json`; add Architecture stage entry with timestamp, owner, and targeted environments.
   - Log selected architecture drivers in `toolkit-forge-docs/${cycleId}/architect/drivers.json` (create file if absent).

3. **Specification Intake**
   - Read `toolkit-forge-docs/${cycleId}/ideate/specification.md`, summarizing top requirements, constraints, and assumptions.
   - Highlight unresolved risks or `[FOLLOW-UP]` items; confirm with user whether they affect architecture scope.

4. **Forge Module & UI Strategy**
   - Present module options (UI Kit vs Custom UI, Triggers, Custom Fields, Dashboard Gadgets, Workflow Extensions) referencing constraints in `../instructions/forge-architecture-policies.instructions.md` and `../instructions/forge-platform-constraints.instructions.md`.
   - Use multiple-choice questioning plus free-form justification; capture decisions as `SDD-${cycleId}-DEC-00X` entries.

5. **Data & Integration Design**
   - Define data storage approach (Forge Storage, entity properties, external services) aligned with quotas.
   - Map external integrations, rate limits, and retry strategies. Record dependencies in `toolkit-forge-docs/${cycleId}/traceability.json` with `artifactType: "DEC"`.

6. **Security & Scope Planning**
   - Enumerate required OAuth scopes, admin approvals, and tenant-specific permissions. Ensure the principle of least privilege.
   - Flag compliance concerns (PII, audit logging) and document mitigations.

7. **Resilience & Performance Considerations**
   - Address timeout risks, background processing, caching, and concurrency strategies.
   - Propose monitoring/alerting hooks (Forge logs, external observability) for later stages.

8. **Template Completion**
   - Populate templates from `./.toolkit-forge-sdd/templates/orchestrators/architect/` into `toolkit-forge-docs/${cycleId}/architect/`, including `architecture-decision-record.md`.
   - Fill `architecture-quality-checklist.md` and `architecture-traceability.md`, ensuring every `DEC` references at least one upstream `REQ`.

9. **Validation**
   - Run `./.toolkit-forge-sdd/scripts/sdd/validate-stage.sh --stage architect --cycle ${cycleId}`; block on errors (missing linkage, invalid scopes, manifest mismatches).
   - Store validation logs under `logs/sdd/${cycleId}/architect/`.

10. **Handoff Preparation**
   - Summarize key decisions, unresolved risks, and TODOs for the Plan stage.
   - Update `toolkit-forge-docs/${cycleId}/traceability.json` linking `DEC` entries to the requirements they satisfy.

## Output Expectations
- `toolkit-forge-docs/${cycleId}/architect/architecture-decision-record.md` with metadata, context, decision log, and Forge platform fit assessment.
- `toolkit-forge-docs/${cycleId}/architect/architecture-quality-checklist.md` marking pass/fail for scope, performance, resiliency, and compliance gates.
- `toolkit-forge-docs/${cycleId}/architect/architecture-traceability.md` summarizing requirement → decision mappings plus module/scope coverage.
- Updated `toolkit-forge-docs/${cycleId}/traceability.json` including `DEC` entries and linked upstream `REQ` IDs.

## Quality Assurance
- Confirm each `DEC` references at least one `REQ` and specifies chosen Forge module(s) and scopes.
- Ensure UI strategy explicitly states UI Kit vs Custom UI rationale and aligns with runtime limits.
- Verify background tasks exceeding 25 seconds are assigned to async events with retry strategies.
- Block completion if security scopes exceed minimal requirements without stakeholder approval.

## Escalation & Abort Rules
- Abort if Ideate validation logs are missing or failed.
- Escalate to stakeholders when required scopes include admin-level permissions or when external integrations lack SLA details.
- Pause the stage if manifest updates are required but cannot be validated (e.g., missing `manifest.yml`).
