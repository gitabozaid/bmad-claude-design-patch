---
name: bmad-claude-design-prep
description: "Prepare a Claude Design session for a specific epic — generate the chat-level attachment checklist, the ready-to-paste prompt, and the handoff landing file. Use when the user says 'prep claude design', 'prepare claude design for epic X', 'next epic to design', or when invoked by the /bmad-roadmap-v2 Phase 4 loop. The skill does NOT do the design work itself (that's manual in claude.ai/design); it packages everything the user needs to paste and upload, then creates the target file where the user pastes the handoff result."
---

# BMAD Claude Design Prep

## Overview

Phase 4 of the roadmap is a per-epic loop: design every screen of an epic in Claude Design, export a handoff bundle, sync the changes back. This skill handles the **prep step** before the user opens a browser — it collects all the context, generates a prompt, and prepares the landing file where the user will paste the handoff result.

## Mental Model: project-level vs chat-level uploads

Phase 4 uses ONE Claude Design project for the entire product. Inside that project:

- **Project-level uploads** (uploaded ONCE during Phase 4 setup, inherited by all chats):
  PRD, UX spec, Architecture, Epics list, optional product brief.
- **Chat-level uploads** (uploaded per-epic chat, this skill emits the checklist):
  ONLY the story files for this epic.

This skill emits the chat-level checklist + prompt for the user to paste into a new chat inside the existing project. It does NOT re-list the project-level docs (they're already attached) — the prompt mentions them by name so Claude Design knows to consult them.

There is **no separate "00 — App Shell" project**. Claude Design carries shell consistency across chats within a project; shell evolution happens organically inside the journey/epic chats.

## Args

```
/bmad-claude-design-prep --epic=<slug>
  [--prd <path>]                       # default: _bmad-output/planning-artifacts/prd.md
  [--ux-doc <path>]                    # default: _bmad-output/planning-artifacts/ux-design-specification.md
  [--epics-file <path>]                # default: _bmad-output/planning-artifacts/epics.md (or epics-dir if shard)
  [--stories-dir <path>]               # default: _bmad-output/implementation-artifacts/stories/
  [--design-system-ref <path>]         # optional — for sanity check that the org-level design system covers this epic's needs
```

## Pipeline

### 1. Load inputs

- Read the epic from `epics.md` (or `epics/<slug>.md` if sharded) — get epic name, description, FRs covered, and list of stories
- Read each story file in `stories/` that belongs to this epic (prefix match like `2.*.md` for `epic-2-...`)
- Read relevant section of `ux-design-specification.md` (journey section matching the epic) for context summary
- Read `_bmad-output/implementation-artifacts/design-progress.yaml` and confirm `design_system.status == "published"` and `design_system.product_project_url` is set
  - If `design_system.status != "published"` → HALT with error: "Org-level design system is not published. Complete Phase 4 Setup 1 (publish design system) before running this skill."
  - If `design_system.product_project_url` is missing → HALT with error: "Product-level Claude Design project URL is missing. Complete Phase 4 Setup 2 (create product project + upload stable docs) and record the URL in design-progress.yaml."

### 2. Build the chat-level attachment checklist

Only the epic's stories. The stable docs (PRD, UX, Architecture, epics list) are at project level already.

Format from `references/attachment-checklist-template.md`:

```
╔══════════════════════════════════════════════════════════════════╗
║ CLAUDE DESIGN — CHAT ATTACHMENTS CHECKLIST                         ║
║ Epic: <slug> — <name>                                              ║
║ Inside: <product-project-url>                                      ║
╠══════════════════════════════════════════════════════════════════╣
║ Project-level docs already attached (do NOT re-upload):            ║
║   ✓ prd.md                                                         ║
║   ✓ ux-design-specification.md                                     ║
║   ✓ architecture.md                                                ║
║   ✓ epics.md                                                       ║
║                                                                    ║
║ Upload these to the new chat:                                      ║
║                                                                    ║
║  [ ] Stories for this epic (<N> files — latest versions from disk):║
║      - stories/<story-1>.md                                        ║
║      - stories/<story-2>.md                                        ║
║      ... etc                                                       ║
║                                                                    ║
║ OPTIONAL:                                                          ║
║  [ ] Reference screenshots (inspiration, competitor screens)       ║
║                                                                    ║
║ NOTE: stories must be uploaded fresh in every new chat — they      ║
║       may have been updated by a prior /bmad-sync-from-design run. ║
╚══════════════════════════════════════════════════════════════════╝
```

### 3. Build the prompt

Produce a **ready-to-paste prompt** using the template in `references/prompt-template.md`. The template includes:

- Epic name and context
- Explicit reference to the project-level docs (prd.md, ux-design-specification.md, architecture.md, epics.md) by name so Claude Design knows to consult them
- Screen list with brief purpose for each (extracted from story files)
- Platform / viewport / language requirements (from UX doc)
- Role/permission context (from PRD / stories)
- Aesthetics guidance (embedded from Anthropic cookbook — avoid "AI slop", distinctive typography, non-generic colors, etc.)
- Explicit request for edge states (loading, empty, error, RTL if applicable)

Print the prompt in a fenced block so the user can copy it cleanly:

```
╔══════════════════════════════════════════════════════════════════╗
║ PASTE THIS INTO THE NEW CHAT (inside the product project):         ║
╚══════════════════════════════════════════════════════════════════╝

<...prompt content...>

╔══════════════════════════════════════════════════════════════════╗
║ END — copy everything between the banners above                    ║
╚══════════════════════════════════════════════════════════════════╝
```

### 4. Create the handoff landing file

Create `design-process/claude-design-handoffs/<epic-slug>/bundle.md` using the template. Pre-fill:
- Epic name
- Date (today)
- Screens list (from stories)

Leave blank:
- Bundle URL (user pastes after handoff)
- Claude Design Chat URL (user pastes — the chat URL inside the product project, not a new project)
- Prompt (user pastes the handoff prompt from Claude Design)
- Notes (optional)

Create parent directories if absent.

### 5. Update design-progress.yaml

Update `_bmad-output/implementation-artifacts/design-progress.yaml`:
- Create the entry for this epic if missing
- Set `status: in-progress`
- Set `started: <today-ISO-date>`
- Leave `chat_url` blank — the user fills it after they create the chat

### 6. Print next instructions to the user

After printing the checklist and prompt:

```
NEXT STEPS:

1. Open the existing product project in Claude Design:
   <product-project-url>

2. Start a new chat in that project (top-right + button or "New chat" prompt
   when context exceeds 100k tokens).

3. Name the chat "<Epic Name>".

4. Upload the stories from the checklist above (chat-level). DO NOT re-upload
   the project-level docs — they're already attached.

5. Paste the prompt into the chat.

6. Iterate on designs until satisfied.

7. Export → "Hand off to Claude Code".

8. Copy the bundle URL and handoff prompt Claude Design gives you.

9. Paste them into:
   design-process/claude-design-handoffs/<epic-slug>/bundle.md

10. Return here and run:
    /bmad-sync-from-design --epic=<epic-slug>
```

## Idempotency

If called twice for the same epic:
- If `bundle.md` already exists and has a populated Bundle URL → prompt user: "Epic already has a handoff bundle. Re-prep? [yes/no]"
- If user says yes → re-generate prompt + checklist (keeps existing bundle.md, appends new prep timestamp)
- Never overwrite an existing Bundle URL

## References

- `references/prompt-template.md` — the full prompt template with aesthetics guidance
- `references/attachment-checklist-template.md` — the chat-level checklist layout

## Non-goals

- Does NOT open a browser or automate Claude Design work
- Does NOT re-list project-level docs (they're already attached at the project level)
- Does NOT enforce any shell/AppLayout constraint — Claude Design maintains shell consistency across chats organically
- Does NOT read the PRD or UX doc deeply — just identifies which story files to attach
- Does NOT wait for the user's handoff result; that's a separate step (`/bmad-sync-from-design`)
