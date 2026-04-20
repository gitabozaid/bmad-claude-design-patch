---
name: bmad-create-epics-and-stories-v2
description: "Generate epics and stories from the PRD + UX design specification, then run adversarial + edge-case reviews on every story before declaring them ready. Use when the user says 'create epics and stories', 'create epics v2', or when invoked by /bmad-roadmap-v2 Phase 3. This skill wraps the base BMM /bmad-create-epics-and-stories and adds quality reviews (adversarial-general + edge-case-hunter) that were previously done by Kateb in the story protocol. The result: stories are ready for Phase 4 design work without requiring a separate reconciliation pass later."
---

# BMAD Create Epics and Stories v2

## Overview

The base BMM `/bmad-create-epics-and-stories` generates epics and stories from the PRD + UX doc. This wrapper adds two quality passes on every generated story:
- `bmad-review-adversarial-general` (BMM native) — looks for adversarial/boundary issues
- `bmad-review-edge-case-hunter` (BMM native) — hunts for unaddressed edge cases

In the v1 patch, these reviews ran inside the Kateb agent during the Story Protocol. In v2, they move here — at story creation time — so:
- Stories are ready for Claude Design in Phase 4 without a reconciliation step
- Reviews run once (at creation) instead of every time a story is built
- The Story Protocol is simpler (no Kateb)

## Args

```
/bmad-create-epics-and-stories-v2
  [--prd <path>]              # default: _bmad-output/planning-artifacts/prd.md
  [--ux-doc <path>]           # default: _bmad-output/planning-artifacts/ux-design-specification.md
  [--epics-dir <path>]        # default: _bmad-output/implementation-artifacts/epics/
  [--stories-dir <path>]      # default: _bmad-output/implementation-artifacts/stories/
  [--skip-reviews]            # rare: skip the adversarial + edge-case passes (not recommended)
```

## Pipeline

### Step 1: Invoke base skill

Invoke `/bmad-create-epics-and-stories` via the Skill tool with the same path arguments. Let it produce:
- `epics/*.md` — one file per epic (derived from UX doc's user journeys)
- `stories/*.md` — one file per story (one per screen within each journey)

Note the list of new story files produced.

### Step 2: Run adversarial + edge-case reviews on each story

For each new story file (unless `--skip-reviews` was passed):

In a SINGLE message, launch BOTH reviews in parallel via Skill tool:
- `bmad-review-adversarial-general` on the story file
- `bmad-review-edge-case-hunter` on the story file

Collect findings from both. Apply every finding to the story file directly (using Edit):
- Adversarial findings → usually become additional acceptance criteria or edge cases
- Edge-case findings → add to the Edge Cases section; may extend tasks

Track per-story:
- Number of adversarial findings found / applied
- Number of edge-case findings found / applied

### Step 3: Report summary

Print a condensed summary:

```
╔══════════════════════════════════════════════════════════════════╗
║ EPICS & STORIES — CREATED AND REVIEWED                             ║
╠══════════════════════════════════════════════════════════════════╣
║ Epics created: {{N}}                                               ║
║ Stories created: {{M}}                                             ║
║                                                                    ║
║ Reviews completed per story:                                       ║
║   - Adversarial findings: {{total}} total, {{applied}} applied     ║
║   - Edge-case findings: {{total}} total, {{applied}} applied       ║
║                                                                    ║
║ Files written:                                                     ║
║   - {{epic_paths}}                                                 ║
║   - {{story_paths}}                                                ║
║                                                                    ║
║ Next: /bmad-check-implementation-readiness (Phase 3 Step 2)       ║
╚══════════════════════════════════════════════════════════════════╝
```

## Idempotency

Running twice:
- Base skill may regenerate or skip already-present files (follow its behavior)
- Reviews: only run on NEW story files (skip files that have a "Reviews applied" footer from a previous run)
- Add a footer at the bottom of each reviewed story:
  ```markdown
  <!-- Reviewed: {{date}} — adversarial applied, edge-case applied -->
  ```

## Non-goals

- Does NOT read the Claude Design bundle (that's Phase 4's sync job)
- Does NOT validate against deployed artifacts — only source artifacts
- Does NOT modify the PRD or UX doc

## Rationale

Moving these reviews to Phase 3 (creation time) instead of Phase 6 (story protocol):

1. **Stories are ready for design work earlier.** Claude Design in Phase 4 gets well-formed stories as input.
2. **Reviews run once, not per-story-build.** Faster loops.
3. **Separation of concerns:** Phase 3 = quality gate for stories. Phase 6 = execution.

The old Kateb agent's other responsibilities (spec reconciliation, cross-reference checks) no longer apply in v2:
- Spec reconciliation → `/bmad-sync-from-design` in Phase 4
- Cross-reference checks → baked into the base BMM skill + these reviews

Kateb is fully removed from the v2 patch.
