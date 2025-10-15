---
description: 'Instruction pack for the Forge SDD Implement stage'
---

# Forge SDD Implement Instruction Pack

## Metadata
| Field | Value |
| --- | --- |
| docId | `SDD-global-DOC-023` |
| stage | `implement` |
| owner | Forge SDD Toolkit |
| upstreamArtifacts | `SDD-{cycleId}-PLAN-*`, `SDD-{cycleId}-TASK-*` |
| supportingPrompts | `prompts/forge-implement.prompt.md` |
| forgeContext.product | `jira`, `confluence`, `bitbucket`, `compass` |
| forgeContext.module | `custom-ui`, `ui-kit`, `trigger`, `function`, `workflow-extension` |
| forgeContext.environment | `development`, `staging` |

## Stage Objectives
- Execute planned tasks while maintaining traceability to decisions and requirements.
- Capture evidence for tests, deployments, and code changes.
- Enforce Forge platform safeguards (timeouts, scopes, environment promotions).

## Required Inputs
- Approved plan templates and traceability data.
- Implementation branch and repository access.
- Forge manifest with updated modules/scopes from Architect stage.

## Implementation Framework
1. **Setup & Environment Control**
   - Validate local tooling (`node`, `npm`, `forge`, `shellcheck`) and environment variables.
   - Confirm working branch, remote tracking, and code review expectations.
2. **Task Execution**
   - Use work breakdown structure to select tasks; ensure prerequisites satisfied.
   - Encourage small commits, feature flags, and toggles for risky changes.
3. **Testing Discipline**
   - Follow plan-defined test suites: unit, integration, performance smoke, accessibility.
   - Capture command outputs and coverage metrics in `test-evidence.md`.
4. **Deployment Hygiene**
   - Use `scripts/sdd/forge-actions.sh` to wrap Forge CLI commands for linting, deploying, installing, and tunneling.
   - Document environment, command, parameters, and outcomes for each action.
5. **Documentation Trail**
   - Update `implementation-log.md` with activity summaries, commit hashes, and blockers.
   - Maintain `deployment-runbook.md` with prerequisites, rollback steps, and verification checks.

## Question Bank
- Readiness: "Has the upstream task been marked READY with dependencies resolved?"
- Quality: "What tests verify this change? Are they automated?"
- Deployment: "Which environment will we deploy to? What rollback strategy exists?"
- Compliance: "Are any secrets or sensitive data handled? How are they secured?"
- Communication: "Who needs to review or approve this change?"

## Validation Logic
- `validate-stage.sh --stage implement` checks:
  - Each task marked `DONE` has corresponding entries in `implementation-log.md` with upstream IDs.
  - `test-evidence.md` contains results for required suites and references to commits or build IDs.
  - `deployment-runbook.md` includes latest deployment entries with success/failure notes.
  - `traceability.json` includes `TASK`, `DOC`, `TEST` artifacts referencing upstream `PLAN` IDs.
- Manual reviewers confirm:
  - Code changes align with plan scope; no untracked features slip in.
  - Rollback procedures are actionable and tested.
  - Observability hooks (logs/metrics) configured per plan.

## Scenario Walkthroughs
- **UI Kit Issue Panel Enhancement**
  - Tasks: update manifest, modify UI components, adjust resolver, write tests, run `forge deploy` to staging tenant.
  - Risks: exceeding storage limit when caching remote data; ensure compression or external storage plan.
- **Custom UI Dashboard Gadget**
  - Tasks: extend backend API, update React frontend, configure OAuth secrets, add e2e tests, update runbook.
  - Quality Gates: accessibility audit, performance baseline under expected load.
- **Automation Trigger**
  - Tasks: create scheduled trigger, implement job handler, add retry/backoff, monitor metrics.
  - Testing: simulate failures, ensure idempotency, verify logs capture error context.

## Handoff Requirements
- Completed templates: `implementation-log.md`, `test-evidence.md`, `deployment-runbook.md`, `implement-quality-checklist.md`.
- Updated `traceability.json` with evidence references.
- Summary of outstanding defects or follow-up tasks for Assess stage.
