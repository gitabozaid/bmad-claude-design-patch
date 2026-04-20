---
name: bmad-roadmap-v2
description: "Orchestrate the BMM-native + Claude Design product development lifecycle across 9 phases. Use when the user says 'bmad roadmap v2', 'start the roadmap', 'where am I in the roadmap', 'next phase', 'continue the roadmap', 'roadmap status', or asks what to do next on a new project built with Claude Design. Also use when navigating between development phases on a project that uses this patch (new projects). For legacy projects that use the old bmad-figma-patch, use /bmad-roadmap (v1) instead."
---

# BMAD Roadmap v2

## Overview

This skill guides you through the complete BMAD product development lifecycle for projects using Claude Design as the visual design tool. It orchestrates 9 phases, executed sequentially, with Phase 4 containing a per-epic loop and Phase 6 containing a per-story loop. Progress is tracked in a YAML status file so work survives across conversations.

**This replaces the 11-phase `/bmad-roadmap` (v1) for new projects.** The old roadmap is still correct for projects built on WDS + per-screen specs + API contracts. Use v2 when:
- The project uses `bmad-create-ux-design` (BMM native) as its UX workflow
- Screens are designed in [Claude Design](https://claude.ai/design) with handoff bundles
- Stories are full-stack slices (no UI/Backend split)

**Args:** Accepts `--status` to show current progress, `--phase N` to jump to a specific phase, `--headless` for autonomous execution, or no args to continue from where you left off.

## Execution Model

**Phases 1–3 (Discover → UX → Epics & Stories):** Conversational — each step invokes a skill that produces an artifact for user approval. Wait for approval at natural gates; move to the next step once given.

**Phase 4 (Per-Epic Design Loop):** Manual user work in browser + automated sync after each handoff. The orchestrator pauses for the user to do the Claude Design work, resumes on return, runs `/bmad-sync-from-design`, then advances to the next epic.

**Phase 5 (Sprint Planning):** Conversational — confirm scope and order.

**Phase 6 (Build):** Autonomous per story. First epic triggers test-infra setup. Per-story Story Protocol runs without stopping except for the mandatory User Review and User Final Approval pauses. After each epic completes, runs `/bmad-retrospective` + `/bmad-testarch-trace`.

**Phases 7–9 (Deploy / Harden / Evolve):** Task-based. Follow the instructions in each phase file.

## On Activation

1. Load the progress file at `{project-root}/_bmad-output/roadmap-progress.yaml`. If it doesn't exist, this is a fresh start.

2. If the progress file doesn't exist — this is a fresh start:
   - Tell the user: "No roadmap progress found. Starting fresh at Phase 1: Discover."
   - Create the progress file from the template in `references/progress-template.yaml`
   - **Verify the file was created** by reading it back. Do not proceed until it exists on disk.
   - Set Phase 1 to `in-progress`
   - Route to Phase 1

3. Determine intent:
   - **`--status`** or "where am I" → Show current phase, epic, story progress, Phase 4 design-progress snapshot. Stop.
   - **`--phase N`** or "go to phase N" → Jump to that phase. **Hard-block enforcement:** verify prerequisites before jumping:
     - Phase 4 requires `3-epics-stories.status == complete`
     - Phase 5 requires `4-claude-design-loop.status == complete` (every epic `design-complete`)
     - Phase 6 requires `5-sprint-planning.status == complete`
     - Phase 7+ requires `6-build.status == complete`
     - Refuse the jump with a clear message if unmet.
   - **`--headless`** → Execute the current phase autonomously. Skip optional steps with defaults. For conversational phases, accept generated artifacts without review. For Phase 4, headless is NOT supported (manual user work required) — halt with instructions.
   - **No args / "continue"** → Resume from where the user left off.
   - **Fresh start** → Begin at Phase 1.

4. Route to the appropriate phase reference file.

## Progress File Structure

### Initial Template (fresh start)

See `references/progress-template.yaml`. Created on activation if missing.

### Mature State Example

```yaml
project_name: "{project-name}"
current_phase: 6
started: "2026-04-20"
updated: "2026-05-02"

phases:
  1-discover:
    status: complete
    completed: "2026-04-22"
  2-ux-design:
    status: complete
    completed: "2026-04-24"
  3-epics-stories:
    status: complete
    completed: "2026-04-26"
    readiness_check: pass
  4-claude-design-loop:
    status: complete      # All epics design-complete
    completed: "2026-04-30"
  5-sprint-planning:
    status: complete
    completed: "2026-04-30"
  6-build:
    status: in-progress
    test_infra_done: true         # First epic test infra setup done
    current_epic: 2
    epics:
      1:
        name: "Onboarding"
        status: complete
        stories_total: 4
        stories_completed: 4
        retro_done: true
      2:
        name: "Lessons"
        status: in-progress
        stories_total: 5
        stories_completed: 2
        current_story: "2.3"
  7-deploy:
    status: pending
  8-harden:
    status: pending
  9-evolve:
    status: pending
```

**Phase 4 tracking lives in a separate file** — `_bmad-output/implementation-artifacts/design-progress.yaml` — managed by `/bmad-claude-design-prep` and `/bmad-sync-from-design`. The roadmap reads both files when reporting Phase 4 status.

## Phase Routing

Read the progress file, determine the current phase, then load the corresponding reference:

| Phase | Reference File | Summary |
|-------|---------------|---------|
| 1 | `./references/phase-01-discover.md` | Product brief, PRD, validate, architecture |
| 2 | `./references/phase-02-ux-design.md` | `/bmad-create-ux-design` — one consolidated UX doc |
| 3 | `./references/phase-03-epics-stories.md` | `/bmad-create-epics-and-stories-v2` + `/bmad-check-implementation-readiness` |
| 4 | `./references/phase-04-claude-design-loop.md` | Per-epic: `/bmad-claude-design-prep` → Claude Design (manual) → `/bmad-sync-from-design` |
| 5 | `./references/phase-05-sprint-planning.md` | `/bmad-sprint-planning` |
| 6 | `./references/phase-06-build.md` | Per story: Story Protocol (full-stack). First epic: test-infra. After each epic: retrospective |
| 7 | `./references/phase-07-deploy.md` | Full-stack deploy |
| 8 | `./references/phase-08-harden.md` | NFR + test review + E2E |
| 9 | `./references/phase-09-evolve.md` | Product evolution |
| — | `./references/story-protocol.md` | Shared sub-workflow for story execution (used by Phase 6) |

Load the reference file for the current phase and follow its instructions.

## Phase Transition Rules

Before moving to the next phase:
1. **Verify completion:** Read the phase reference file's exit condition. Confirm every required step is done.
2. **Update progress file:** Mark the phase `complete` with `completed: "{today}"`.
3. Set the next phase to `status: in-progress` and update `current_phase`.
4. Announce: "Phase N complete. Moving to Phase N+1: [name]."

**Special transitions:**
- **Phase 4 completion** requires every epic in `design-progress.yaml` to be `design-complete`. If any is still `pending` or `in-progress`, Phase 4 is not complete.
- **Phase 6 epic completion** does NOT mean the phase is complete — check if more epics remain. Only mark Phase 6 complete when ALL epics built.
- **Phase 4 escape** — if during design loop the user realizes the approach is wrong, invoke `/bmad-correct-course` (BMM native). The roadmap tolerates this without breaking.
- **Phase 6 escape** — if at Step 5 (User Final Approval) the user chooses "revise design", mark the epic's `design-progress.yaml` status back to `in-progress`, halt Phase 6 for that epic, and return to Phase 4 for that epic. Resume Phase 6 at the affected story after re-sync.

## References

- `references/progress-template.yaml` — initial template for fresh projects
- `references/story-protocol.md` — Story Protocol inline prompts (Saneh, Naqed, etc.)
- `references/phase-*.md` — one reference per phase
