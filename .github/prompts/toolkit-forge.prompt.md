---
description: 'Build an Atlassian Forge-focused SDD orchestration system with prompts, instructions, templates, and automation'
mode: 'agent'
tools: ['runCommands', 'runTasks', 'edit', 'runNotebooks', 'search', 'new', 'github/github-mcp-server/*', 'extensions', 'todos', 'usages', 'vscodeAPI', 'problems', 'changes', 'testFailure', 'openSimpleBrowser', 'fetch', 'githubRepo', 'betterthantomorrow.joyride/joyride-eval', 'betterthantomorrow.joyride/human-intelligence']
---

# SDD Prompt Orchestration Overhaul

## Mission
Design and implement a Forge-specialized Specification-Driven Development (SDD) orchestration toolkit that ships as a reusable CLI seed. The CLI must provision `.github/` prompt and instruction packs, `.toolkit-forge-sdd/` automation scripts, templates, and reference docs, plus an empty `toolkit-forge-docs/` workspace, ensuring Atlassian Forge best practices, platform constraints, and traceability are enforced across Ideate, Architect, Plan, Implement, and Assess stages.

## Scope & Preconditions
- Work entirely in English; keep ASCII unless assets already rely on Unicode.
- Preserve the five SDD stages (`forge-ideate`, `forge-architect`, `forge-plan`, `forge-implement`, `forge-assess`).
- Assume freedom to redesign layout, metadata, and file contents from scratch while honouring existing `.instructions.md` guidance files as references.
- Embed deep Atlassian Forge domain knowledge: runtime limits, storage quotas, UI Kit vs Custom UI, app manifest and permissions, product contexts (Jira, Confluence, etc.), Forge CLI workflows.
- Prompts must remain interactive, asking clarifying questions instead of guessing critical details.
- Require GitHub Forge CLI and Bash availability; declare any additional tooling (e.g., `jq`, `shellcheck`) before relying on it.
- Ensure idempotent scripts and prompts: repeated execution must not corrupt prior cycles.

## Inputs
- `${workspaceFolder}` pointing to `/Users/vinicius.almeida/Desktop/toolkit-forge-copilot/toolkit`.
- Existing directories: `prompts/`, `instructions/`, `templates/`, `scripts/`, `docs/`.
- Legacy step templates in `templates/steps-templates/` as stylistic reference only.
- Forge platform policy references in `.github/instructions/forge-*.instructions.md`.

## Workflow
1. **Audit & Plan**
   - Inventory current prompt, instruction, template, and script files; capture key gaps versus SDD requirements and Forge platform compliance.
   - Draft a restructuring plan covering directory layout, naming conventions, and migration approach.
   - Record plan in `docs/sdd-system-overview.md` with before/after structure diagrams and Forge-specific considerations.
2. **Define Global Conventions**
   - Establish a cycle metadata schema (`cycleId`, `stage`, `status`, `createdAt`, `updatedAt`, `owner`).
   - Specify unique ID strategy: `SDD-{cycleId}-{artifactType}-{sequence}` where `artifactType` ∈ {`REQ`, `DEC`, `PLAN`, `TASK`, `TEST`, `DOC`, `RISK`}.
   - Document mandatory frontmatter fields for every prompt, instruction, template, and generated document (include `description`, `stage`, `docId`, `sourceStage`, `relatedIds`, `forgeContext`).
   - Define traceability tables mapping Requirements → Architecture Decisions → Plan Tasks → Implementation Artifacts → Assessment Findings, capturing Forge module selections, scopes, and deployment targets.
3. **Reorganize Filesystem**
   - Ensure `.github/prompts/`, `instructions/orchestrators/`, `templates/orchestrators/`, `scripts/sdd/`, `docs/sdd/` exist.
   - Move or recreate stage-specific assets under the new structure; keep legacy files untouched until replacements are ready.
   - Provide README files in each top-level directory explaining purpose, Forge context coverage, and usage.
4. **Author Stage Prompts**
   - For each stage prompt (`forge-ideate.prompt.md`, etc.), follow `.github/instructions/prompt.instructions.md` standards.
   - Embed mission, preconditions, inputs, detailed workflow, output expectations, quality checks, and escalation rules tied to Forge constraints (time limits, permission scopes, product modules).
   - Reference relevant instruction files using relative links (e.g., Forge platform constraints, code patterns, edge cases).
   - Ensure prompts collect and emit metadata (cycle, doc IDs, Forge product context, related artifacts) and gate progression until validations pass.
