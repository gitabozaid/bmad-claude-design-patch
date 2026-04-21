# BMAD Roadmap (v3 — Claude Design Patch)

> **This roadmap is available as an interactive workflow:** `/bmad-roadmap-v2`
> Tracks progress across conversations, handles the per-epic Claude Design loop and the per-story build loop, and guides you through each of the 9 phases.
> Use `/bmad-roadmap-v2 --status` to check progress, `/bmad-roadmap-v2 --phase N` to jump, or `/bmad-roadmap-v2` to continue.

**When to use:** new BMAD projects that use Claude Design for visuals and build stories as full-stack slices (UI + API + DB in one PR). 9 phases — no WDS, no per-screen specs, no API contracts phase, no UI/Backend split.

For legacy projects on WDS + per-screen specs + split UI/Backend stories, use [v1 ROADMAP](../bmad-figma-patch/ROADMAP.md) or [v2 ROADMAP](../bmad-patch-v2/ROADMAP.md) (compact protocol variant).

## 1. Discover

1. `/bmad-domain-research` · skip if domain is well-known
2. `/bmad-market-research` · skip if not a product
3. `/bmad-brainstorming` · skip if user has clear vision
4. `/bmad-product-brief`
5. `/bmad-create-prd`
6. `/bmad-validate-prd` · fix gaps before moving on
7. `/bmad-create-architecture`

## 2. UX Design

1. `/bmad-create-ux-design` (BMM native) — produces **one consolidated document** `_bmad-output/planning-artifacts/ux-design-specification.md` covering:
   - Discovery + core experience + emotional response
   - Design system (tokens + components)
   - **User journeys** (these become epics in Phase 3)
   - Component strategy + UX patterns
   - Responsive + accessibility

**Important:** review the User Journeys section with the user before Phase 3 — each journey becomes one epic and one Claude Design project.

## 3. Epics & Stories

