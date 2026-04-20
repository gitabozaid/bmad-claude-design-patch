---
deferred_work_file: '{implementation_artifacts}/deferred-work.md'
---

# Step 4: Present and Act

## RULES

- YOU MUST ALWAYS SPEAK OUTPUT in your Agent communication style with the config `{communication_language}`
- When `{spec_file}` is set, always write findings to the story file before offering action choices.
- `decision-needed` findings must be resolved before handling `patch` findings.

## INSTRUCTIONS

### 1. Clean review shortcut

If zero findings remain after triage (all dismissed or none raised): state that and proceed to section 6 (Sprint Status Update).

### 2. Write findings to the story file

If `{spec_file}` exists and contains a Tasks/Subtasks section, append a `### Review Findings` subsection. Write all findings in this order:

1. **`decision-needed`** findings (unchecked):
   `- [ ] [Review][Decision] <Title> — <Detail>`

2. **`patch`** findings (unchecked):
   `- [ ] [Review][Patch] <Title> [<file>:<line>]`

3. **`defer`** findings (checked off, marked deferred):
   `- [x] [Review][Defer] <Title> [<file>:<line>] — deferred, pre-existing`

Also append each `defer` finding to `{deferred_work_file}` under a heading `## Deferred from: code review ({date})`. If `{spec_file}` is set, include its basename in the heading (e.g., `code review of story-3.3 (2026-03-18)`).

