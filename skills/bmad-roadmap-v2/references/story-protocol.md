# Story Protocol (Phase 6)

Sub-workflow used by Phase 6 (Build). Full-stack per-story execution: one story = one screen + its API + its DB migration + its tests, all in one PR.

## Architecture

You are the orchestrator. You manage the checklist. Each step below tells you what to run and how (agent vs. skill) — follow it as written.

### Named Agents (inline)

All agent prompts live **inline in this file** — there is no separate `.claude/agents/*.md` file.

| Name | Role |
|------|------|
| **Saneh** | Full-stack builder — implements screen + API + DB + tests in one pass |
| **Naqed** | Visual + technical QA — Compliance check (vs design bundle) and Audit (a11y + perf). NO subjective Critique step. |

Code Quality steps (`/simplify`, `/bmad-code-review`, `/bmad-testarch-*`, type-check/lint/test verification) are invoked directly by the orchestrator via Skill tool or Bash. Do NOT wrap them in Agent calls.

**Agent return policy:** When Saneh or Naqed returns, print its full Return block verbatim to the user before proceeding. Do not paraphrase or summarize.

### Pause model (changed 2026-05-12)

- **One PAUSE per story** at Step 4 (User Review) — light visual + flow check on the already-cleaned screen
- **One PAUSE per epic** at the end (Epic Final Approval) — holistic walk-through of every story together before retro + trace
- Naqed runs BEFORE User Review (not after) so the user sees a clean implementation, not raw Saneh output
- The legacy "Critique" sub-step is removed entirely — the Claude Design bundle IS the approved visual; second-guessing it adds noise

---

## Epic-Level Wrapper

Before the first story of the FIRST epic of the project:
- Run `/bmad-testarch-framework` (BMM native) to set up the test framework
- Run `/bmad-testarch-ci` (BMM native) to set up CI test infrastructure
- Mark `roadmap-progress.yaml: phases.6-build.test_infra_done: true`

Subsequent epics skip this setup.

After the last story of EACH epic, run the **Epic Close-out** (separate section below) — this includes the per-epic User Final Approval.

When all epics are `complete`, Phase 6 is done; return to the orchestrator.

---

## Per-Story Loop

### On entry

Create this checklist via TodoWrite:

```
Step 1: Branch
Step 2: Saneh (Full-Stack Build)
Step 3: Naqed (Compliance + Audit, automated)
Step 4: User Review [PAUSE — light]
Step 5: Simplify
Step 6: Code Review
Step 7: PR Review (parallel)
Step 8: Verify
Step 9: Ship
```

### Step 1 — Branch

`git checkout -b feat/story-{X.Y}`. Mark done. Go to Step 2 in the same turn.

### Step 2 — Saneh — Full-Stack Build

Launch Agent with this prompt:

```
You are Saneh, full-stack builder. Context: Story {X.Y}, Story file: {path to story file}, Epic: {epic name and slug}.

Do exactly these steps:

1. Read the story file completely. Note the Design Reference block which contains:
   - Bundle URL (from Claude Design handoff)
   - Claude Design Project URL
   - Screen name within the bundle

2. Fetch the bundle via WebFetch:
   - Call WebFetch on the Bundle URL
   - Extract the screen named in the Design Reference block
   - If WebFetch returns thin/empty content (JS-heavy page), HALT and ask the user to download the bundle as a ZIP, place it at a known path, and re-run with that path.

3. Detect the project stack:
   - If `frontend/package.json` exists → frontend stack is Node (Next.js/Vite/etc.)
   - If `backend/composer.json` exists → backend stack is Laravel/PHP
   - If `package.json` at root (no frontend/ folder) → single-stack Node project
   - Use the detected stack for all build and verify commands below.

4. Build the screen using whatever layout / shell conventions are already established
   in the codebase. Claude Design carries shell consistency across chats within a
   project, so the bundle reflects the shell style the team has settled on. Match it.

5. Implement the story as a full-stack slice:
   a. UI — build the screen to match the design extracted from the bundle. Use the project's existing component library (from design system). Match the framework (Next.js page + components, Vue SFC, etc.).
   b. State — wire local state, global store (Redux/Zustand/Pinia), or React Query as appropriate.
   c. Routing — add route entries. Match the project's routing convention.
   d. i18n — add translation keys for all user-facing strings. Support AR + EN if the project is bilingual.
   e. API — implement the endpoint(s) the story needs (Laravel route + controller, Express endpoint, etc.).
   f. DB:
      - **Migration** — add new tables/columns the story needs. Include any reference data (enums, lookups, required-from-day-one records) directly in the migration.
      - **Dev seeder** — create or extend a seeder in `database/seeders/` that populates the dev DB with **5–20 realistic fake records** for this feature. The goal: when the user opens the screen in their browser, they see populated data without having to create records manually. Call the seeder from `DatabaseSeeder.php` so `php artisan db:seed` covers it.
      - **Factories** — if this story introduces a new model, add a factory in `database/factories/`. Factories power the dev seeder AND the automated tests — same source of fake data, different consumers.
   g. Tests — unit tests for the UI component and API controller, one happy-path E2E for the screen. Tests use factories (not seeders) for isolation.

6. Prepare the dev database for the user review:
   - If backend is Laravel: `cd backend && php artisan migrate:fresh --seed`
   - If backend is Node: run the equivalent seed command for the project's ORM (Prisma: `pnpm prisma migrate reset --force`, Drizzle: `pnpm db:push && pnpm db:seed`, etc.)
   - Confirm the dev DB now has the seed data visible in the screen.

7. Verify (stack-specific):
   - Node frontend: `cd frontend && pnpm tsc --noEmit && pnpm lint` (or at root if single-stack)
   - Laravel backend: `cd backend && php artisan test`
   - Single-stack projects: adapt commands to the detected stack.
   All commands must pass before returning.

Return:
Story file: <path>
Stack detected: <frontend=X, backend=Y>
Bundle fetched: <yes/no — from WebFetch or local ZIP>
Screens built: <list of URLs where the screen is accessible locally>
API endpoints: <method path list>
Migrations: <names or "none">
Dev seeder: <file path, N seed records added, or "none — no new data needed">
Factories: <names or "none">
Tests: <N passing>
Verify: TypeScript PASS, Lint PASS, Tests PASS

Test Checklist (for Step 4 User Review — derived from the story file):

  Happy path:
    - [ ] <AC 1 in plain language, e.g., "User sees the list of languages populated from DB">
    - [ ] <AC 2>
    ...

  Edge cases:
    - [ ] <Edge case 1 from the story, e.g., "Tapping a language stores it in localStorage">
    - [ ] <Edge case 2>
    ...

  States to verify:
    - [ ] Default view loads with seeded data
    - [ ] Loading state (throttle network in DevTools to simulate)
    - [ ] Empty state (temporarily truncate the seed table OR add a query param)
    - [ ] Error state (stop the API server OR inspect a broken endpoint)
    - [ ] Hover / focused / disabled (for interactive elements, if applicable)

  Interactions from design:
    - [ ] <Interaction 1 from the design / story, e.g., "Continue button navigates to /onboard/level">
    - [ ] <Interaction 2>
    ...

  Bilingual (only if project supports AR + EN):
    - [ ] Screen renders correctly in LTR (English)
    - [ ] Screen renders correctly in RTL (Arabic)
    - [ ] Language switcher toggles direction without reload

Generate the checklist items by reading the story's Acceptance Criteria, Edge Cases, Interactions, and Design Reference. Only include sections that apply — skip "Bilingual" for monolingual projects, skip "Empty state" if the data is guaranteed to always be non-empty, etc.
```

**When the agent returns, print its full Return block verbatim.**

When Saneh returns, mark done. Go to Step 3 in the same turn (no pause).

### Step 3 — Naqed — Visual + Technical QA (Compliance + Audit)

Launch Agent with this prompt:

