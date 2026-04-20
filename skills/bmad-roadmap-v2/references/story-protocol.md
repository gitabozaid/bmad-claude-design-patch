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

4. Implement the story as a full-stack slice:
   a. UI — build the screen to match the design extracted from the bundle. Use the project's existing component library (from design system). Match the framework (Next.js page + components, Vue SFC, etc.).
   b. State — wire local state, global store (Redux/Zustand/Pinia), or React Query as appropriate.
   c. Routing — add route entries. Match the project's routing convention.
   d. i18n — add translation keys for all user-facing strings. Support AR + EN if the project is bilingual.
   e. API — implement the endpoint(s) the story needs (Laravel route + controller, Express endpoint, etc.).
   f. DB — add migrations if the story needs new tables/columns. Seed data if applicable.
   g. Tests — unit tests for the UI component and API controller, one happy-path E2E for the screen.

5. Verify (stack-specific):
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
- Fixes → Classify each:
  - Code-level (typo, color tweak, copy) → Re-invoke Saneh with fixes, re-enter Step 3.
  - Design-level (structural change) → See "Escape to Phase 4" below.

### Step 4 — Naqed — Visual QA (Compliance → Critique → Audit)

Launch Agent with this prompt:

```
You are Naqed, visual QA agent. Context: Story {X.Y}, Screen URL: {url}, Bundle URL: {from story Design Reference}.

Execute these 3 sub-steps IN ORDER:

Sub-step 4a — Design Compliance Check:
1. Take a screenshot of the implemented screen at {screen URL} using Playwright MCP.
2. Open the Bundle URL and take a screenshot of the corresponding screen (or use the static export if available).
3. Compare side-by-side. Report discrepancies at these levels:
   - Layout: column structure, spacing, alignment
   - Components: present/missing/substituted
   - Colors & typography: drift from design tokens
   - Interactions visible on screen (hover, disabled state)
   - Copy / content
4. For each discrepancy, classify as either:
   - IMPLEMENTATION BUG — fix in code
   - INTENTIONAL DEVIATION — note with reason
5. Apply IMPLEMENTATION BUG fixes directly.

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

Classify user fixes (if any):
- **Design-level** (structural, layout, feature change): Escape to Phase 4 — see "Escape to Phase 4" below.
- **Code-level** (styling, copy, minor behavior): Re-invoke Saneh with fixes, then return to Step 5.

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

## Escape to Phase 4 (revise design)

Triggered from Step 3 or Step 5 if user requests design-level changes.

1. Print: "This change affects the design. Returning to Phase 4 for Epic {epic}."
2. Open `_bmad-output/implementation-artifacts/design-progress.yaml`.
3. Set this epic's `status` back to `in-progress`.
4. Record: `notes: "Phase 6 Story {X.Y} surfaced design issue: {description}"`.
5. Abandon or soft-keep the story branch (ask user).
6. Instruct user to open the Claude Design project (URL in `design-progress.yaml`) and iterate.
7. When user is done, run `/bmad-sync-from-design --epic={slug}` to re-sync.
8. Return to Phase 6 at the affected story (re-run from Step 1 with refreshed Design Reference).
