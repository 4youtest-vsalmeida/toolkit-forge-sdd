---
description: 'Execute the Forge SDD Assess stage to validate outcomes and capture findings'
mode: 'agent'
tools: ['runCommands', 'edit', 'search', 'new']
---

# Forge SDD Assess Orchestrator

## Metadata
| Field | Value |
| --- | --- |
| docId | `SDD-global-DOC-014` |
| stage | `assess` |
| owner | Forge SDD Toolkit |
| upstreamArtifacts | `SDD-{cycleId}-TASK-*`, `SDD-{cycleId}-DOC-*`, `SDD-{cycleId}-TEST-*` |
| forgeContext.product | `jira`, `confluence`, `bitbucket`, `compass` |
| forgeContext.module | `custom-ui`, `ui-kit`, `trigger`, `function`, `workflow-extension` |
| forgeContext.environment | `staging`, `production` |

## Mission
Verify that implementation outcomes meet the documented requirements, quality gates, and Forge platform constraints. Capture assessment findings, residual risks, and deployment approvals or rejection reasons.

## Scope & Preconditions
- Ideate, Architect, Plan, and Implement stages must be validated with successful logs.
- Implementation artifacts (`implementation-log.md`, `test-evidence.md`, `deployment-runbook.md`) must be present in `toolkit-forge-docs/${cycleId}/implement/` and up to date.
- `./.toolkit-forge-sdd/scripts/sdd/check-prereqs.sh --stage assess` must succeed (requires Forge CLI, `jq`, `shellcheck`, `mdformat`).
- Detailed review criteria live in `../instructions/orchestrators/forge-assess.instructions.md`.

## Inputs
- `${input:cycleId:Existing SDD cycle (sdd-XX)}`
- `${input:assessmentPanel:Stakeholders participating in the review}`
- `${input:releaseDecision:Target decision - approve, conditionally approve, reject}` (optional)

## Workflow
1. **Preparation & Prerequisites**
   - Run `./.toolkit-forge-sdd/scripts/sdd/check-prereqs.sh --stage assess`.
   - Confirm implementation evidence exists; if missing, revert to Implement stage.

2. **Context Refresh**
   - Summarize the original goals and requirements from `toolkit-forge-docs/${cycleId}/ideate/specification.md` and architecture decisions in `toolkit-forge-docs/${cycleId}/architect/`.
   - Identify critical success metrics and compliance needs for review.

3. **Evidence Review**
   - Inspect `toolkit-forge-docs/${cycleId}/implement/implementation-log.md`, `toolkit-forge-docs/${cycleId}/implement/test-evidence.md`, and `toolkit-forge-docs/${cycleId}/implement/deployment-runbook.md`.
   - Map each completed task to test evidence and deployment outcomes; note gaps.

4. **User Acceptance & UX Validation**
   - Confirm user acceptance scenarios align with UI expectations (UI Kit vs Custom UI) and accessibility standards.
   - Verify localized content, theming, and performance obligations are met.

5. **Security & Compliance Audit**
   - Validate scopes, permissions, and data handling meet policy requirements using `../instructions/forge-architecture-policies.instructions.md` and `../instructions/forge-platform-constraints.instructions.md`.
   - Ensure logging and audit entries exist for critical flows.

6. **Operational Readiness**
   - Check monitoring, alerting, rollback, and on-call documentation.
   - Ensure Forge environments are documented, with promotion criteria defined.

7. **Template Completion**
   - Populate `toolkit-forge-docs/${cycleId}/assess/assessment-report.md`, `assessment-quality-checklist.md`, and `residual-risks.md` using templates from `./.toolkit-forge-sdd/templates/orchestrators/assess/`.
   - Log findings as `SDD-${cycleId}-RISK-00X` entries with severity and mitigation owners.

8. **Validation**
   - Run `./.toolkit-forge-sdd/scripts/sdd/validate-stage.sh --stage assess --cycle ${cycleId}`.
   - Require all blocking risks to have mitigation plans; unresolved blockers prevent approval.

9. **Decision & Communication**
   - Record final decision (approve/conditional/reject) with rationale and required follow-up tasks.
   - Update `toolkit-forge-docs/${cycleId}/traceability.json` linking `RISK` entries to upstream tasks/tests and documenting final status.

## Output Expectations
- `toolkit-forge-docs/${cycleId}/assess/assessment-report.md` summarizing findings, decision, and required next steps.
- `toolkit-forge-docs/${cycleId}/assess/assessment-quality-checklist.md` with gate status (performance, security, compliance, support, documentation).
- `toolkit-forge-docs/${cycleId}/assess/residual-risks.md` enumerating `RISK` IDs, severity, owners, and due dates.
- Updated `toolkit-forge-docs/${cycleId}/traceability.json` with `RISK` and final status fields, plus release decision metadata.
- Validation logs in `logs/sdd/${cycleId}/assess/`.

## Quality Assurance
- Confirm each risk references upstream artifacts (task/test/document) and includes mitigation.
- Ensure assessment decision aligns with evidence; record reasons for any conditional approval.
- Block completion if mandatory tests lack evidence or if scopes exceed approved levels.
- Verify deployment runbook contains rollback procedures validated during implementation.

## Escalation & Abort Rules
- Abort if any previous stage lacks validated outputs or traceability is broken.
- Escalate when production deployment is requested without staging validation.
- Pause assessments when compliance or security reviews are incomplete; involve governance stakeholders.
