# Phase 5: Sprint Planning

**Goal:** Order the stories into sprints, identify dependencies, and lock in the execution sequence for Phase 6.

**Exit condition:** `_bmad-output/implementation-artifacts/sprint-status.yaml` exists with stories assigned to sprints.

---

## Process

**Run:** `/bmad-sprint-planning` (BMM native).

The skill walks through sprint planning given:
- Epics and stories from Phase 3
- Design references baked in (from Phase 4 sync)
- PRD priorities

Outputs:
- `sprint-status.yaml` with:
  - Story execution order (respecting dependencies)
  - Estimated size per story
  - Current sprint marker

Review the output with the user before approving.

---

## Phase Completion

Before marking Phase 5 complete, verify:
- [ ] `sprint-status.yaml` exists
- [ ] All stories are assigned to a sprint
- [ ] Dependencies are flagged (e.g., story 2.3 blocks 4.1)

Update progress file:

```yaml
5-sprint-planning:
  status: complete
  completed: "{today}"
  sprints_planned: 3
```

Announce completion and proceed to Phase 6.
