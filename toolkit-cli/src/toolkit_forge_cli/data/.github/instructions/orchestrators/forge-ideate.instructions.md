description: 'Guidance for running the Forge SDD Ideate orchestrator prompt'
---

# Forge SDD Ideate Instruction Pack

## Metadata
| Field | Value |
| --- | --- |
| docId | `SDD-global-DOC-020` |
| stage | `ideate` |
| owner | Forge SDD Toolkit |
| relatedIds | `SDD-global-DOC-010`, `SDD-global-DOC-003` |
| forgeContext.product | `jira`, `confluence`, `bitbucket`, `compass` |
| forgeContext.module | `ui-kit`, `custom-ui`, `issue-panel`, `dashboard-gadget`, `trigger` |
| forgeContext.environment | `development`, `staging`, `production` |

## Purpose
Provide detailed guidance for the Ideate stage prompt, ensuring specification quality, Forge constraint awareness, and traceability enforcement.

## Quick Reference
- Prompts: `prompts/orchestrators/forge-ideate.prompt.md`
- Templates: `templates/orchestrators/ideate/`
- Automation: `scripts/sdd/init-cycle.sh`, `scripts/sdd/check-prereqs.sh`, `scripts/sdd/validate-stage.sh`

## Stage Objectives
- Clarify the product vision, target users, and success criteria.
- Capture functional and non-functional requirements with traceable IDs.
- Document assumptions, constraints, and edge cases aligned with Forge policies.

## Required Inputs
- User problem statement or product vision (can be rough; the prompt will clarify).
- Stakeholder roster and target Atlassian product(s).
- Access to Forge platform constraint references (`instructions/forge-platform-constraints.instructions.md`).

## Ideation Framework
1. **Progressive Clarity Assessment**
	 - Score four dimensions: Scope & Boundaries, Users & Context, Problem & Value, Constraints & Integrations.
	 - Use scoring rubric:
		 - 🟢 Clear: explicit detail provided.
		 - 🟡 Partial: implied or incomplete.
		 - 🔴 Vague: missing or ambiguous.
	 - Focus follow-up questions on 🟡/🔴 dimensions.
2. **Question Flow**
	 - Start with closed-ended (multiple-choice) to accelerate clarity.
	 - Follow with open-ended prompts for nuance (compliance, data residency, integrations).
	 - Always ask about security, privacy, and failure handling.
3. **Requirement Capture**
	 - Categorize requirements as `Functional`, `Non-Functional`, `Compliance`, `Operational`.
	 - Assign `REQ` IDs sequentially (`SDD-${cycleId}-REQ-00X`).
	 - Record acceptance criteria and associated user roles.
4. **Assumption Logging**
	 - Use `[ASSUMPTION: ...]` format and justify with platform policy references.
	 - Distinguish between safe defaults vs. risky guesses needing follow-up.
5. **Edge Case Enumeration**
	 - For each critical flow, document at least one timeout scenario, permission issue, and external integration failure.
6. **Traceability Prep**
	 - Populate traceability table skeleton linking future `DEC` IDs.
	 - Record external dependencies (APIs, services) and data classifications.

## Question Bank
- Scope: "Which Jira projects or Confluence spaces must this app support?"
- Users: "Who triggers the app? What permissions do they have?"
- Value: "What measurable outcome indicates success (time saved, errors reduced)?"
- Data: "What data do we read/write? Any PII or compliance requirements?"
- Integrations: "Which external systems must we connect to? How often?"
- Failure Modes: "How should the app behave if the external service is down?"

## Validation Logic
- `validate-stage.sh --stage ideate` checks:
	- `specification.md` includes metadata, requirement catalog, and traceability table.
	- Quality checklist covers scope, safety, compliance, and risk questions.
	- `traceability.json` includes `REQ` entries with descriptions and product contexts.
	- No unmet mandatory questions (security, privacy, integrations) remain blank.
- Manual reviewer checklist:
	- Requirements are testable and map back to user goals.
	- Edge cases cover timeout, storage, and permission scenarios.
	- Assumptions reference authoritative sources or are flagged for follow-up.

## Scenario Walkthroughs
- **Jira Issue Panel for PR Status**
	- Requirements: display PR list, show status, link to Bitbucket.
	- Constraints: Bitbucket authentication, performance (refresh every 5 min).
	- Edge Cases: PR API downtime, user without repository access, large PR list.
- **Confluence Page Sync with Jira Issues**
	- Requirements: push metadata, maintain backlinks, schedule sync.
	- Constraints: API rate limits, data size (summary vs. full content).
	- Edge Cases: Conflicting edits, permission mismatches, stale cache.
- **Compass Dependency Dashboard**
	- Requirements: show service dependencies, highlight risk levels, integrate with incident system.
	- Constraints: Frequent updates, cross-product scopes, security classification.
	- Edge Cases: Missing dependency data, unauthorized viewer, stale risk signals.

## Handoff Requirements
- Completed templates: `specification.md`, `specification-quality-checklist.md`, `edge-case-catalog.md` (if applicable).
- `traceability.json` seeded with `REQ` entries and related context.
- Summary of open questions or risks to tackle during Architect stage.
