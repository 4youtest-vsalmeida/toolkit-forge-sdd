---
description: 'Coordinate the Forge SDD Implement stage to execute plan tasks and capture evidence'
mode: 'agent'
tools: ['runCommands', 'edit', 'search', 'new']
---

# Forge SDD Implement Orchestrator

## Metadata
| Field | Value |
| --- | --- |
| docId | `SDD-global-DOC-013` |
| stage | `implement` |
| owner | Forge SDD Toolkit |
| upstreamArtifacts | `SDD-{cycleId}-PLAN-*`, `SDD-{cycleId}-TASK-*` |
| forgeContext.product | `jira`, `confluence`, `bitbucket`, `compass` |
| forgeContext.module | `custom-ui`, `ui-kit`, `trigger`, `function`, `workflow-extension` |
| forgeContext.environment | `development`, `staging` (promotion to production gated by Assess stage) |

## Mission
Execute the implementation plan with disciplined tracking, testing, and Forge-aware guardrails. Ensure all code, configuration, and deployment steps remain traceable to upstream tasks and decisions.

## Scope & Preconditions
- Plan stage outputs must be validated and stored in `toolkit-forge-docs/${cycleId}/plan/`.
- Source code repository must be ready; confirm branch name and workspace state before making changes.
- `./.toolkit-forge-sdd/scripts/sdd/check-prereqs.sh --stage implement` must pass (includes `forge`, `git`, `jq`, `shellcheck`, `npm`).
- For detailed guidance, consult `../instructions/orchestrators/forge-implement.instructions.md`.

## Inputs
- `${input:cycleId:Existing SDD cycle (sdd-XX)}`
- `${input:implementationBranch:Git branch to use}`
- `${input:environments:Forge environments to deploy during this stage}` (default: development, staging)

## Workflow
1. **Environment Verification**
   - Run `./.toolkit-forge-sdd/scripts/sdd/check-prereqs.sh --stage implement` and `git status` to ensure clean working tree or documented local changes.
   - Confirm `forge whoami` and list available environments with `forge environments list` using `./.toolkit-forge-sdd/scripts/sdd/forge-actions.sh` wrapper.

2. **Task Selection & Metadata Update**
   - Load `toolkit-forge-docs/${cycleId}/plan/work-breakdown-structure.md` and `toolkit-forge-docs/${cycleId}/traceability.json`; select tasks marked `READY` for implementation.
   - Update `toolkit-forge-docs/${cycleId}/implement/implementation-log.md` with start timestamps and assigned owners.

3. **Development Execution**
    - For each task:
       - Clarify acceptance criteria and dependencies.
       - Guide coding steps, referencing `../instructions/forge-code-patterns.instructions.md` and `../instructions/edge-case-architecture-patterns.instructions.md` where relevant.
   - Encourage incremental commits tagged with task IDs such as `SDD-${cycleId}-TASK-001`.

4. **Testing & Validation**
   - Run automated tests defined in the plan (unit, integration, linting). Document results in `toolkit-forge-docs/${cycleId}/implement/test-evidence.md`.
   - Execute Forge validations via `./.toolkit-forge-sdd/scripts/sdd/forge-actions.sh --cycle ${cycleId} --command "lint"|"deploy"|"install"|"tunnel"` as needed.
   - Log outputs to `logs/sdd/${cycleId}/implement/`.

5. **Deployment Steps**
   - If deploying to development/staging, record command history, environment variables, and approvals in `toolkit-forge-docs/${cycleId}/implement/deployment-runbook.md`.
   - Ensure secrets management aligns with Forge requirements; never embed credentials in repo.

6. **Status Updates**
   - Update `toolkit-forge-docs/${cycleId}/implement/implementation-log.md` with completion timestamps, outcomes, and links to code changes (commit hashes, PR URLs).
   - Mark tasks as `DONE`, `BLOCKED`, or `DEFERRED` in `toolkit-forge-docs/${cycleId}/plan/work-breakdown-structure.md`; escalate blockers immediately.

7. **Validation & Sign-off**
   - Run `./.toolkit-forge-sdd/scripts/sdd/validate-stage.sh --stage implement --cycle ${cycleId}` to verify traceability, documentation completeness, and test coverage.
   - Require checklist sign-off for quality gates in `toolkit-forge-docs/${cycleId}/implement/implement-quality-checklist.md` (performance, security, observability, documentation).

8. **Handoff Preparation**
   - Compile summary of completed tasks, deployment status, outstanding defects, and test coverage for Assess stage review.
   - Ensure `toolkit-forge-docs/${cycleId}/traceability.json` reflects `DOC`, `TASK`, and `TEST` artifacts created during implementation.

## Output Expectations
- `toolkit-forge-docs/${cycleId}/implement/implementation-log.md` with task execution details and traceability IDs.
- `toolkit-forge-docs/${cycleId}/implement/test-evidence.md` capturing test suites, results, and coverage notes.
- `toolkit-forge-docs/${cycleId}/implement/deployment-runbook.md` documenting Forge CLI commands, environment variables, and rollback plans.
- `toolkit-forge-docs/${cycleId}/implement/implement-quality-checklist.md` summarizing quality gate status.
- Updated `toolkit-forge-docs/${cycleId}/traceability.json` with `TASK`, `DOC`, and `TEST` entries referencing plan decisions.

## Quality Assurance
- Ensure every commit or change references a tracked task ID.
- Confirm Forge deployments run through `forge-actions.sh` wrappers to capture logs and enforce safeguards.
- Block completion if any mandatory test suite fails or lacks evidence in `test-evidence.md`.
- Require rollback procedures for any deployment activity.

## Escalation & Abort Rules
- Abort if plan validation logs are missing or outdated.
- Escalate on repeated deployment failures, missing credentials, or security review blockers.
- Pause when code changes threaten scope creep; involve plan owners before proceeding.
