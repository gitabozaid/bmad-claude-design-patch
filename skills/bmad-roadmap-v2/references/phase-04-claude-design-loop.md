# Phase 4: Per-Epic Claude Design Loop

**Goal:** For each epic, design every screen in [Claude Design](https://claude.ai/design), export a handoff bundle, and propagate design changes back to stories/epic/UX doc (and PRD if scope shifted). This is the **only** phase with manual user work in a browser.

**Exit condition:** Every epic in `design-progress.yaml` has `status: design-complete` and a `bundle_url` set.

---

## Mental Model

Claude Design's project structure is hierarchical:

```
Organization (e.g., "Baseir")
  ├─ Design System  ────────────  one-time setup, inherited org-wide
  └─ Project (one per app)
     ├─ Project-level files  ──  stable docs uploaded ONCE (PRD, UX spec, Architecture, epics list)
     └─ Chats  ────────────────  one chat per epic / journey
        └─ Chat-level uploads  ──  ONLY the stories for that epic
```

**Three mutual benefits of this layout:**
1. **One project per product, not per epic.** The Baseir Claude Design project hosts all journeys as separate chats. Files stay attached at the project level once.
2. **Stable docs upload once.** The PRD, UX spec, and Architecture rarely change. They sit at the project level and every chat inherits them.
3. **Stories upload per-epic.** Stories DO change (sync from design can rewrite acceptance criteria). Re-uploading the latest version with each new epic chat prevents stale-story drift.

**No standalone "00 — App Shell" project.** Claude Design's projects share design system state automatically; the shell concept evolves inside the journey/epic chats and is captured in the handoff bundles. There is no separate shell pre-flight.

---

## One-Time Setup (before the loop starts)

### Setup 1 — Org-level Design System

Done once per organization, then inherited by all projects:

1. Open [claude.ai/design](https://claude.ai/design) → top-left org switcher → use or create the organization for this product.
2. Open the org's **Design System** section.
3. Upload the design system inputs. The canonical set for any BMM-built product:
   - **`tokens.css`** — Tailwind v4 CSS variables (canonical color / spacing / radius / typography tokens)
   - **`design-system-brief.md`** — brand identity, anti-patterns, aesthetic guardrails (1 page)
   - **`typography-specimens.md`** — type scale specimens for each font in the stack
   - **`component-inventory.md`** — list of expected components (Tier 2 + Tier 3) the product will need
   - **`fonts/*.woff2`** — self-hosted font files for every weight + script the product uses
   - **`fonts/fonts.css`** — `@font-face` declarations referencing the woff2 files (with proper `unicode-range`)
   - Optionally: GitHub repo URL if the design system is published as a standalone repo
4. Wait ~5–10 minutes for Claude Design to generate previews, brand wordmark, UI kit cards.
5. Toggle **Published** so every project in the org inherits the design system.
6. (Optional) Toggle **Default** if this is the org's primary design system.

**Sanity-check the extraction** — open the auto-generated preview cards (Color · Primary, Type · Headings, Component · Project card, etc.) and confirm tokens were parsed correctly. If a section looks wrong, click **Needs work…** and tell Claude Design what's off. Use the per-card "Looks good" / "Needs work…" feedback to refine.

**Do this step ONCE per product.** Subsequent journey chats reuse this setup.

### Setup 2 — Create the Product Project

Done once per product:

1. From the Claude Design homescreen, click **+ Create new design** (or **Use this system → ↗ New design** from the design system page).
2. Project name: **the product name** (e.g., "Baseir"). NOT an epic name.
3. Design system: pick the org-level system you just published.
4. Choose **High fidelity + Interactive prototype**.
5. Click **Create**. The project opens with a "Start with context" sidebar and a chat textarea.
6. Upload the **project-level stable docs** ONCE (drag-drop into the chat or use Import → file picker). These are the docs every chat will inherit:
   - `_bmad-output/planning-artifacts/prd.md`
   - `_bmad-output/planning-artifacts/ux-design-specification.md`
   - `_bmad-output/planning-artifacts/architecture.md`
   - `_bmad-output/planning-artifacts/epics.md`
   - (Optional) `_bmad-output/planning-artifacts/product-brief-*.md`
7. Send a brief first message confirming the upload: "These are the stable project docs (PRD + UX + Architecture + Epics list). I'll start individual chats per epic with epic-specific story files. Acknowledge and wait."
8. After Claude Design acknowledges, **Start a new chat** (top-right + button). The project-level docs stay attached; each new chat inherits them.

Record the project URL in `_bmad-output/implementation-artifacts/design-progress.yaml: design_system.product_project_url`.

---

## The Loop

Iterate this sub-workflow for each epic. The orchestrator uses `_bmad-output/implementation-artifacts/design-progress.yaml` to track which epic is next.

### Sub-step A — Pick next epic

1. Read `design-progress.yaml`.
2. If any epic has `status: in-progress` → resume that epic (prompt user: "Still working on Epic {X}? [continue/redo/skip]").
3. Else → pick the first epic with `status: pending` and start it.
4. If all epics are `design-complete` → Phase 4 is done, exit to Phase 5.

### Sub-step B — Prepare the Claude Design session

**Run:** `/bmad-claude-design-prep --epic={slug}` (skill added by this patch).

This skill:
1. Generates a **chat-level attachment checklist** — ONLY the epic's stories (the stable docs are already at project level)
2. Generates a **ready-to-paste prompt** for the new chat, including aesthetics guidance and explicit mentions of the project-level docs to consult
3. Creates `design-process/claude-design-handoffs/<epic-slug>/bundle.md` with a template
4. Sets the epic's status in `design-progress.yaml` to `in-progress`

Print both the checklist and the prompt to the terminal. Tell the user:
> "Inside the existing Baseir project, click **+ Start a new chat**. Name the chat after the epic. Upload the files from the checklist (stories only — the PRD/UX/Architecture are already at project level). Paste the prompt. Iterate on designs. Return when done."

### Sub-step C — Manual user work in Claude Design

The user does the work. The orchestrator waits. Expected activities:
- Start a new chat inside the existing product project
- Upload the epic's story files from the checklist
- Paste the prompt
- Review Claude's generated designs
- Iterate via inline comments (small changes) and chat replies (structural changes)
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

**Story version-drift safety:** Because stories are uploaded per-chat (not at the project level), the next epic's chat will get the freshly-synced versions of any cross-referenced stories. No stale-story conflicts.

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

### A previous epic's stories need re-syncing

If Sub-step E modified stories that cross an epic boundary (e.g., a global validation rule lives in Epic 1's auth story but Epic 4's checkout uses it), the local copy is now newer than any prior Claude Design chat where that story was uploaded. **This is fine** — the next chat (Sub-step C of the next epic) re-uploads stories from the local filesystem, so the new chat always sees the latest version. No action needed.

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
