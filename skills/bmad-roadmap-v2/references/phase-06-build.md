# Phase 6: Build (Full-Stack per Story)

**Goal:** Implement every story as a full-stack slice — UI + API + DB + tests — referencing the Claude Design bundle from Phase 4 as the design source of truth.

**Exit condition:** Every story across every epic is shipped. `sprint-status.yaml` shows all stories `done`. `roadmap-progress.yaml` shows every epic `complete`.

---

## Execution Model

Phase 6 is a nested loop:
- **Outer loop:** epics
- **Inner loop:** stories within the current epic (Story Protocol)

The orchestrator uses `roadmap-progress.yaml` to track `current_epic` and `current_story`.

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
Step 3: User Review [PAUSE]
Step 4: Naqed (Compliance → Critique → Audit)
Step 5: User Final Approval [PAUSE]
Step 6: Simplify
Step 7: Code Review
Step 8: PR Review (parallel)
Step 9: Verify
Step 10: Ship
```

See `story-protocol.md` for full details, including Saneh's inline prompt, Naqed's three sub-steps, and the escape path back to Phase 4 if design changes are needed.

---

## After the Last Story of Each Epic

**Epic close-out:**

1. Run `/bmad-retrospective` (BMM native) — captures lessons from this epic
2. Run `/bmad-testarch-trace` (BMM native) — traces test coverage for this epic's changes
3. Update `roadmap-progress.yaml`:
   ```yaml
   phases:
     6-build:
       epics:
         <N>:
           status: complete
           retro_done: true
   ```
4. Advance `current_epic` to the next pending epic

---

## Phase Completion

Before marking Phase 6 complete, verify:
- [ ] Every story in every epic has status `done` in `sprint-status.yaml`
- [ ] Every epic has `retro_done: true`
- [ ] No stories are left in `in-progress`

Update progress file:

```yaml
6-build:
  status: complete
  completed: "{today}"
  epics_built: 6
  stories_shipped: 28
```

Announce completion and proceed to Phase 7.