1. `/bmad-create-epics-and-stories-v2` — wraps base BMM skill; runs adversarial + edge-case reviews on every generated story at creation time (reviews that Kateb used to do in v1's story protocol). Outputs one epic per journey and one story per screen within each journey.
2. `/bmad-check-implementation-readiness` (BMM native) — verifies PRD + UX doc + epics + stories all present and consistent.

## 4. Per-Epic Claude Design Loop

**Manual browser work** in [claude.ai/design](https://claude.ai/design). No automation (Claude Design has no API/MCP). Orchestrator pauses, user works in browser, orchestrator resumes.

### One-time setup (before the loop)

Two sequential setup steps:

**Setup 1 — Organization-level design system:**
Open claude.ai/design → create organization for the project → upload design system (link repo or asset files) → toggle "Published".

**Setup 2 — App Shell Pre-flight (new in v3.1):**
Claude Design has no Figma-style layout inheritance across projects. To guarantee shell consistency, the app shell (header, footer, sidebar, navigation) lives in the **codebase**, not in each Claude Design project. The orchestrator asks:

- `[yes]` → the shell is implemented; tell me the path (e.g., `frontend/src/components/layout/AppLayout.tsx`)
- `[no]`  → guide me through the shell workflow:
  1. Create a Claude Design project "00 — App Shell"
  2. Design the shell (all variants: default, scrolled, mobile, desktop)
  3. Export → Hand off to Claude Code
  4. Implement as `AppLayout.tsx` on branch `chore/app-shell`
  5. Review + merge to main
  6. Come back and answer `[yes]`
- `[skip]` → product has no persistent shell (single-screen landing / minimal PWA). All shell-specific instructions are skipped; codebase attachment becomes OPTIONAL.

The choice is recorded in `design-progress.yaml: app_shell` and is sticky.

**The shell is infrastructure, NOT a story.** Foundation branch, merged directly to main. No Kateb, no Naqed, no retrospective. Tracked in `design-progress.yaml.app_shell` only.

### Loop per epic

For each epic from Phase 3:

1. `/bmad-claude-design-prep --epic=<slug>` — prints **attachment checklist** (exact file paths to upload, including REQUIRED codebase attachment when shell is `implemented`) + **ready-to-paste prompt** (with aesthetics guidance + "App shell constraint" section when shell is implemented). Creates `design-process/claude-design-handoffs/<slug>/bundle.md`.
2. User work in browser:
   - Create a new Claude Design project for the epic
   - Upload the files from the checklist (PRD + UX doc + epic + stories + **codebase** if shell is implemented)
   - Paste the prompt (includes "Don't redesign the shell; focus on main content area only" when applicable)
   - Iterate (inline comments for small changes, chat for structural changes)
   - Ask for edge states (empty, error, loading, RTL if bilingual)
   - Export → **"Hand off to Claude Code"** → get bundle URL + handoff prompt
3. User pastes bundle URL + handoff prompt into `bundle.md`
4. `/bmad-sync-from-design --epic=<slug>` — WebFetches the bundle, deep-compares vs existing stories (screen/section/component/copy/state level), propagates changes autonomously to stories/epic/UX doc, marks epic `design-complete`, prints diff summary.
5. Advance to next epic.

Phase 4 is complete when every epic is `design-complete` in `_bmad-output/implementation-artifacts/design-progress.yaml`.

### Escape hatch

If the approach is wrong mid-loop, invoke `/bmad-correct-course` (BMM native) — it re-plans the affected phase without wiping completed epics.

## 5. Sprint Planning

1. `/bmad-sprint-planning` (BMM native) — order stories into sprints, identify dependencies.

## 6. Build (Full-Stack per Story)

Each story = one screen + its API + its DB migration + its tests, all in one PR.

### Per-epic wrapper

- **First epic only:** `/bmad-testarch-framework` + `/bmad-testarch-ci` to set up the test framework and CI.
- **After each epic:** `/bmad-retrospective` + `/bmad-testarch-trace`.

### Story Protocol (for every story)

Follow `.claude/skills/bmad-roadmap-v2/references/story-protocol.md`. 10 steps in a single branch:

```
Step 1:  Branch
Step 2:  Saneh — Full-Stack Build
         (reads story + Design Reference block; reads app_shell.status;
          if implemented: imports AppLayout and wraps content, does NOT
          modify shell; fetches bundle; detects stack; builds UI + state
          + routing + i18n + API + DB migration + tests in one pass)
Step 3:  User Review [PAUSE]
         Fixes classified three-way (CONTENT / JOURNEY / SHELL)
Step 4:  Naqed — Visual QA (in this order)
         4a. Design Compliance Check (vs Bundle URL)
             — when shell is implemented, compares MAIN CONTENT AREA only;
               shell differences are not flagged as violations
         4b. Critique (UX)
         4c. Audit (a11y + performance)
Step 5:  User Final Approval [PAUSE]
         Three-way fix classification:
           CONTENT-level → re-invoke Saneh (content, copy, CSS tweaks)
           JOURNEY-DESIGN-level → Escape to Phase 4 for this epic (layout, new screen)
           SHELL-level → Escape to App Shell (header, footer, navigation)
         Approve → continue to Step 6.
Step 6:  /simplify
Step 7:  /bmad-code-review (auto-mode)
Step 8:  PR Review (3 agents in parallel)
Step 9:  Verify (stack-detected: pnpm tsc + pnpm lint + php artisan test as applicable)
Step 10: /ship
```

No Kateb step (reviews moved to Phase 3). No Mir'a step (sync happens in Phase 4, not per story).

### Escape to Phase 4 (journey design)

If Step 3 or Step 5 surfaces a **JOURNEY-DESIGN-level** change (layout of content area, new screen, rearranged sections), return to Phase 4 for the affected epic: reset its `design-progress.yaml` status to `in-progress`, open the Claude Design journey project, iterate, re-export, re-run `/bmad-sync-from-design`, then resume Phase 6 at the affected story.

### Escape to App Shell (shell design)

If Step 3 or Step 5 surfaces a **SHELL-level** change (header, footer, sidebar, navigation, global chrome), the journey project can't fix this — the shell lives in "00 — App Shell" and in `AppLayout` code:

1. Set `app_shell.status` back to `pending` (or `design-complete` if only code needs updating).
2. Open the Claude Design project "00 — App Shell" (URL in `design-progress.yaml.app_shell.claude_design_project_url`).
3. Iterate in Claude Design → Export → Hand off to Claude Code.
4. Re-implement `AppLayout.tsx` on branch `chore/app-shell`.
5. Review + merge to main.
6. Update `app_shell.status = implemented`.
7. Resume Phase 6 at the affected story.

**Impact:** any story already shipped that uses AppLayout automatically inherits the updated shell (shared component). Only stories with content-area regressions need rebuild.

## 7. Deploy (Full-Stack)

Unlike v1 (which had separate UI-only and full-stack deploys), v3 deploys full-stack from the start.

Follow the "Adding a New App to the Server" guide in global CLAUDE.md. Full-stack stack: PHP-FPM + Nginx + Node/Next.js + DB + Redis, routed through Caddy with Let's Encrypt SSL.

Post-deploy smoke test:
- `GET /api/v1/health` returns 200
- Every journey entry screen loads correctly
- One full journey end-to-end with real API + DB
- Rollback script dry-run verified

## 8. Harden

1. `/bmad-testarch-nfr` (BMM native) — NFR assessment: performance, accessibility, security, observability, reliability
2. `/bmad-testarch-test-review` (BMM native) — test suite review (coverage gaps, flakiness, missing types)
3. `/bmad-qa-generate-e2e-tests` (BMM native) — generate E2E tests for the critical journeys from Phase 2

## 9. Evolve

Open-ended. Collect signals (feedback, analytics, incidents), prioritize changes, loop back to whichever phase is affected:

- Bug → small story, back to Phase 6 briefly
- UX improvement → back to Phase 4 for the affected epic
- New feature → Phase 2 (UX doc update) + Phase 3 (new epic/stories) + Phase 4 (design)
- Pivot → Phase 1 (revised PRD)

Skills that help: `/bmad-business-change`, `/bmad-correct-course`, `/bmad-sync-artifacts`.

Phase 9 never truly completes — it's the ongoing life of the product.

---

## v3 vs v1/v2 — Key Differences

| Aspect | v1 / v2 | v3 |
|--------|---------|-----|
| UX workflow | WDS (multi-phase: foundation, scenarios, design system, specs) | BMM native (`bmad-create-ux-design` — one consolidated doc) |
| Screen specs | Per-screen markdown specs (9-step flow) | No per-screen specs. Claude Design bundle IS the spec. |
| Visual design tool | Figma / HTML prototype / manual | Claude Design (handoff bundles) |
| Stories | Split UI (mock data) + Backend (real API) | Full-stack slice (UI + API + DB + tests in one PR) |
| Deploy phases | UI-only deploy + full-stack deploy (2 separate) | Single full-stack deploy |
| API contracts phase | Yes (Phase 4) | Removed — no UI/Backend split needed |
| Agents (sub-agents) | Kateb + Banna + Haddad + Naqed + Mir'a | Saneh + Naqed only (Kateb/Mir'a removed; Banna+Haddad merged) |
| Total phases | 11 | 9 |

Choose v3 for new projects. Keep legacy projects on v1/v2.
