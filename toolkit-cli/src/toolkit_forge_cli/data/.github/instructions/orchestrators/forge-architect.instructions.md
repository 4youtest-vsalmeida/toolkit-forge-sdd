description: 'Instruction pack for the Forge SDD Architect stage'
---

# Forge SDD Architect Instruction Pack

## Metadata
| Field | Value |
| --- | --- |
| docId | `SDD-global-DOC-021` |
| stage | `architect` |
| owner | Forge SDD Toolkit |
| upstreamArtifacts | `SDD-{cycleId}-REQ-*` |
| supportingPrompts | `prompts/orchestrators/forge-architect.prompt.md` |
| forgeContext.product | `jira`, `confluence`, `bitbucket`, `compass` |
| forgeContext.module | `ui-kit`, `custom-ui`, `function`, `trigger`, `workflow-extension` |
| forgeContext.environment | `development`, `staging`, `production` |

## Stage Objectives
- Translate approved specifications into architectural decisions with explicit traceability.
- Select Forge modules, UI strategy, and integration patterns that satisfy requirements and constraints.
- Define security scopes, performance safeguards, and operational considerations for downstream planning.

## Required Inputs
- Validated specification (`docs/sdd/${cycleId}/ideate/specification.md`).
- Ideate quality checklist results and traceability manifest entries (`REQ`).
- Any stakeholder clarifications or assumption logs tied to requirements.

## Decision Framework
1. **Module Selection**
   - Always compare UI Kit vs Custom UI capabilities using `instructions/forge-architecture-policies.instructions.md` guidance.
   - Ask:
     - Which Forge surfaces are required (issue panel, dashboard gadget, admin page)?
     - Does the experience need dynamic refresh or heavy client-side logic?
     - Are there accessibility or theming requirements met more easily via UI Kit components?
2. **Data Storage Strategy**
   - Consider data volume and retention. Use Forge Storage under 100KB per entity; escalate to external storage otherwise.
   - Questions:
     - What size is each data entity? Frequency of writes?
     - Do we need relational queries or reporting beyond Forge Storage capabilities?
3. **Integration & API Usage**
   - Map all Atlassian and third-party APIs. Reference rate limits and retry policies.
   - Validate authentication flows (user vs app context, OAuth 2 scopes, JWT webhooks).
4. **Security & Compliance**
   - Apply least-privilege scope selection; document rationale for any write/admin scopes.
   - Confirm data residency, privacy, and retention expectations.
5. **Performance & Resiliency**
   - Enforce 25s execution guard by offloading long tasks to async events/triggers.
   - Plan caching, pagination, and concurrency safeguards.
6. **Operations & Deployment**
   - Outline environment promotion path (development → staging → production) and necessary approvals.
   - Identify monitoring/logging approach (Forge logs, external telemetry).

## Question Bank
- Quality Attributes: "What success metrics (latency, availability, accuracy) must the solution achieve?"
- User Context: "Which personas interact with each module and what permissions do they possess?"
- Data Lifecycle: "How long must we retain data and how do we purge per tenant?"
- Integration Risk: "What happens if external system ${system} is unavailable for 5 minutes?"
- Compliance: "Do we handle PII/PHI? What audit evidence is required?"

## Validation Logic
- `validate-stage.sh --stage architect` must confirm:
  - Every `DEC` references at least one `REQ` in `traceability.json`.
  - `architecture-decision-record.md` frontmatter includes doc IDs, scopes, environments.
  - Quality checklist is complete with no `FAIL` items remaining unresolved.
  - Scopes listed match manifest updates and abide by least privilege.
- Manual reviewer checklist:
  - UI strategy rationale clearly states trade-offs.
  - Data retention policy documented with purge process.
  - External dependencies include SLA/contact info and retry design.

## Scenario Walkthroughs
- **Jira Issue Panel with Bitbucket Integration**
  - Modules: Issue panel, web trigger for webhook ingestion, custom function for data sync.
  - Storage: Forge Storage for cache (<100KB). Escalate to external if PR metadata grows.
  - Scopes: `read:jira-work`, `read:bitbucket-pullrequest:jira`, optional write scopes flagged.
  - Performance: Use async events triggered by Bitbucket webhooks to avoid 25s timeout.
- **Confluence Macro for Reporting**
  - Modules: Macro (Custom UI), scheduled trigger for data refresh.
  - Data: Consider external storage if aggregated dataset >100KB.
  - Compliance: Ensure macro displays last sync time and handles permission mismatches gracefully.
- **Compass App for Dependency Mapping**
  - Modules: Compass UI Kit module, events listening to component changes.
  - Integrations: External microservice for dependencies; plan retries and fallback data.

## Handoff Requirements
- Populate `architecture-decision-record.md`, `architecture-quality-checklist.md`, and `architecture-traceability.md`.
- Update `traceability.json` with all `DEC` entries and downstream references.
- Provide summary of open questions for Plan stage (capacity, sequencing, external approvals).
