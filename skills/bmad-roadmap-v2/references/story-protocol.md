# Story Protocol (Phase 6)

Sub-workflow used by Phase 6 (Build). Full-stack per-story execution: one story = one screen + its API + its DB migration + its tests, all in one PR.

## Architecture

You are the orchestrator. You manage the checklist. Each step below tells you what to run and how (agent vs. skill) — follow it as written.

### Named Agents (inline)

All agent prompts live **inline in this file** — there is no separate `.claude/agents/*.md` file. This matches the refactor pattern from the v1 patch (commit `aa8d9d5`).

| Name | Role |
|------|------|
| **Saneh** | Full-stack builder — implements screen + API + DB + tests in one pass |
| **Naqed** | Visual QA — design compliance + critique + audit in that order |

Code Quality steps (`/simplify`, `/bmad-code-review`, `/bmad-testarch-*`, type-check/lint/test verification) are invoked directly by the orchestrator via Skill tool or Bash. Do NOT wrap them in Agent calls.

**Agent return policy:** When Saneh or Naqed returns, print its full Return block verbatim to the user before proceeding. Do not paraphrase or summarize.

---

## Epic-Level Wrapper

Before the first story of the FIRST epic of the project:
- Run `/bmad-testarch-framework` (BMM native) to set up the test framework
- Run `/bmad-testarch-ci` (BMM native) to set up CI test infrastructure
- Mark `roadmap-progress.yaml: phases.6-build.test_infra_done: true`

Subsequent epics skip this setup.

After the last story of EACH epic:
- Run `/bmad-retrospective` (BMM native)
- Run `/bmad-testarch-trace` (BMM native) to trace test coverage
- Update `roadmap-progress.yaml`: mark this epic `complete`; advance `current_epic`

When all epics are `complete`, Phase 6 is done; return to the orchestrator.

---

## Per-Story Loop

### On entry

Create this checklist via TodoWrite:

```
Step 1: Branch
Step 2: Saneh (Full-Stack Build)
Step 3: User Review [PAUSE]
Step 4: Naqed (Compliance → Critique → Audit)
Step 5: User Final Approval [PAUSE]
Step 6: Simplify
Step 7: Code Review
Step 8: PR Review (parallel)
Step 9: Verify
Step 10: Ship
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

4. Check the app shell status (read `design-progress.yaml: app_shell.status`):
   - If `implemented`: the app shell lives at `{app_shell.layout_component_path}`. Import AppLayout (or the project's shell equivalent) and wrap your new screen inside it. DO NOT modify AppLayout, Header, Footer, or Navigation. Build ONLY the content that goes inside the main area of the shell.
   - If `none`: the product has no persistent shell. Build the screen directly — no wrapper required.

5. Implement the story as a full-stack slice:
   a. UI — build the screen to match the design extracted from the bundle. Use the project's existing component library (from design system). Match the framework (Next.js page + components, Vue SFC, etc.). If app shell is implemented, wrap the content as noted above.
   b. State — wire local state, global store (Redux/Zustand/Pinia), or React Query as appropriate.
   c. Routing — add route entries. Match the project's routing convention.
   d. i18n — add translation keys for all user-facing strings. Support AR + EN if the project is bilingual.
   e. API — implement the endpoint(s) the story needs (Laravel route + controller, Express endpoint, etc.).
   f. DB — add migrations if the story needs new tables/columns. Seed data if applicable.
   g. Tests — unit tests for the UI component and API controller, one happy-path E2E for the screen.

6. Verify (stack-specific):
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
Tests: <N passing>
Verify: TypeScript PASS, Lint PASS, Tests PASS
```

**When the agent returns, print its full Return block verbatim.**

When Saneh returns, note the screens' URLs. Mark done. **PAUSE — go to Step 3.**

### Step 3 — User Review

Tell the user:

```
Story {X.Y} done.
Screen(s): {URLs from Saneh}
API: {endpoints from Saneh}

Review the screen in your browser. Say "continue" when done, or tell me fixes.
```

