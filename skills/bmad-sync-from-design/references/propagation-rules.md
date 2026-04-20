# Propagation Rules

How each detected change type maps to artifact updates.

## Change type → artifact updates

### ADDED_SCREEN

The bundle has a screen that no existing story covers.

**Updates:**
- Create new story file: `stories/<epic-prefix>.<next-index>-<slug>.md`
  - Fill in title (from bundle screen name)
  - Derive initial acceptance criteria from bundle structure + PRD (find FRs relevant to this screen)
  - Add tasks (UI, state, API if applicable, tests)
  - Add Design Reference block pointing to bundle URL + this screen name
- Update epic file: increment screen count, add this story to the epic's story list, insert at the right position in the flow
- Update `ux-design-specification.md` journey section: add this screen to the journey flow

### REMOVED_SCREEN

An existing story's screen is no longer in the bundle.

**Updates:**
- Check story status via `sprint-status.yaml`:
  - If `done` (already shipped) → HALT and ask user (don't silently undo shipped work)
  - If `pending` or `in-progress` → archive the story
- Archive mechanism: move the story file to `stories/_archived/` and add a note at the top: "Archived on {date} — screen removed in Phase 4 sync for epic {slug}"
- Update epic file: remove this story from the flow; update screen count
- Update `sprint-status.yaml` if the story was in the current sprint

### RENAMED_SCREEN

Semantic match detected; name changed.

**Updates:**
- Update the story title
- Update the Design Reference block's screen name
- Rename the story file to reflect the new slug
- Update references in the epic file

### MODIFIED_SECTION

A section within a matched screen changed.

**Updates to the story file:**
- Update acceptance criteria to mention the new/modified section
- Update tasks to cover the new section's build work
- Update or add edge cases if new states emerged

### ADDED_COMPONENT / REMOVED_COMPONENT / REPLACED_COMPONENT

**Updates to the story file:**
- Update tasks to reflect the component change
- If ADDED_COMPONENT introduces a new custom component not in the design system:
  - Add a note in the story: "New component needed — coordinate with design system"
  - Flag this in the sync report summary

### MODIFIED_COPY / ADDED_COPY

**Updates to the story file:**
- Update acceptance criteria to reflect the new copy
- Update any i18n task to include new translation keys (AR+EN if bilingual)

### STATE_MISSING_IN_DESIGN

A state in the story's Edge Cases list doesn't appear in the bundle designs.

**Updates:**
- Flag in the sync report (not auto-removed from the story — design may have missed it)
- Add a note: "State '{name}' listed in story but not designed. Confirm with design or add to a future iteration."

### STATE_MISSING_IN_STORY

A state designed in the bundle isn't in the story's Edge Cases.

**Updates to the story file:**
- Add the state to Edge Cases
- Update tasks to include implementation of this state

### PRD_CONFLICT — HALT

The design implies something that directly contradicts the PRD.

**Action:** HALT. Do NOT apply any changes for the affected screen. Prompt the user:

```
CONFLICT DETECTED:

Screen: {name}
Design shows: {what the bundle visual implies}
PRD says: {conflicting FR citation}

Options:
  [1] Update the PRD (re-open Phase 1 PRD for edit)
  [2] Update the design (go back to Claude Design, remove the conflicting element)
  [3] Override (accept the design, add a note in the story that this supersedes the PRD FR — requires explicit reason)

Enter 1, 2, or 3:
```

Wait for user input before proceeding with the rest of the changes for this epic.

## Applying the Design Reference block

For EVERY story in the epic (new or existing), ensure the Design Reference block is present and current:

```markdown
## Design Reference

- **Bundle URL:** <from bundle.md>
- **Claude Design Project:** <from bundle.md>
- **Screen name in bundle:** "<name>"
- **Last synced:** <ISO timestamp>

## Design Notes (optional — from bundle.md Notes section)
<copied from bundle.md Notes if present and relevant to this screen>
```

If the block already exists, replace it. If absent, append to the end of the story file.

## Idempotency

Running sync twice for the same bundle URL should be a no-op after the first time — all changes already applied. Detect via:
- Design Reference block's `Last synced` timestamp
- `design-progress.yaml` `bundle_url` match

If nothing changed, print a short "No updates needed" summary and skip the report.