```
You are Naqed, visual+technical QA agent. Context: Story {X.Y}, Screen URL: {url}, Bundle URL: {from story Design Reference}.

Execute these 2 sub-steps IN ORDER:

Sub-step 3a — Design Compliance Check:
1. Take a screenshot of the implemented screen at {screen URL} using Playwright MCP. Capture BOTH directionality variants if the project supports AR + EN (loop through {ar, en}).
2. Open the Bundle URL and take a screenshot of the corresponding screen (or use the static export if available).
3. Compare side-by-side. Report discrepancies at these levels:
   - Layout: column structure, spacing, alignment
   - Components: present/missing/substituted
   - Colors & typography: drift from design tokens
   - Interactions visible on screen (hover, disabled state)
   - Copy / content
4. For each discrepancy, classify as either:
   - IMPLEMENTATION BUG — fix in code
   - INTENTIONAL DEVIATION — note with reason (rare; should be flagged in the story file)
5. Apply IMPLEMENTATION BUG fixes directly. After fixes, re-run the screenshot capture and confirm the diff is resolved.

Sub-step 3b — Audit (a11y + perf):
1. Invoke `/audit` via Skill tool on the screen URL.
2. Apply all findings that are code-level fixes (add aria-labels, fix contrast, optimize asset sizes, lazy-load images, etc.).
3. Flag any systemic issues (e.g., "design system color contrast fails AA across multiple tokens") as escalations — do NOT silently change brand tokens.

DO NOT perform a "Critique" step. The Claude Design bundle is the approved visual. Compliance verifies the code matches that visual; Audit verifies a11y + perf. Subjective design opinions are out of scope here.

Return (exact format):

### Compliance (3a)
Discrepancies found: <N>
Fixed: <N>
Deviations kept: <N with reasons>
RTL/LTR parity checked: <yes/no/not-applicable>

### Audit (3b)
Findings: <N>
Fixed inline: <N>
Escalated: <list or "none">

### Summary
Total changes applied: <N>
Blockers for review: <list or "none">
```

**When the agent returns, print its full Return block verbatim.**

When Naqed returns, mark done. **PAUSE — go to Step 4.**

### Step 4 — User Review (light, per-story) [PAUSE]

Print the user-facing review block — includes the Test Checklist from Saneh's Return block plus Naqed's summary:

```
Story {X.Y} — automated checks done. Ready for your light review.

Screen(s):         {URLs from Saneh}
API endpoint(s):   {endpoints from Saneh}
Dev seed data:     {seeder file, N records — from Saneh}
Migrations:        {list or "none"}

Compliance:        {Naqed 3a summary — N fixes applied}
Audit:             {Naqed 3b summary — N fixes applied}

=== TEST CHECKLIST ===

{paste Saneh's Test Checklist verbatim — includes:
  Happy path, Edge cases, States, Interactions, Bilingual (if applicable)}

======================

Open the screen in your browser. The implementation has already been cleaned
by automated compliance + audit checks. Do a quick visual + flow review:
- Does the flow make sense?
- Is the copy clean (no Google-Translate Arabic, no placeholder text leaks)?
- Anything obviously broken?

Reply "continue" or "yes" → I proceed to Simplify + Code Review + Ship.
Reply with fixes (free-form) → I'll classify each and re-invoke Saneh.

You will get a deeper review opportunity at the END of this epic (Epic Final
Approval), where you'll walk through every shipped story together.
```

