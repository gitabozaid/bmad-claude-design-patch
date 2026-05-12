# Phase 6: Build (Full-Stack per Story)

**Goal:** Implement every story as a full-stack slice — UI + API + DB + tests — referencing the Claude Design bundle from Phase 4 as the design source of truth.

**Exit condition:** Every story across every epic is shipped. `sprint-status.yaml` shows all stories `done`. `roadmap-progress.yaml` shows every epic `complete`.

---

## Execution Model

Phase 6 is a nested loop:
- **Outer loop:** epics
- **Inner loop:** stories within the current epic (Story Protocol)

The orchestrator uses `roadmap-progress.yaml` to track `current_epic` and `current_story`.

### Pause model (changed 2026-05-12)

- **One PAUSE per story** — at Step 4 (User Review), after Naqed has cleaned the implementation. Light visual + flow check, not deep approval.
- **One PAUSE per epic** — at Epic Final Approval (Epic Close-out E1), after the last story ships. Holistic walk-through of every screen in the journey together.
- No legacy "Critique" sub-step. The Claude Design bundle IS the approved visual; second-guessing it is out of scope. Naqed verifies compliance (vs bundle) + audit (a11y + perf) only.

---

## Before the First Story of the First Epic

**Test infrastructure setup (first epic only):**

1. Run `/bmad-testarch-framework` (BMM native) — sets up the test framework
2. Run `/bmad-testarch-ci` (BMM native) — wires CI for tests

Mark in progress file: `phases.6-build.test_infra_done: true`

Skip these steps for all subsequent epics.

---

## Per-Story: Story Protocol

For each story in the current epic, run the Story Protocol in `./story-protocol.md`:

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

See `story-protocol.md` for full details, including Saneh's inline prompt, Naqed's 2 sub-steps (Compliance + Audit only — no Critique), and the escape path back to Phase 4 if design changes are needed.

---

## After the Last Story of Each Epic: Epic Close-out

```
Step E1: User Final Approval [PAUSE — per-epic walk-through]
Step E2: /bmad-retrospective
Step E3: /bmad-testarch-trace
Step E4: Update roadmap-progress.yaml — mark epic complete; advance current_epic
```

Epic Final Approval is the holistic gate. The user walks through every screen of the journey together, end-to-end, and either approves the epic or surfaces fixes (CONTENT-level → re-invoke Saneh on affected stories / JOURNEY-level → escape to Phase 4 to re-sync).

See `story-protocol.md` → "Epic Close-out" section for the full prompts and escape paths.

---

## Phase Completion

Before marking Phase 6 complete, verify:
- [ ] Every story in every epic has status `done` in `sprint-status.yaml`
- [ ] Every epic has `retro_done: true`
- [ ] Every epic has been approved at Epic Final Approval (E1)
- [ ] No stories are left in `in-progress`

Update progress file:

```yaml
6-build:
  status: complete
  completed: "{today}"
  epics_built: <N>
  stories_shipped: <M>
```

Announce completion and proceed to Phase 7.
