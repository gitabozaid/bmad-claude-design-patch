# Deferred Work

## Schema (effective from patch install)

Every deferred item MUST use this schema. Silent skips are forbidden by the project's story protocol.

Entry format:

```
- id: <reviewer finding ID, e.g. C1, H3, M2>
  severity: <Critical | High | Medium | Low>
  reason: <pre-existing | phase-8-backend | architectural-scope | infrastructure-pending>
  justification: <1-2 concrete sentences; do not use "low priority" / "low ROI" / "minor">
  location: <file:line>
  source: <code-review | pr-review>
  date: <YYYY-MM-DD — last touched; updated when entry is re-kept during a retrospective>
```

Allowed `reason` values:
- **pre-existing** — bug outside this story's `git diff`.
- **phase-8-backend** — requires real backend to reproduce / fix.
- **architectural-scope** — fix touches code beyond this story; orchestrator must also open a follow-up story.
- **infrastructure-pending** — blocked on missing observability / metrics / data; must name the missing piece.

Any other reason is rejected — the finding must be fixed instead.

Headings: `## Deferred from: code review of <story> (<date>)` or `## Deferred from: PR review of <story> (<date>)`. Resolved items move to `## Resolved on <date>` with a one-line note.

Triaged during epic retrospectives (`/bmad-retrospective` includes a triage step that walks each entry).

---