Wait for user response:
- `"continue"` → Mark done, go to Step 5.
- Fixes → Classify each (two-way):
  - **CONTENT-level** (copy, color tweak, component inside main area, minor behavior) → Re-invoke Saneh with fixes, re-enter Step 3 (Naqed re-runs to verify the fix didn't break anything else), then Step 4 again.
  - **JOURNEY-DESIGN-level** (layout of content area, new screen, rearranged sections, feature scope change) → See "Escape to Phase 4" below.

If the classification is ambiguous, ask the user once: "Is this a content tweak or a journey-design change?"

### Step 5 — Simplify

Invoke `/simplify` via Skill tool on the story's changes.

When it returns: mark done, go to Step 6 in the same turn. No summary, no pause.

### Step 6 — Code Review

Invoke `/bmad-code-review` via Skill tool with preamble:
> "auto-mode: story-protocol orchestrator — batch-apply all patches, apply severity gating to decision-needed (stop only on High-impact without spec answer), skip interactive HALTs."

When it returns: mark done, go to Step 7 in the same turn.

### Step 7 — PR Review (parallel)

Launch 3 agents in parallel (single message, 3 Agent tool calls):
- `pr-review-toolkit:code-reviewer`
- `pr-review-toolkit:silent-failure-hunter`
- `pr-review-toolkit:pr-test-analyzer`

When all three return, dedupe findings. For each finding:
- Fix it, OR
- Write a structured defer to `_bmad-output/implementation-artifacts/deferred-work.md` with `source: pr-review`, OR
- Dismiss with a one-line reason in the story file.

When fixes are applied: mark done, go to Step 8.

### Step 8 — Verify (stack-detected)

Run commands based on detected stack:

```bash
# Node frontend
if [ -d frontend ]; then
  cd frontend && pnpm tsc --noEmit && pnpm lint
fi

# Laravel backend
if [ -d backend ] && [ -f backend/composer.json ]; then
  cd backend && php artisan test
fi

# Single-stack Node (no frontend/ folder, package.json at root)
if [ -f package.json ] && [ ! -d frontend ]; then
  pnpm tsc --noEmit && pnpm lint && pnpm test
fi
```

If any command fails, fix the regression and re-run. When all pass: mark done, go to Step 9.

### Step 9 — Ship

Invoke `/ship` via Skill tool.

When it returns:
- Update `_bmad-output/implementation-artifacts/sprint-status.yaml` — set this story's status to `done`, increment `stories_completed`, clear `current_story`.
- Return control to the orchestrator to start the next story.

**No per-story Final Approval pause.** Final approval happens once per epic — see "Epic Close-out" below.

---

## Epic Close-out

After the last story of the epic ships:

### Step E1 — Epic Final Approval [PAUSE]

Print a per-epic walk-through:

```
Epic {N} — {Epic Name} — all {M} stories shipped.

Stories:
  {X.Y} — {one-line summary} — {screen URL or "backend-only"}
  ...

Walk through the full journey in your browser (start at the entry screen,
go through the flow end-to-end). Then reply:

  "approve epic"     → I run retrospective + test trace, then move to next epic
  Fixes (free-form)  → I classify each:
                        * CONTENT-level → re-invoke Saneh on the affected story
                        * JOURNEY-level → escape to Phase 4 for this epic
                                          (new chat in product project, re-sync)
```

Wait for user response:
- `"approve epic"` → Mark done, go to E2.
- Fixes:
  - **CONTENT-level** → for each affected story, re-invoke Saneh + Naqed + a quick re-ship. Then re-enter E1.
  - **JOURNEY-level** → see "Escape to Phase 4" below. After the epic is re-synced from Phase 4, re-run E1.

### Step E2 — Retrospective

Run `/bmad-retrospective` (BMM native).

### Step E3 — Test Trace

Run `/bmad-testarch-trace` (BMM native).

### Step E4 — Mark epic complete

Update `roadmap-progress.yaml`:
```yaml
phases:
  6-build:
    epics:
      <N>:
        status: complete
        retro_done: true
```

Advance `current_epic` to the next pending epic.

If all epics are complete, Phase 6 is done — proceed to Phase 7.

---

## Escape to Phase 4 (journey design)

Triggered from Step 4 or Epic Close-out E1 if the user requests a **JOURNEY-DESIGN-level** change (layout, new screen, rearranged sections, header/sidebar/nav rework).

1. Print: "This change affects the journey design. Returning to Phase 4 for Epic {epic}."
2. Open `_bmad-output/implementation-artifacts/design-progress.yaml`.
3. Set this epic's `status` back to `in-progress`.
4. Record: `notes: "Phase 6 surfaced journey-level design issue: {description}"`.
5. Soft-keep the affected story branch(es) — ask user if they want to discard or hold.
6. Instruct the user: "Open the product Claude Design project ({product_project.url}) and start a new chat (or continue the existing epic chat). Iterate on the design. When done, paste the new bundle URL into bundle.md."
7. Run `/bmad-sync-from-design --epic={slug}` to re-sync the stories.
8. Return to Phase 6 at the affected story (re-run from Step 1 with refreshed Design Reference). If multiple stories need rework, run them in sequence.

Because all journey chats live inside the SAME product project, header/sidebar/nav-level rework propagates as conventions across chats automatically — no separate "app shell" workflow needed.
