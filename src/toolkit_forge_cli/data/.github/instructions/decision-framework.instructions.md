<!-- toolkit: forge-sdd-toolkit -->
---
description: Forge architectural decision framework for SDD methodology
applyTo: "**"
---

# Forge Architectural Decisions

When making architectural decisions for Forge applications:

- Always trace decisions back to specific requirements from the Specification Document
- Consider at least 3 alternatives before deciding
- Document trade-offs explicitly (what we gain vs what we lose)
- Include measurable validation criteria
- Record all decisions in Architecture Decision Documents (ADD)

## Module Selection

- Use `jira:issuePanel` for displaying content in issue context
- Use `trigger:issueUpdated` for responding to issue changes
- Use `jira:customField` for adding custom data to issues
- Use `workflow:trigger` for automating workflows
- Use `confluence:macro` for Confluence content enhancement
- Use `common:globalPage` for cross-product access

## UI Framework Choice

Choose Custom UI when you need:
- Real-time updates or WebSocket connections
- Complex state management
- Custom styling beyond Atlassian defaults
- Full React capabilities and npm packages

Choose UI Kit when you need:
- Simple forms and basic interactions
- Server-side rendered content
- Automatic Atlassian theming
- Simpler security model

## Storage Strategy

- User preferences → Forge Storage (100KB/key limit)
- Temporary cache → Forge Storage with TTL
- Issue metadata → Entity Properties (32KB limit)
- Large datasets → External API
- Cross-product data → App Storage

## Performance

- Operations > 20 seconds → Async events required
- Operations 10-20 seconds → Async events recommended
- Heavy processing → Use async events
- Simple operations < 10 seconds → Synchronous acceptable

## Security Scopes

- Request minimum necessary scopes only
- Start with read-only scopes
- Add write scopes only when needed
- Request admin scopes as last resort
- Document why each scope is necessary

## Rate Limiting

- < 10 API calls/min → Direct calls
- 10-50 calls/min → Basic caching
- 50-200 calls/min → Aggressive caching + batching
- > 200 calls/min → Async processing + queues