**Each entry MUST use the structured defer schema** (silent skips are forbidden by the project's story protocol):

```
- id: <finding ID, e.g. C1, H3, M2>
  severity: <Critical | High | Medium | Low>
  reason: <pre-existing | phase-8-backend | architectural-scope | infrastructure-pending>
  justification: <1-2 concrete sentences explaining why it cannot be fixed in this story>
  location: <file:line>
  source: code-review
```

Allowed `reason` enum values:
- `pre-existing` — the bug is in code outside the current `git diff`. Justification must name the untouched file/section.
- `phase-8-backend` — requires real backend behavior to reproduce or test. Justification must name the missing backend behavior.
- `architectural-scope` — fix requires decisions touching code beyond the story. Justification must name the scope; the orchestrator should also open a follow-up story.
- `infrastructure-pending` — the right fix is blocked on missing observability/metrics/data. Justification must name exactly what is missing.

If a finding cannot be written with one of these four reasons, it must be fixed instead — do not invent new reasons, and do not use phrases like "low priority," "low ROI," "minor," or "not user-facing."

### 3. Present summary

Announce what was written:

> **Code review complete.** <D> `decision-needed`, <P> `patch`, <W> `defer`, <R> dismissed as noise.

If `{spec_file}` is set, add: `Findings written to the review findings section in {spec_file}.`
Otherwise add: `Findings are listed above. No story file was provided, so nothing was persisted.`

### 4. Resolve decision-needed findings

**Auto-mode detection:** If the caller is an orchestrator/agent running the BMAD story protocol (invoked from a named agent like Kateb/Banna/Haddad, from the story-protocol.md Code Review step, or with a preamble message like "auto-mode" / "story-protocol"), skip the HALT in this section and apply the severity gating from `.claude/skills/bmad-roadmap/references/story-protocol.md` directly:

- **Spec is definitive** → auto-decide per the spec. Log choice to `{deferred_work_file}`.
- **No spec + Low/Medium impact** → auto-decide (safer option / existing pattern). Log choice.
- **No spec + High impact (user-visible flow, business rule, pricing, content, feature scope)** → this is the ONLY case that HALTs. Present the options and wait for the user's numbered choice.

Otherwise (interactive human invocation, no orchestrator context): present each `decision_needed` finding to the user with options and HALT for each one.

If a finding becomes `defer` (either through auto-decision or user choice): append a structured entry to `{deferred_work_file}` using the schema documented in `deferred-work.md` (id, severity, reason, justification, location, source). Silent skips are forbidden by the project's story protocol.

**Interactive HALT (only when not in auto-mode and decision-needed findings exist):** I am waiting for your numbered choice. Reply with only the number (or "0" for batch). Do not proceed until you select an option.

### 5. Handle `patch` findings

**Auto-mode:** If invoked from the orchestrator / story-protocol / a named agent, **skip the HALT and auto-select Option 0 (Batch-apply all)** unconditionally. Apply all patches, then present a summary. No per-finding confirmation. This is the only sane behavior when the caller is an automated pipeline — the user is not sitting at the keyboard for each review.

**Interactive mode:** If the caller is a human running `/bmad-code-review` directly (no orchestrator context, no story protocol, no named agent wrapping this), HALT and present the options below.

If `{spec_file}` is set, present all three options (if >3 `patch` findings exist, also show option 0):

> **How would you like to handle the <Z> `patch` findings?**
> 0. **Batch-apply all** — automatically fix every non-controversial patch (recommended when there are many)
> 1. **Fix them automatically** — I will apply fixes now
> 2. **Leave as action items** — they are already in the story file
> 3. **Walk through each** — let me show details before deciding

If `{spec_file}` is **not** set, present only options 1 and 3 (omit option 2 — findings were not written to a file). If >3 `patch` findings exist, also show option 0:

> **How would you like to handle the <Z> `patch` findings?**
> 0. **Batch-apply all** — automatically fix every non-controversial patch (recommended when there are many)
> 1. **Fix them automatically** — I will apply fixes now
> 2. **Walk through each** — let me show details before deciding

**Interactive HALT (only when not in auto-mode):** I am waiting for your numbered choice. Reply with only the number (or "0" for batch). Do not proceed until you select an option.

- **Option 0** (auto-mode default, and manual >3 findings): Apply all non-controversial patches without per-finding confirmation. Skip any finding that requires judgment. Present a summary of changes made and any skipped findings.
- **Option 1**: Apply each fix. After all patches are applied, present a summary of changes made. If `{spec_file}` is set, check off the items in the story file.
- **Option 2** (only when `{spec_file}` is set): Done — findings are already written to the story.
- **Walk through each**: Present each finding with full detail, diff context, and suggested fix. After walkthrough, re-offer the applicable options above.

  **Interactive HALT (only when not in auto-mode):** I am waiting for your numbered choice. Reply with only the number (or "0" for batch). Do not proceed until you select an option.

**✅ Code review actions complete**

- Decision-needed resolved: <D>
- Patches handled: <P>
- Deferred: <W>
- Dismissed: <R>

### 6. Update story status and sync sprint tracking

Skip this section if `{spec_file}` is not set.

#### Determine new status based on review outcome

- If all `decision-needed` and `patch` findings were resolved (fixed or dismissed) AND no unresolved HIGH/MEDIUM issues remain: set `{new_status}` = `done`. Update the story file Status section to `done`.
- If `patch` findings were left as action items, or unresolved issues remain: set `{new_status}` = `in-progress`. Update the story file Status section to `in-progress`.

Save the story file.

#### Sync sprint-status.yaml

If `{story_key}` is not set, skip this subsection and note that sprint status was not synced because no story key was available.

If `{sprint_status}` file exists:

1. Load the FULL `{sprint_status}` file.
2. Find the `development_status` entry matching `{story_key}`.
3. If found: update `development_status[{story_key}]` to `{new_status}`. Update `last_updated` to current date. Save the file, preserving ALL comments and structure including STATUS DEFINITIONS.
4. If `{story_key}` not found in sprint status: warn the user that the story file was updated but sprint-status sync failed.

If `{sprint_status}` file does not exist, note that story status was updated in the story file only.

#### Completion summary

> **Review Complete!**
>
> **Story Status:** `{new_status}`
> **Issues Fixed:** <fixed_count>
> **Action Items Created:** <action_count>
> **Deferred:** <W>
> **Dismissed:** <R>

### 7. Next steps

**Auto-mode:** If invoked from the orchestrator / story-protocol / a named agent, skip this section entirely and return control to the caller with the completion summary above. The orchestrator owns what happens next (typically PR review, then verify, then Mir'a, then ship).

**Interactive mode:** Present the user with follow-up options:

> **What would you like to do next?**
> 1. **Start the next story** — run `dev-story` to pick up the next `ready-for-dev` story
> 2. **Re-run code review** — address findings and review again
> 3. **Done** — end the workflow

**Interactive HALT (only when not in auto-mode):** I am waiting for your choice. Do not proceed until the user selects an option.
