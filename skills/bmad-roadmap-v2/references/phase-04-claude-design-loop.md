# Phase 4: Per-Epic Claude Design Loop

**Goal:** For each epic, design every screen in [Claude Design](https://claude.ai/design), export a handoff bundle, and propagate design changes back to stories/epic/UX doc (and PRD if scope shifted). This is the **only** phase with manual user work in a browser.

**Exit condition:** Every epic in `design-progress.yaml` has `status: design-complete` and a `bundle_url` set.

---

## One-Time Setup (before the loop starts)

Two one-time setup steps:

### Setup 1 — Organization-level design system

Done once per project, not per epic:

1. Open [claude.ai/design](https://claude.ai/design) and create an organization for this project (or use an existing one)
2. Upload the project's design system:
   - **Best:** link the GitHub repository (or local directory) containing the project's component library + styles
   - **Alternative:** manually upload color palette, typography specimens, component screenshots
3. Review the extracted design system (colors, typography, components)
4. Toggle the design system "Published" so every project under this organization inherits it

**Do this step ONLY once per project.** Subsequent epics reuse the same organization-level design system.

### Setup 2 — App Shell Pre-flight

Claude Design does NOT have Figma-style layout inheritance across projects. To guarantee shell consistency across per-epic projects, the app shell (header, footer, sidebar, navigation — the chrome that appears on most screens) must live in the CODEBASE before Phase 4 starts.

**Pre-flight prompt (the orchestrator asks the user):**

```
Before Phase 4 can start, we need to know the status of the app shell.

Has your project got an AppLayout (or stack-equivalent) component implemented?

  [yes]   → Tell me the path (e.g., frontend/src/components/layout/AppLayout.tsx).
            I'll record it in design-progress.yaml and proceed to the per-epic loop.
  [no]    → I'll guide you through the shell workflow (design in Claude Design
            "00 — App Shell", export, implement, commit). Then come back and
            answer [yes].
  [skip]  → The product has no persistent shell (single-screen landing,
            minimal PWA, interstitial, etc.). Skip shell-related instructions
            for every epic. Codebase attachment becomes OPTIONAL instead of
            REQUIRED.
```

**On `[yes]`:**
- Record `app_shell.status: implemented`, `app_shell.layout_component_path: <user-provided path>`, `app_shell.implemented_at: {today}` in `design-progress.yaml`
- Proceed to "The Loop" section below

**On `[no]`:**
- Print the shell-first workflow:
  ```
  1. Go to claude.ai/design
  2. Create a new project named "00 — App Shell"
  3. Prompt: "Design the app shell for <product type>: header (logo + nav + user avatar),
     footer (if any), sidebar (if any), navigation. Show all variants: default,
     scrolled, mobile (hamburger state if applicable), desktop."
  4. Iterate until satisfied
  5. Export → Hand off to Claude Code
  6. Paste the handoff prompt into local Claude Code
  7. Claude Code builds AppLayout.tsx (or stack-equivalent) on branch chore/app-shell
  8. Review, merge to main
  9. Re-run /bmad-roadmap-v2 and answer [yes] to the pre-flight
  ```
- Record `app_shell.status: pending` + any URLs the user pasted
- Halt Phase 4 until the user returns with `[yes]`

**On `[skip]`:**
- Record `app_shell.status: none` in `design-progress.yaml`
- The choice is sticky — the orchestrator never re-asks unless the user manually edits `design-progress.yaml`
- Proceed to "The Loop" — all shell-related instructions are omitted in per-epic prompts

**Shell implementation — NOT a story.** The shell is infrastructure, not a user-facing feature:
- Branch: `chore/app-shell` (or `feat/app-shell-foundation`)
- No story file, no Kateb reviews, no Naqed, no retrospective
- Merge directly to `main` once reviewed
- It's tracked in `design-progress.yaml: app_shell` only, NOT in `sprint-status.yaml`

---

## The Loop

Iterate this sub-workflow for each epic. The orchestrator uses `_bmad-output/implementation-artifacts/design-progress.yaml` to track which epic is next.

### Sub-step A — Pick next epic

1. Read `design-progress.yaml`
2. If any epic has `status: in-progress` → resume that epic (prompt user: "Still working on Epic {X}? [continue/redo/skip]")
3. Else → pick the first epic with `status: pending` and start it
4. If all epics are `design-complete` → Phase 4 is done, exit to Phase 5

### Sub-step B — Prepare the Claude Design session

**Run:** `/bmad-claude-design-prep --epic={slug}` (skill added by this patch).

This skill:
1. Generates an **attachment checklist** — exact file paths to upload to Claude Design for this epic
2. Generates a **ready-to-paste prompt** for the Claude Design chat, including aesthetics guidance
3. Creates `design-process/claude-design-handoffs/<epic-slug>/bundle.md` with a template
4. Sets the epic's status in `design-progress.yaml` to `in-progress`

Print both the checklist and the prompt to the terminal. Tell the user:
> "Open claude.ai/design, create a new project for Epic {name}, upload these files, paste this prompt, iterate on designs, then come back when done."

### Sub-step C — Manual user work in Claude Design

The user does the work. The orchestrator waits. Expected activities:
- Create a new project in Claude Design named for the epic
- Upload the files from the checklist
- Paste the prompt
- Review Claude's generated designs
- Iterate via inline comments (small changes) and chat (structural changes)
- Ask Claude to show edge states (empty, error, loading, RTL)
- When satisfied: Export → Hand off to Claude Code
- Claude Design produces a bundle URL + a ready-to-paste prompt

### Sub-step D — User returns with handoff details

The user pastes the bundle URL and the handoff prompt into the terminal.

Write them into `design-process/claude-design-handoffs/<epic-slug>/bundle.md` — into the `Bundle URL` and `Prompt` sections.

Optionally, the user may add notes in the `Notes` section of `bundle.md` for any non-obvious decisions (gestures, conditional logic, constraints). This section is **optional** — leave empty if everything is visible from the design itself.

### Sub-step E — Sync from design

**Run:** `/bmad-sync-from-design --epic={slug}` (skill added by this patch).

This skill:
1. WebFetches the bundle URL, extracts the final screens
2. Reads the user's `bundle.md` Notes section (if any)
3. Performs deep comparison vs existing stories:
   - Screen-level: added / removed / merged / renamed
   - Section-level inside each screen: added / removed / modified
   - Component-level: changed / replaced
   - Copy / content: edited
   - State coverage: loading, empty, error, etc.
4. Propagates changes autonomously:
   - Updates story files (acceptance criteria, tasks, edge cases, Design Reference block)
   - Updates epic file (screen count, flow narrative)
   - Updates UX doc section if structural
   - Flags PRD-level conflicts (halts, asks user)
5. Marks the epic's status in `design-progress.yaml` as `design-complete`
6. Prints a human-readable diff summary

### Sub-step F — Advance

Return to Sub-step A and pick the next epic, until every epic is `design-complete`.

---

## Escape Hatches

### The design approach is fundamentally wrong

If during the loop the user realizes the journey structure is off (e.g., "Epic 3 should actually be split into two journeys"), invoke `/bmad-correct-course` (BMM native). It re-plans the affected phase without wiping completed epics.

### WebFetch cannot read the bundle URL

If the Claude Design bundle is JS-heavy and WebFetch returns empty content:
1. Ask the user to download the bundle as a ZIP from the Claude Design export menu
2. Save it to `design-process/claude-design-handoffs/<epic-slug>/bundle.zip`
3. Re-run `/bmad-sync-from-design --epic={slug} --bundle-zip=<path>`

---

## Phase Completion

Before marking Phase 4 complete, verify:
- [ ] Every epic in `design-progress.yaml` has `status: design-complete`
- [ ] Every epic has a `bundle_url` and a populated `bundle.md`
- [ ] Every story has the Design Reference block populated (added by sync)

Update progress file:

```yaml
4-claude-design-loop:
  status: complete
  completed: "{today}"
  epics_designed: 6
```

Announce completion and proceed to Phase 5.