Wait for user response:
- `"continue"` → Mark done, go to Step 4.
- Fixes → Classify each (three-way):
  - **CONTENT-level** (typo, color tweak, copy inside the main area, component inside content) → Re-invoke Saneh with fixes, re-enter Step 3.
  - **JOURNEY-DESIGN-level** (layout of content area, new screen, rearranged sections) → See "Escape to Phase 4" below (epic's journey project).
  - **SHELL-level** (header, footer, sidebar, navigation, global nav/chrome) → See "Escape to App Shell" below. The journey project can't fix this — the shell lives in "00 — App Shell" and in AppLayout code.

If the classification is ambiguous, ask the user: "Is this change about the content area (CONTENT), the journey screen structure (JOURNEY), or the app shell (SHELL)?"

### Step 4 — Naqed — Visual QA (Compliance → Critique → Audit)

Launch Agent with this prompt:

```
You are Naqed, visual QA agent. Context: Story {X.Y}, Screen URL: {url}, Bundle URL: {from story Design Reference}.

Execute these 3 sub-steps IN ORDER:

Sub-step 4a — Design Compliance Check:
1. Read `_bmad-output/implementation-artifacts/design-progress.yaml` and note `app_shell.status`.
2. Take a screenshot of the implemented screen at {screen URL} using Playwright MCP.
3. Open the Bundle URL and take a screenshot of the corresponding screen (or use the static export if available).
4. Compare side-by-side. Report discrepancies at these levels:
   - Layout: column structure, spacing, alignment
   - Components: present/missing/substituted
   - Colors & typography: drift from design tokens
   - Interactions visible on screen (hover, disabled state)
   - Copy / content
5. **Scope of comparison:**
   - If `app_shell.status == "implemented"`: compare the MAIN CONTENT AREA ONLY. The shell (header, footer, sidebar, navigation) lives in AppLayout and is fixed across all stories — do NOT flag shell differences between the implementation and the bundle as violations. Only flag discrepancies inside the content area.
   - If `app_shell.status == "none"`: compare the full screen including any chrome.
6. For each discrepancy, classify as either:
   - IMPLEMENTATION BUG — fix in code
   - INTENTIONAL DEVIATION — note with reason
7. Apply IMPLEMENTATION BUG fixes directly.

Sub-step 4b — Critique (UX):
1. Invoke `/critique` via Skill tool on the screen URL.
2. For each finding, classify as either:
   - UX POLISH — fix in code (e.g., small copy adjustments, spacing tweaks)
   - DESIGN CHANGE — escalate ("this needs redesign in Claude Design")
3. Apply UX POLISH fixes directly.

Sub-step 4c — Audit (a11y + perf):
1. Invoke `/audit` via Skill tool on the screen URL.
2. Apply all findings that are code-level fixes (add aria-labels, fix contrast, optimize asset sizes, etc.).
3. Flag any systemic issues (e.g., "design system color contrast fails AA") as escalations.

Return (exact format):

### Compliance (4a)
Discrepancies found: <N>
Fixed: <N>
Deviations kept: <N with reasons>

### Critique (4b)
Findings: <N>
Fixed inline: <N>
Escalated to design: <list or "none">

### Audit (4c)
Findings: <N>
Fixed inline: <N>
Escalated: <list or "none">

### Summary
Total changes applied: <N>
Blockers for approval: <list or "none">
```

**When the agent returns, print its full Return block verbatim.**

Mark done. Go to Step 5 in the same turn.

### Step 5 — User Final Approval

Print a summary (one-liner per step 2, 3, 4 outcomes) and ask the user:

```
All automated checks passed. Final approval to ship?

Reply with:
  - "approve" / "yes" / "go" → proceed to Step 6
  - Any list of fixes (free-form, e.g., "header color, button position") → I'll classify each
```

Classify user fixes (if any) — three-way classification:
- **CONTENT-level** (CSS tweak, copy, component inside main area, minor behavior): Re-invoke Saneh with fixes, then return to Step 5.
- **JOURNEY-DESIGN-level** (layout of content area, new screen, rearranged sections, feature scope): Escape to Phase 4 for this epic — see "Escape to Phase 4 (journey)" below.
- **SHELL-level** (header, footer, sidebar, navigation, global nav/chrome): Escape to App Shell — see "Escape to App Shell" below.

If classification is ambiguous, ask the user: "Is this change about the content area (CONTENT), the journey screen structure (JOURNEY), or the app shell (SHELL)?"

If approve → mark done, go to Step 6 in the same turn.

### Step 6 — Simplify

Invoke `/simplify` via Skill tool on the story's changes.

When it returns: mark done, go to Step 7 in the same turn. No summary, no pause.

### Step 7 — Code Review

Invoke `/bmad-code-review` via Skill tool with preamble:
> "auto-mode: story-protocol orchestrator — batch-apply all patches, apply severity gating to decision-needed (stop only on High-impact without spec answer), skip interactive HALTs."

When it returns: mark done, go to Step 8 in the same turn.

### Step 8 — PR Review (parallel)

Launch 3 agents in parallel (single message, 3 Agent tool calls):
- `pr-review-toolkit:code-reviewer`
- `pr-review-toolkit:silent-failure-hunter`
- `pr-review-toolkit:pr-test-analyzer`

When all three return, dedupe findings. For each finding:
- Fix it, OR
- Write a structured defer to `_bmad-output/implementation-artifacts/deferred-work.md` with `source: pr-review`, OR
- Dismiss with a one-line reason in the story file.

When fixes are applied: mark done, go to Step 9.

### Step 9 — Verify (stack-detected)

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

If any command fails, fix the regression and re-run. When all pass: mark done, go to Step 10.

### Step 10 — Ship

Invoke `/ship` via Skill tool.

When it returns:
- Update `_bmad-output/implementation-artifacts/sprint-status.yaml` — set this story's status to `done`, increment `stories_completed`, clear `current_story`.
- If this was the LAST story in the epic, trigger the Epic-Level Wrapper close-out (retrospective + testarch-trace) before returning to the orchestrator.
- Return control to the orchestrator to start the next story (or the next epic, or Phase 7).

---

## Escape to Phase 4 (journey) — revise journey design

Triggered from Step 3 or Step 5 if the user requests a **JOURNEY-DESIGN-level** change (layout of content area, new screen, rearranged sections within this epic).

1. Print: "This change affects the journey design. Returning to Phase 4 for Epic {epic}."
2. Open `_bmad-output/implementation-artifacts/design-progress.yaml`.
3. Set this epic's `status` back to `in-progress`.
4. Record: `notes: "Phase 6 Story {X.Y} surfaced journey-level design issue: {description}"`.
5. Abandon or soft-keep the story branch (ask user).
6. Instruct the user to open the Claude Design **journey** project (URL in `design-progress.yaml.epics.{slug}`) and iterate.
7. When the user is done, run `/bmad-sync-from-design --epic={slug}` to re-sync.
8. Return to Phase 6 at the affected story (re-run from Step 1 with refreshed Design Reference).

## Escape to App Shell — revise shell design

Triggered from Step 3 or Step 5 if the user requests a **SHELL-level** change (header, footer, sidebar, navigation, global chrome). The journey project can't fix this — the shell lives in "00 — App Shell" and in AppLayout code.

1. Print: "This change affects the app shell. All stories using AppLayout are affected."
2. Open `design-progress.yaml`.
3. Set `app_shell.status` back to `pending` (or `design-complete` if only the code needs updating, not the design).
4. Record: `app_shell.notes: "Phase 6 Story {X.Y} surfaced shell issue: {description}"`.
5. Abandon or soft-keep the story branch (ask user).
6. Instruct the user:
   ```
   Open the Claude Design project "00 — App Shell" (URL in design-progress.yaml.app_shell.claude_design_project_url)
   and iterate on the shell. When done:
   1. Export → Hand off to Claude Code
   2. Paste the handoff into local Claude Code on branch chore/app-shell
   3. Re-implement AppLayout.tsx (or stack-equivalent at {{layout_component_path}})
   4. Review + merge to main
   5. Come back and tell me the shell is ready
   ```
7. When the user returns, update `app_shell.status = implemented` and `app_shell.implemented_at = {today}`.
8. **Impact:** any story already shipped that uses AppLayout now visually inherits the new shell automatically (no rebuild needed for shell-only changes because AppLayout is a shared component). Only stories with content-area changes need re-run.
9. Return to Phase 6 at the affected story (re-run from Step 1).