5. **Write Instruction Packs**
   - Create `instructions/orchestrators/forge-{stage}.instructions.md` mirroring the prompt workflow with deeper guidance: validation logic, question banks, success criteria, completion definition, and practical examples rooted in Forge scenarios.
   - Include scenario walkthroughs covering common Atlassian products, module combinations, manifest constraints, and error handling.
6. **Design Templates**
   - Build Markdown templates under `templates/orchestrators/{stage}/` for all generated docs (specification, ADD, implementation plan, quality checklists, reverse-engineering reports, deployment runbooks).
   - Introduce mandatory sections (Overview, Metadata, Traceability Matrix, Forge Platform Fit, Content Core, Quality Gates, Next Steps) and optional sections flagged clearly.
   - Incorporate traceability tables ensuring each artifact references upstream IDs and records relevant Forge modules, scopes, runtime/storage considerations, and environment configs.
7. **Implement Automation Scripts**
   - `scripts/sdd/init-cycle.sh`: bootstrap cycle folders, copy templates, seed metadata; accept `--cycle`, `--stage`, `--feature`, `--product-context`.
   - `scripts/sdd/check-prereqs.sh`: verify Forge CLI, required binaries, environment variables, manifest presence, and product permissions before stage execution.
   - `scripts/sdd/validate-stage.sh`: run stage-specific linting (Markdown lint, JSON schema validation, Forge manifest checks, cross-reference validations).
   - `scripts/sdd/forge-actions.sh`: wrap Forge CLI commands (`forge lint`, `forge deploy`, `forge install`, `forge tunnel`) with safeguards and logging.
   - Ensure scripts log in `logs/sdd/` and exit non-zero on failure, preventing progression.
8. **Enforce Inter-stage Traceability**
   - Update templates and prompts to propagate IDs (e.g., specification `REQ` IDs feed architect decisions `DEC`, which feed plan `PLAN/TASK`, implementation `TEST` and `DOC` IDs, assessment `RISK` findings).
   - Implement validation that each downstream artifact references at least one upstream ID and associated Forge module/scope; emit actionable error messages otherwise.
   - Store linkage manifests in `docs/sdd/{cycleId}/traceability.json` capturing Forge environment metadata (development, staging, production).
9. **Quality Assurance**
   - Add ShellCheck targets for Bash scripts and Markdown linting workflows (document commands).
   - Ensure each stage has a quality checklist template; prompts must mark pass/fail before allowing completion, including Forge-specific checks (timeouts, storage quotas, OAuth scopes, UI guidance).
   - Provide regression tests or dry-run examples for prompts/templates where feasible (e.g., sample manifest snippets, markdown outputs, script dry runs).
10. **Documentation & Hand-off**
    - Update or create `docs/sdd/USAGE.md` explaining the full SDD workflow, script usage, Forge CLI integration, and troubleshooting.
    - Summarize new conventions and automation in the main project README if appropriate.
    - Offer migration guidance for legacy artifacts, including mapping tables and Forge-specific adaptations.

## Output Expectations
- Five refreshed prompt files in `.github/prompts/` ready for Copilot Chat, each specialized for Atlassian Forge development.
- Five comprehensive instruction files in `.github/instructions/orchestrators/` detailing Forge-aware workflows.
- Stage-specific template suites within `.toolkit-forge-sdd/templates/orchestrators/` embedding Forge constraints and traceability structures.
- Automation scripts residing in `.toolkit-forge-sdd/scripts/sdd/` with executable permissions, supporting Forge CLI operations.
- Supporting documentation (`docs/sdd-system-overview.md`, `docs/sdd/USAGE.md`, traceability manifest examples) explicitly covering Forge platforms.
- Updated directory READMEs and metadata schemas documenting conventions and Forge considerations.

## Quality Assurance
- All new Markdown passes linting; no `[TODO]` placeholders remain.
- Bash scripts pass `shellcheck` and support macOS (BSD) and GNU tooling where possible.
- Re-running any script or prompt does not duplicate content or break existing cycles.
- Traceability validation succeeds on sample data across all stages and surfaces Forge module/scope coverage.
- Prompts reference their instruction files and templates accurately via relative paths.
- Document final verification results and outstanding risks in `docs/sdd/USAGE.md`, including Forge deployment caveats.

## Completion Criteria
- Every deliverable listed above exists, is linked, and adheres to the defined metadata and ID scheme while reflecting Atlassian Forge constraints.
- Automation confirms prerequisites and quality checks before advancing stages, blocking implementation until Forge-specific validations pass.
- The SDD workflow demonstrably prevents deployment until specifications, architecture decisions, plans, tests, and validations aligned with Forge requirements are in place.
- All guidance is self-contained, enabling new contributors to follow the SDD process end-to-end for Atlassian Forge apps without external context.