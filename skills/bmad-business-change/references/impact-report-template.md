# Screen-Centric Impact Report Template

Use this template when presenting the gap analysis results to the user.

---

```
═══════════════════════════════════════════════════
BUSINESS CHANGE IMPACT REPORT
═══════════════════════════════════════════════════

CHANGE: {one-line summary of what changed}
MAGNITUDE: {Small / Medium / Large}
CURRENT PHASE: {Phase N — name}

───────────────────────────────────────────────────
SCREENS AFFECTED ({count})
───────────────────────────────────────────────────

{For each screen, group ALL changes together:}

▸ {Screen Name} ({screen spec path})
  STATUS: {New screen / Existing — needs update / Existing — code stale}
  SPEC:   {Needs update / Up to date / New spec needed}
  CODE:   {Needs update / Not yet built / Up to date}
  STORIES:
    - {Story X.Y — status} → {what needs to change}
    - {NEW Story X.Z needed} → {what it should do}
  FILES:
    - {file path} → {what specifically needs to change}

───────────────────────────────────────────────────
ARTIFACTS TO UPDATE ({count})
───────────────────────────────────────────────────

  ☐ PRD (prd.md) — {already updated / needs update}
  ☐ Architecture (architecture.md) — {specific sections}
  ☐ API Contracts (api-contracts.md) — {endpoints affected}
  ☐ Page Specs — {list of specs}
  ☐ TypeScript Contracts — {interfaces to add/modify}
  ☐ Mock Data — {mocks to update}

───────────────────────────────────────────────────
NEW STORIES NEEDED ({count})
───────────────────────────────────────────────────

  {For each new story:}
  ▸ Story {X.Y}: {Title}
    Epic: {epic number — name}
    Phase: {current phase}
    Purpose: {one-line description}
    Screen: {which screen it builds/modifies}

───────────────────────────────────────────────────
EXISTING STORIES TO MODIFY ({count})
───────────────────────────────────────────────────

  {For each affected story:}
  ▸ Story {X.Y}: {Title} — Status: {completed/pending/in-progress}
    Change: {what needs to change in the story}
    {If completed:}
    Code files: {list of source files that need updating}

───────────────────────────────────────────────────
DECISION
───────────────────────────────────────────────────

  [P] Proceed — Execute all changes
  [M] Modify  — Adjust the plan
  [S] Split   — Break into smaller changes
  [A] Abort   — Cancel this change
```

## Guidelines

1. **Screen-first grouping**: Always lead with screens. A developer looking at this should immediately know "which screens do I need to touch?"

2. **Specificity over vagueness**: Don't say "architecture needs update". Say "architecture.md §Voice Layer — change from admin-configured to user-selectable."

3. **File paths for code**: When existing code needs updating, include the exact file path. Don't make the developer search.

4. **Story numbers**: New stories should have proposed numbers following the existing numbering scheme (e.g., if Epic 4 has stories 4.1-4.5, the new one is 4.6).

5. **Phase correctness**: Every new story must be assigned to the correct phase. A UI feature in Phase 5 gets a UI story, not a backend story.
