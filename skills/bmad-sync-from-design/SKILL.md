---
name: bmad-sync-from-design
description: "Sync artifacts (stories, epic file, UX doc, optionally PRD) with the final state of a Claude Design handoff bundle for a specific epic. Use when the user says 'sync from design', 'apply design changes', 'sync epic X', or when invoked by /bmad-roadmap-v2 Phase 4 after the user returns with a handoff bundle URL. Performs deep comparison (screen/section/component/copy/state level), propagates changes autonomously, marks the epic's design-progress status as complete, and prints a human-readable diff summary."
---

# BMAD Sync From Design

## Overview

After the user completes design work for an epic in Claude Design and exports a handoff bundle, this skill:

1. Reads the bundle via WebFetch
2. Compares the final designs against the existing stories/epic/UX doc
3. Propagates changes into all affected artifacts autonomously
4. Marks the epic's design status as complete

The sync is **deep** — not just screen-level. It detects section/component/copy/state changes within each screen and updates story acceptance criteria, tasks, and edge cases accordingly.

## Args

```
/bmad-sync-from-design --epic=<slug>
  [--bundle-zip <path>]         # fallback: read from local ZIP instead of URL
  [--dry-run]                   # show the diff without writing
  [--prd <path>]                # default: _bmad-output/planning-artifacts/prd.md
  [--ux-doc <path>]             # default: _bmad-output/planning-artifacts/ux-design-specification.md
  [--epics-dir <path>]          # default: _bmad-output/implementation-artifacts/epics/
  [--stories-dir <path>]        # default: _bmad-output/implementation-artifacts/stories/
```

## Pipeline

### 1. Load inputs

- Read `design-process/claude-design-handoffs/<slug>/bundle.md`
- Extract `Bundle URL` (required — halt if missing)
- Extract any user-authored content in the `Notes` section (optional)
- Read the epic file at `epics/<slug>.md`
- Read all story files in `stories/` that belong to this epic (prefix match or listed in epic file)
- Read relevant sections of `ux-design-specification.md` (journey matching the epic)

### 2. Fetch the bundle

**Primary path:** WebFetch the Bundle URL.
- Prompt for WebFetch: "Extract the list of screens (names, paths) and for each screen, list the sections, components, copy/content, and states visible. Report in structured markdown."
- If the response is meaningful (contains screen names and structure) → proceed
- If the response is thin (< 500 chars, generic, or error) → fall back

**Fallback path:** Prompt the user to download the bundle as a ZIP and pass the path.
- Ask: "Cannot read the bundle URL. Download the bundle as a ZIP from Claude Design's export menu, save it to `design-process/claude-design-handoffs/<slug>/bundle.zip`, and re-run with `--bundle-zip <path>`."
- Halt (do not continue without the bundle data).

### 3. Skip chat history

Do NOT parse chat history. The primary source of truth is the final designs. The user may have added explicit decisions to the `Notes` section of `bundle.md` — those are read in step 4.

### 4. Read user's optional Notes

If `bundle.md` has content in the `Notes` section, load it. Use it to:
- Understand constraints that shaped the design (not visible from visual alone)
- Understand non-visual interactions (gestures, keyboard shortcuts)
- Understand conditional logic tied to UI

If the Notes section is empty, proceed without it (common case).

### 5. Deep comparison

For each screen in the current stories vs the bundle:

**Screen-level detection:**
- Present in both → comparison proceeds to section-level
- In bundle but not in stories → NEW SCREEN (potential new story)
- In stories but not in bundle → REMOVED SCREEN (potential story deletion or merge)
- Renamed (semantic similarity) → RENAME

**Section-level (within each screen):**
- Added section (e.g., a new hero section)
- Removed section
- Modified section (layout change, content reorg)

**Component-level (within each section):**
- New component used
- Component replaced (e.g., card → accordion)
- Component removed

**Copy/content-level:**
- Text changed
- New CTA label
- Error message text

**State coverage:**
- Loading: shown or missing
- Empty: shown or missing
- Error: shown or missing
- Other: hover, disabled, focused — per screen relevance

Apply the logic in `references/comparison-logic.md` for edge cases.

### 6. Classify changes

For each detected change, classify:

- **Trivial copy/style update** → apply to story file silently
- **Structural change within a screen** → update story acceptance criteria + tasks
- **New screen** → create a new story file in the appropriate position; update epic file
- **Removed screen** → move the story file to an archive section of the epic file (don't delete — user may reactivate)
- **Scope shift** (epic gained or lost major functionality) → update epic file + flag UX doc section for update
- **PRD-level conflict** (design implies something that contradicts the PRD) → HALT and prompt user (this is the only pause point in the autonomous flow)

Full rules in `references/propagation-rules.md`.

### 7. Apply changes

For each non-HALT change:

- Story file updates: use Edit tool. Add/modify the specific sections (Acceptance Criteria, Tasks, Edge Cases, Design Reference).
- Epic file updates: use Edit tool. Update screen count, flow narrative.
- UX doc updates: use Edit tool. Update the journey's screen list if changed.
- Design Reference block: add/update in every story file — see `templates/bundle.md` for format.

If `--dry-run`, do NOT apply; only print the diff.

### 8. Update design-progress.yaml

Update `_bmad-output/implementation-artifacts/design-progress.yaml`:
```yaml
epics:
  <slug>:
    claude_design_project_url: "<from bundle.md>"
    bundle_url: "<from bundle.md>"
    status: design-complete
    last_handoff: "<ISO timestamp>"
    stories_synced: true
    changes_applied: <N>
```

### 9. Print diff summary

Use the template in `references/diff-report-template.md`. Organize as:

- Summary counts (screens added/removed/modified, changes applied)
- Per-story changes (what changed in each story)
- PRD escalations (if any)
- Files modified list

Save the full report to `.bmad/sync-reports/<slug>-<ISO-date>.md` for auditability.

## HALT cases

Only these cases halt autonomous execution:

1. **Bundle URL unreadable + no ZIP fallback provided** → halt with instructions
2. **PRD-level conflict detected** → halt, print the conflict, ask user: "Update PRD, update design, or override?"
3. **Screens removed that correspond to already-shipped stories** → halt, ask user: "Story X.Y was shipped but its screen is now removed. Revert, keep, or mark deprecated?"

All other changes apply autonomously.

## Non-goals

- Does NOT touch implementation code (that's Phase 6's job)
- Does NOT parse chat history from the bundle (low signal, high noise)
- Does NOT rebuild stories from scratch — only applies deltas
- Does NOT run any tests

## References

- `references/comparison-logic.md` — detailed rules for detecting screen/section/component/copy/state changes
- `references/propagation-rules.md` — how each change classification maps to artifact updates
- `references/diff-report-template.md` — the format of the printed and saved report
