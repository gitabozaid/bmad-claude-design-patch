# Step 5: Verify and Complete

## MANDATORY EXECUTION RULES (READ FIRST):

- 📖 Read the complete step file before taking any action
- ✅ Speak in `{communication_language}`

## YOUR TASK:

Verify that all synced artifacts are consistent with each other, then update the design log.

## SEQUENCE:

### 1. Consistency Check

Cross-reference the updated artifacts to catch inconsistencies:

**TypeScript ↔ api-contracts.md:**
- Every interface in `contracts/models/*.ts` must be documented in api-contracts.md
- Every endpoint in `contracts/endpoints/*.ts` must be documented in api-contracts.md
- Field names and types must match exactly

**Mock data ↔ TypeScript:**
- Every JSON field in mock files must exist in the corresponding TypeScript interface
- No extra fields in mocks that aren't in the interface
- No missing fields

**Page specs ↔ api-contracts.md:**
- Every page spec with dynamic data must have an API contracts reference link
- The anchor in the link must exist in api-contracts.md
- OBJECT IDs that display API data must be mapped in the screen contracts section

**Scenarios index ↔ page specs:**
- Every page spec must be listed in 00-ux-scenarios.md
- No phantom entries (pages listed but spec doesn't exist)

Report any inconsistencies found:

```
Consistency check:
✅ TypeScript ↔ api-contracts.md — all match
✅ Mock data ↔ TypeScript — all match
⚠️ Page spec 01b.2-my-words.md references OBJECT ID "mywords-filter-level"
   but no API contract maps to it — is this client-side only?
✅ Scenarios index ↔ page specs — all match
```

Fix any issues found (with user confirmation for ambiguous cases).

### 2. Update Design Log

Append to `{output_folder}/_progress/00-design-log.md`:

```markdown
### [date] — Artifact Sync
- **Trigger:** UI changes approved for [screen names]
- **Phase:** [ui-only | full-stack]
- **Change types:** [list of classifications]
- **Artifacts updated:**
  - Page specs: [list]
  - API contracts: [yes/no + what changed]
  - Mock data: [list]
  - Stories: [list or "none"]
  - Scenarios index: [yes/no]
  - PRD: [yes/no]
- **Consistency:** verified
```

If `{phase_mode}` is **ui-only** AND contract changes were made, add a **Backend Impact** section to the design log entry:

```markdown
- **Backend Impact (Phase 8):**
  - [Model/endpoint]: [what the backend must implement]
  - [Model/endpoint]: [what changed and why]
```

This creates a running log of contract decisions made during UI development. When Phase 8 starts, the team can review these entries to understand why contracts look the way they do.

### 3. Summary

Present the final summary:

```
Sync complete:
- [N] page specs updated
- [N] TypeScript interfaces updated
- [N] mock data files updated
- [N] new stories noted
- API contracts document updated
- Design log updated
- All artifacts verified consistent

Ready to /ship.
```

If `{phase_mode}` is **ui-only** AND contract changes were made, append:

```
📋 Backend Impact Log:
  Contract changes that will affect Phase 8 backend work:
  - [list of contract changes with model/endpoint names]
  These are recorded in the design log for future reference.
```
