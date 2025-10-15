---
description: 'Lead the Forge SDD Plan stage to translate decisions into executable tasks'
mode: 'agent'
tools: ['runCommands', 'edit', 'search', 'new']
---

# Forge SDD Plan Orchestrator

## Metadata
| Field | Value |
| --- | --- |
| docId | `SDD-global-DOC-012` |
| stage | `plan` |
| owner | Forge SDD Toolkit |
| upstreamArtifacts | `SDD-{cycleId}-DEC-*` |
| forgeContext.product | `jira`, `confluence`, `bitbucket`, `compass` |
| forgeContext.module | `custom-ui`, `ui-kit`, `trigger`, `function`, `workflow-extension` |
| forgeContext.environment | `development`, `staging`, `production` |

## Mission
Turn architecture decisions into a prioritized, validated implementation plan with traceable tasks, milestones, and quality gates tailored to Forge constraints.

## Scope & Preconditions
- Ideate and Architect stages must have validated outputs (`./.toolkit-forge-sdd/scripts/sdd/validate-stage.sh` success logs present).
- Dependencies on Forge modules, scopes, and manifests must be documented in `toolkit-forge-docs/${cycleId}/traceability.json`.
- `./.toolkit-forge-sdd/scripts/sdd/check-prereqs.sh --stage plan` must pass (requires Forge CLI, `jq`, `shellcheck`, `mdformat`).
- Follow deep guidance in `../instructions/orchestrators/forge-plan.instructions.md`.

## Inputs
- `${input:cycleId:Existing SDD cycle (sdd-XX)}`
- `${input:sprintLength:Planning cadence in days}` (optional)
- `${input:teamCapacity:Available engineering capacity per sprint}` (optional)
- `${input:releaseTarget:Desired release window or milestone}` (optional)

## Workflow
1. **Prerequisite Check**
   - Run `./.toolkit-forge-sdd/scripts/sdd/check-prereqs.sh --stage plan`.
   - Verify `logs/sdd/${cycleId}/architect/` contains successful validation output; stop otherwise.

2. **Metadata Update**
   - Append Plan stage entry to `toolkit-forge-docs/${cycleId}/metadata.json` including capacity, sprint length, and release target.
   - Load architecture drivers and decisions into memory for cross-referencing.

3. **Decision Breakdown**
   - Enumerate each `DEC` item and ask the user for implementation considerations (sequence, dependencies, skill sets).
   - Translate into preliminary tasks (`TASK`) and supporting documents (`DOC`).

4. **Risk & Constraint Alignment**
   - Check for long-running tasks requiring async events, storage changes, or new scopes; record mitigation strategies.
   - Cross-reference `../instructions/implementation-task-patterns.instructions.md` for best practices.

5. **Template Population**
   - Copy plan templates from `./.toolkit-forge-sdd/templates/orchestrators/plan/` into `toolkit-forge-docs/${cycleId}/plan/` if missing.
   - Populate `implementation-plan.md` (milestones, deliverables, test strategy), `work-breakdown-structure.md`, and `plan-quality-checklist.md` within that directory.
   - Ensure each task includes owner, duration, dependencies, Forge module coverage, and upstream `DEC` IDs.

6. **Traceability Mapping**
   - Update `toolkit-forge-docs/${cycleId}/traceability.json` with `PLAN` and `TASK` entries referencing source `DEC` IDs and targeted environments.
   - Generate `toolkit-forge-docs/${cycleId}/plan/plan-traceability.md` summarizing requirement → decision → plan alignment.

7. **Capacity & Schedule Validation**
   - Ask user to confirm capacity assumptions; adjust task sequencing accordingly.
   - Validate no sprint exceeds capacity; flag overloads as blockers until resolved.

8. **Automation Hooks**
   - Specify automation or validation hooks (linting, unit tests, Forge CLI commands) to be run during implementation.
   - Document readiness criteria for moving to Implement stage.

9. **Validation**
   - Execute `./.toolkit-forge-sdd/scripts/sdd/validate-stage.sh --stage plan --cycle ${cycleId}`.
   - Ensure quality checklist items are marked and unresolved risks explicitly assigned to owners.

10. **Handoff Summary**
    - Produce executive summary covering timeline, critical risks, and required approvals.
    - Provide next-step checklist for the Implement stage.

## Output Expectations
- `toolkit-forge-docs/${cycleId}/plan/implementation-plan.md` with milestones, task breakdown, and quality gates.
- `toolkit-forge-docs/${cycleId}/plan/work-breakdown-structure.md` capturing task metadata and dependencies.
- `toolkit-forge-docs/${cycleId}/plan/plan-quality-checklist.md` with validation results and open items.
- `toolkit-forge-docs/${cycleId}/plan/plan-traceability.md` connecting requirements → decisions → tasks.
- Updated `toolkit-forge-docs/${cycleId}/traceability.json` with `PLAN`/`TASK` records.

## Quality Assurance
- Confirm each task references at least one `DEC` and identifies Forge module/scope impact.
- Ensure plan timeline respects capacity and release target; escalate if unrealistic.
- Validate that testing and validation activities cover Forge-specific requirements (manifest linting, environment promotion, scope review).
- Block completion if automation hooks or quality gates are undefined.

## Escalation & Abort Rules
- Abort if architecture validation failed or required decisions are missing.
- Escalate when dependencies include external teams/services with unconfirmed SLAs.
- Pause when capacity inputs are undefined or contradictory; require stakeholder confirmation.
