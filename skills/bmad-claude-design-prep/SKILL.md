---
name: bmad-claude-design-prep
description: "Prepare a Claude Design session for a specific epic — generate the attachment checklist, the ready-to-paste prompt, and the handoff landing file. Use when the user says 'prep claude design', 'prepare claude design for epic X', 'next epic to design', or when invoked by the /bmad-roadmap-v2 Phase 4 loop. The skill does NOT do the design work itself (that's manual in claude.ai/design); it packages everything the user needs to paste and upload, then creates the target file where the user pastes the handoff result."
---

# BMAD Claude Design Prep

## Overview

Phase 4 of the roadmap is a per-epic loop: design every screen of an epic in Claude Design, export a handoff bundle, sync the changes back. This skill handles the **prep step** before the user opens a browser — it collects all the context, generates a prompt, and prepares the landing file where the user will paste the handoff result.

## Args

```
/bmad-claude-design-prep --epic=<slug>
  [--prd <path>]                       # default: _bmad-output/planning-artifacts/prd.md
  [--ux-doc <path>]                    # default: _bmad-output/planning-artifacts/ux-design-specification.md
  [--epics-dir <path>]                 # default: _bmad-output/implementation-artifacts/epics/
  [--stories-dir <path>]               # default: _bmad-output/implementation-artifacts/stories/
  [--design-system-ref <path>]         # optional — a human-readable design system file (e.g. design-system.md)
```

## Pipeline

### 1. Load inputs

- Read `epics/<slug>.md` — get epic name, description, and list of stories
- Read each story file in `stories/` that belongs to this epic (prefix match or explicit reference in epic file)
- Read relevant section of `ux-design-specification.md` (journey section matching the epic)
- Read relevant section(s) of `prd.md` (FR references mentioned in the stories)
- Read `_bmad-output/implementation-artifacts/design-progress.yaml` and note `app_shell.status` + `app_shell.layout_component_path` — this controls how the checklist and prompt are rendered

### 1b. App shell status gate

- If `app_shell.status == "pending"` → HALT with error: "Phase 4 pre-flight was not completed. Run `/bmad-roadmap-v2` and answer the App Shell pre-flight question first." Do not generate checklist or prompt.
- If `app_shell.status == "implemented"` → render the REQUIRED codebase attachment line in the checklist AND include the "App shell constraint" block in the prompt. Substitute `{{layout_component_path}}` with the recorded path.
- If `app_shell.status == "none"` → render the OPTIONAL codebase attachment line in the checklist (softer wording) AND leave the "App shell constraint" block empty in the prompt. No shell instructions propagate.

### 2. Build the attachment checklist

Produce a terminal-printable checklist listing exactly which files to upload to Claude Design. Format:

```
╔══════════════════════════════════════════════════════════════════╗
║ CLAUDE DESIGN — ATTACHMENTS CHECKLIST                              ║
║ Epic: <slug> — <name>                                              ║
╠══════════════════════════════════════════════════════════════════╣
║ Upload these files to your Claude Design project:                 ║
║                                                                    ║
║  1. {project-root}/_bmad-output/planning-artifacts/prd.md         ║
║     (full PRD — Claude will use the FRs relevant to this epic)    ║
║                                                                    ║
║  2. {project-root}/_bmad-output/planning-artifacts/                ║
║     ux-design-specification.md                                     ║
║     (full UX doc — Claude will reference the journey section)      ║
║                                                                    ║
║  3. {project-root}/_bmad-output/implementation-artifacts/         ║
║     epics/<slug>.md                                                ║
║     (this epic's definition)                                       ║
║                                                                    ║
║  4. Stories (<N> files):                                          ║
║     - stories/<story-1>.md                                        ║
║     - stories/<story-2>.md                                        ║
║     ... etc                                                        ║
║                                                                    ║
║  OPTIONAL:                                                         ║
║  5. Your project's design-system.md or equivalent                 ║
║     (skip if design system is already attached org-level)         ║
║                                                                    ║
║  6. Reference screenshots (inspiration, existing screens)         ║
╚══════════════════════════════════════════════════════════════════╝
```

### 3. Build the prompt

Produce a **ready-to-paste prompt** using the template in `references/prompt-template.md`. The template includes:

- Epic name and context
- Screen list with brief purpose for each (extracted from story files)
- Platform / viewport / language requirements (from UX doc)
- Role/permission context (from PRD / stories)
- Aesthetics guidance (embedded from Anthropic cookbook — avoid "AI slop", distinctive typography, non-generic colors, etc.)
- Explicit request for edge states (loading, empty, error, RTL if applicable)

Print the prompt in a fenced block so the user can copy it cleanly:

```
╔══════════════════════════════════════════════════════════════════╗
║ PASTE THIS INTO CLAUDE DESIGN CHAT:                                ║
╚══════════════════════════════════════════════════════════════════╝

<...prompt content...>

╔══════════════════════════════════════════════════════════════════╗
║ END — copy everything between the banners above                    ║
╚══════════════════════════════════════════════════════════════════╝
```

### 4. Create the handoff landing file

Create `design-process/claude-design-handoffs/<epic-slug>/bundle.md` using the template in `../../templates/bundle.md`. Pre-fill:
- Epic name
- Date (today)
- Screens list (from stories)

Leave blank:
- Bundle URL (user pastes after handoff)
- Claude Design Project URL (user pastes)
- Prompt (user pastes the handoff prompt from Claude Design)
- Notes (optional)

Create parent directories if absent.

### 5. Update design-progress.yaml

Update `_bmad-output/implementation-artifacts/design-progress.yaml`:
- Create the entry for this epic if missing
- Set `status: in-progress`
- Set `started: <today-ISO-date>`

### 6. Print next instructions to the user

After printing the checklist and prompt:

```
NEXT STEPS:
1. Open claude.ai/design in your browser.
2. Create a new project named "<Epic Name>".
3. Upload the files from the checklist above.
4. Paste the prompt above into the chat.
5. Iterate on the designs until satisfied.
6. Export → "Hand off to Claude Code".
7. Copy the bundle URL and handoff prompt Claude Design gives you.
8. Paste them into: design-process/claude-design-handoffs/<epic-slug>/bundle.md
9. Return here and run: /bmad-sync-from-design --epic=<epic-slug>
```

## Idempotency

If called twice for the same epic:
- If `bundle.md` already exists and has a populated Bundle URL → prompt user: "Epic already has a handoff bundle. Re-prep? [yes/no]"
- If user says yes → re-generate prompt + checklist (keeps existing bundle.md, appends new prep timestamp)
- Never overwrite an existing Bundle URL

## References

- `references/prompt-template.md` — the full prompt template with aesthetics guidance
- `references/attachment-checklist-template.md` — the checklist layout
- `../../templates/bundle.md` — the template copied to `design-process/claude-design-handoffs/<epic-slug>/`

## Non-goals

- Does NOT open a browser or automate Claude Design work
- Does NOT read the PRD or UX doc deeply — just identifies which files to attach
- Does NOT wait for the user's handoff result; that's a separate step (`/bmad-sync-from-design`)
