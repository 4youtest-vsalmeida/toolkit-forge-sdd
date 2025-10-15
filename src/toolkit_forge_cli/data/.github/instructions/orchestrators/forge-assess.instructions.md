---
description: 'Instruction pack for the Forge SDD Assess stage'
---

# Forge SDD Assess Instruction Pack

## Metadata
| Field | Value |
| --- | --- |
| docId | `SDD-global-DOC-024` |
| stage | `assess` |
| owner | Forge SDD Toolkit |
| upstreamArtifacts | `SDD-{cycleId}-TASK-*`, `SDD-{cycleId}-DOC-*`, `SDD-{cycleId}-TEST-*` |
| supportingPrompts | `prompts/forge-assess.prompt.md` |
| forgeContext.product | `jira`, `confluence`, `bitbucket`, `compass` |
| forgeContext.module | `custom-ui`, `ui-kit`, `trigger`, `function`, `workflow-extension` |
| forgeContext.environment | `staging`, `production` |

## Stage Objectives
- Validate that implemented work satisfies requirements, decisions, and plan commitments.
- Capture evidence, residual risks, and release decisions.
- Enforce compliance, security, and operational readiness before production rollout.

## Required Inputs
- Implementation evidence: `implementation-log.md`, `test-evidence.md`, `deployment-runbook.md`.
- Quality checklists from previous stages.
- Stakeholder roster for assessment review.

## Assessment Framework
1. **Readiness Check**
   - Confirm prior stages have successful validation logs.
   - Ensure assessment panel roles are defined (product owner, architect, QA, security).
2. **Evidence Correlation**
   - Map tasks to test results and deployment records.
   - Verify documentation completeness (runbooks, support guides).
3. **Quality Gates**
   - Performance: verify load/performance test metrics meet targets.
   - Security: confirm scope usage, secret handling, audit logging.
   - Supportability: ensure monitoring, alerting, and runbooks exist.
4. **Risk Evaluation**
   - Identify residual risks; categorize severity and mitigation plan.
   - Evaluate marketplace or tenant upgrade impact (if applicable).
5. **Decision Making**
   - Determine approval status; document conditions or rejection reasons.
   - Assign follow-up tasks (`RISK` or `TASK` IDs) for unresolved issues.

## Question Bank
- Coverage: "Which requirement does this test evidence support?"
- Deployment: "Was rollback procedure executed during testing?"
- Compliance: "Are data retention and privacy requirements satisfied?"
- Support: "Who monitors alerts and during which hours?"
- Release Decision: "What conditions must be met before production promotion?"

## Validation Logic
- `validate-stage.sh --stage assess` ensures:
  - Assessment templates are populated with metadata and decision outcomes.
  - Every `RISK` entry references upstream artifacts in `traceability.json`.
  - Quality checklist indicates pass/fail with remediation notes; no unresolved `BLOCKER` items.
  - Logs exist in `logs/sdd/${cycleId}/assess/`.
- Manual review steps:
  - Confirm release notes and communication plan exist (if shipping to customers).
  - Validate that production tenant is not targeted until assessment approval granted.
  - Ensure conditional approvals list responsible owners and deadlines.

## Scenario Walkthroughs
- **Customer-Facing Jira App Release**
  - Assess performance on production-like data, ensure scopes align with marketplace requirements, verify downgrade/rollback strategy.
- **Internal Confluence Automation**
  - Confirm compliance with internal audit policies, check data classification tags, ensure on-call rotation accepts responsibility.
- **Compass Integration Rollout**
  - Evaluate cross-product dependencies, confirm service health monitors, coordinate communication with DevOps teams.

## Handoff Requirements
- Completed templates: `assessment-report.md`, `assessment-quality-checklist.md`, `residual-risks.md`.
- Updated `traceability.json` with `RISK` entries and final release decision metadata.
- Summary of follow-up tasks or remediation actions for next iteration or hotfix cycle.
