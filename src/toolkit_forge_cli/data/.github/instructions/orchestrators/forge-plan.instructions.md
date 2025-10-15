---
description: 'Instruction pack for the Forge SDD Plan stage'
---

# Forge SDD Plan Instruction Pack

## Metadata
| Field | Value |
| --- | --- |
| docId | `SDD-global-DOC-022` |
| stage | `plan` |
| owner | Forge SDD Toolkit |
| upstreamArtifacts | `SDD-{cycleId}-DEC-*` |
| supportingPrompts | `prompts/forge-plan.prompt.md` |
| forgeContext.product | `jira`, `confluence`, `bitbucket`, `compass` |
| forgeContext.module | `custom-ui`, `ui-kit`, `trigger`, `function`, `workflow-extension` |
| forgeContext.environment | `development`, `staging`, `production` |

## Stage Objectives
- Convert architecture decisions into a sequenced implementation roadmap.
- Define tasks, quality gates, and automation hooks that ensure compliance with Forge constraints.
- Balance scope, capacity, and risk to produce a realistic delivery plan.

## Required Inputs
- Architecture decision record, quality checklist, and traceability data.
- Stakeholder guidance on delivery windows, capacity, and external dependencies.
- Backlog of open risks from Ideate/Architect stages.

## Planning Framework
1. **Workstream Identification**
   - Group `DEC` items by functional area or module.
   - Map dependencies between modules (e.g., triggers require functions, custom UI requires backend resolvers).
2. **Task Decomposition**
   - Break each decision into implementable tasks referencing `instructions/implementation-task-patterns.instructions.md`.
   - Document prerequisites, deliverables, and acceptance criteria per task.
3. **Scheduling & Capacity**
   - Align tasks to sprints or milestones respecting capacity inputs.
   - Ensure long-running or risky tasks schedule early for feedback.
4. **Quality & Automation**
   - Define test strategy (unit, integration, Forge CLI validation, ShellCheck, Markdown lint).
   - Schedule quality gates before promotion to staging or production.
5. **Risk Management**
   - Identify risks (technical, process, dependency) and mitigation actions.
   - Escalate unresolved architecture questions back to architects.

## Question Bank
- Prioritization: "Which decision delivers the highest value or unlocks other work?"
- Dependencies: "Does this task rely on Forge manifest changes or environment configuration?"
- Capacity: "Which roles are required (Forge developer, QA, DevOps) and are they available?"
- Risk: "What happens if this task slips? Do we have buffer or contingency?"
- Compliance: "Do we need security or legal review before implementation?"

## Validation Logic
- `validate-stage.sh --stage plan` confirms:
  - Every task includes upstream `DEC` references and Forge module impact.
  - Quality checklist marks all mandatory gates with status and owner.
  - `plan-traceability.md` aligns requirements → decisions → tasks.
  - Schedule sections include capacity data and release target.
- Manual review ensures:
  - Timelines are feasible with documented assumptions.
  - Risks have mitigation owners and dates.
  - Automation hooks cover linting, testing, deployment verifications.

## Scenario Walkthroughs
- **Jira App with Custom UI**
  - Tasks: build UI, implement resolver, define data schema, configure manifest scopes, create tests.
  - Quality Gates: UI accessibility review, Forge tunnel dry-run, integration test with sample tenant.
- **Confluence Macro with Scheduled Trigger**
  - Tasks: macro UI, scheduled job, external API integration, caching strategy, operations runbook.
  - Risks: API quota overrun, timezone handling for schedule.
- **Compass Integration**
  - Tasks: component registration, dependency graph, event subscriptions, observability dashboards.
  - Consider cross-team dependencies for microservice updates.

## Handoff Requirements
- Completed templates: `implementation-plan.md`, `work-breakdown-structure.md`, `plan-quality-checklist.md`, `plan-traceability.md`.
- Updated `traceability.json` with `PLAN` and `TASK` entries.
- Summary of critical risks, open decisions, and readiness conditions for the Implement stage.
