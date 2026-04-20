# Phase 3: Epics & Stories

**Goal:** Create the epic and story breakdown from the PRD + UX doc, with adversarial + edge-case reviews baked in. Verify readiness before moving to Phase 4.

**Exit condition:** `_bmad-output/implementation-artifacts/epics/` and `_bmad-output/implementation-artifacts/stories/` populated, and `/bmad-check-implementation-readiness` returns pass.

---

## Steps

### Step 1: Generate Epics & Stories

**Run:** `/bmad-create-epics-and-stories-v2` (skill added by this patch — wraps BMM native with adversarial + edge-case reviews).

This skill:
1. Invokes base `/bmad-create-epics-and-stories` (BMM native)
2. For each generated story:
   - Invokes `bmad-review-adversarial-general` (BMM native)
   - Invokes `bmad-review-edge-case-hunter` (BMM native)
   - Applies findings directly to the story file
3. Prints a summary of reviews performed

The mapping is: **one user journey (from Phase 2 UX doc) = one epic. One screen in that journey = one story.**

Outputs:
- `_bmad-output/implementation-artifacts/epics/<epic-slug>.md` — one file per epic
- `_bmad-output/implementation-artifacts/stories/<story-id>-<slug>.md` — one file per story

### Step 2: Check Implementation Readiness

**Run:** `/bmad-check-implementation-readiness` (BMM native).

Verifies that all required artifacts exist and are consistent:
- PRD
- Architecture
- UX design specification
- Epics directory populated
- Stories directory populated

If gaps are flagged, fix them before moving on.

---

## Phase Completion

Before marking Phase 3 complete, verify:
- [ ] Every journey in the UX doc has a corresponding epic file
- [ ] Every screen in each journey has a corresponding story file
- [ ] Every story has acceptance criteria, FR references, and tasks
- [ ] `/bmad-check-implementation-readiness` returns pass
- [ ] Adversarial and edge-case review findings have been applied to each story

Update progress file:

```yaml
3-epics-stories:
  status: complete
  completed: "{today}"
  epics_count: 6
  stories_count: 28
  readiness_check: pass
```

Announce completion and proceed to Phase 4.
