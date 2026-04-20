# Phase 9: Evolve

**Goal:** Plan and execute post-launch product evolution based on real user feedback, analytics, and operational learnings.

**Exit condition:** An evolution plan exists with prioritized changes. Phase 9 is open-ended — it may recycle back into Phase 2 (UX updates), Phase 3 (new epics/stories), or Phase 4 (design iterations) as the product grows.

---

## Process

This phase is flexible. Typical activities:

### Collect signals

- User feedback (support tickets, direct interviews, NPS)
- Analytics data (funnel drop-off, feature usage, cohort retention)
- Operational data (incident logs, error rates, performance regressions)
- Competitive intelligence

### Prioritize changes

For each signal:
- Is this a **bug** → fix directly via a small story and return to Phase 6 briefly
- Is this a **UX improvement** → loop back to Phase 4 for the affected epic(s)
- Is this a **new feature** → loop back to Phase 2 (UX doc) + Phase 3 (new epic/stories) + Phase 4 (design)
- Is this a **pivot** → loop back to Phase 1 (revised PRD)

### Execute

For each prioritized change, use the normal phase flow. The roadmap file continues to track progress.

---

## Skills That May Help

- `/bmad-business-change` (carried over from v1) — orchestrate a business-level change across all artifacts (PRD + UX + epics + stories + code)
- `/bmad-correct-course` (BMM native) — re-plan when the current approach needs rework
- `/bmad-sync-artifacts` — manual sync after an out-of-flow code change

---

## Phase Completion

Phase 9 doesn't have a traditional "completion" — it's the ongoing life of the product. Mark milestones as the product evolves:

```yaml
9-evolve:
  status: in-progress     # stays in-progress; never reaches "complete"
  milestones:
    - date: "2026-06-15"
      change: "Added dark mode (Epic 7)"
    - date: "2026-08-01"
      change: "Pivoted pricing model based on Q2 retention data"
```

Each major evolution that requires a loop back to earlier phases re-opens those phases in the progress file while Phase 9 stays `in-progress`.
