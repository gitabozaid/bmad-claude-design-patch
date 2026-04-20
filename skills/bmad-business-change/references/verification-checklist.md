# Verification Gate Checklist

Run every check after cascade and story management are complete. If ANY check fails, report what's missing and fix it before completing the workflow.

## Check 1: PRD ↔ Artifacts Alignment

For every PRD section that changed:
- [ ] Is the change reflected in `architecture.md`? (if architecturally relevant)
- [ ] Is the change reflected in `api-contracts.md`? (if API relevant)
- [ ] Is the change reflected in the relevant page spec? (if UI relevant)

**How to verify:** Grep each affected artifact for the changed concept. If the concept appears in the PRD but not in the artifact that should reflect it, flag as MISSING.

## Check 2: New Concepts → Contracts

For every new concept/entity introduced in the PRD change:
- [ ] Is there a TypeScript interface defined (or described) in `api-contracts.md`?
- [ ] Is there a mock data entry described for it?
- [ ] Is there an API endpoint defined for it (if it needs server data)?

**How to verify:** Extract new nouns/entities from the PRD diff. Search `api-contracts.md` for each. Missing = flag.

## Check 3: Affected Screens → Stories

For every screen identified in the gap analysis:
- [ ] Does the screen have at least one story covering the change?
- [ ] If the screen is new, is there a story to build it?
- [ ] If the screen exists and code is deployed, is there a story/task to update it?

**How to verify:** Cross-reference the impact report's "Screens Affected" with `epics.md` stories. Every screen must have coverage.

## Check 4: Completed Stories → Remediation

For every completed story flagged as affected:
- [ ] Is there either:
  - A new story to update the implementation, OR
  - The code was already updated inline (verify with git diff)
- [ ] Are the affected source files identified specifically?

**How to verify:** Check `roadmap-progress.yaml` for completed stories. For each flagged one, verify remediation exists in `epics.md` or code.

## Check 5: Sprint Status Consistency

- [ ] `sprint-status.yaml` matches `epics.md` — same stories, same count
- [ ] New stories added to sprint-status have status `backlog`
- [ ] `roadmap-progress.yaml` story counts match the actual stories in each epic
- [ ] No orphaned stories (in sprint-status but not in epics, or vice versa)

**How to verify:** Compare story IDs across the three files.

## Check 6: Phase Correctness

- [ ] Every new story is assigned to the correct phase
- [ ] UI stories are in a Phase 5 epic (if currently in Phase 5)
- [ ] Backend stories are in Phase 7/8 epics (if applicable)
- [ ] No stories deferred vaguely to "future" without a specific phase

**How to verify:** Read each new story's epic assignment and cross-reference with `roadmap-progress.yaml` current phase.

## Failure Handling

If any check fails:
1. Report which check failed and what specifically is missing
2. Fix the gap (add missing artifact entry, create missing story, etc.)
3. Re-run the failed check to confirm it now passes
4. Continue to next check

Do NOT mark the workflow as complete until all checks pass.

## Output

After all checks pass, report:
```
VERIFICATION: ALL {count} CHECKS PASSED
- PRD ↔ Artifacts: ✓ ({count} artifacts aligned)
- New Concepts: ✓ ({count} concepts have contracts)
- Screen Coverage: ✓ ({count} screens have stories)
- Completed Stories: ✓ ({count} remediation plans in place)
- Sprint Status: ✓ (consistent)
- Phase Correctness: ✓ (all stories in correct phase)
```
