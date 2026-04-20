# Step 3: Build Sync Plan

## MANDATORY EXECUTION RULES (READ FIRST):

- 📖 Read the complete step file before taking any action
- ✅ Speak in `{communication_language}`
- 🚫 Do not modify any files yet — this step only produces the plan

## YOUR TASK:

Based on the classifications from step 2, build a concrete sync plan that lists every file that will be modified and exactly what will change. The user must approve this plan before anything is touched.

## SEQUENCE:

### 1. Build the Plan

For each classified screen, determine the specific updates:

#### For Type 1 (Visual Only):

Read the page spec and compare the layout diagram + spacing tokens against the actual code. List what's different:

```
📄 01b.1-home-returning.md
  UPDATE layout diagram: swap hero section and word-of-day section order
  UPDATE spacing: section gap space-md → space-lg
```

#### For Type 2 (Content / Field Change):

Compare the page spec's OBJECT IDs and content against the code. Also check api-contracts.md for affected endpoints:

```
📄 01b.2-my-words.md
  ADD OBJECT ID: mywords-last-practiced (new date field on word card)
  UPDATE content: word card now shows "Last practiced: {date}"

📄 api-contracts.md
  UPDATE model WordSummary: add lastPracticed: string (ISO date)
  UPDATE screen mapping for my-words: add lastPracticed reference

📄 contracts/models/word.ts
  ADD field: lastPracticed: string to WordSummary interface

📄 contracts/mocks/get-words.json
  ADD lastPracticed field to every word object
```

#### For Type 3 (New Screen):

```
📄 NEW: design-process/C-UX-Scenarios/.../settings.md
  CREATE new page spec from the built screen

📄 api-contracts.md
  ADD screen section for settings
  ADD endpoints: GET /api/v1/users/me/preferences, PATCH /api/v1/users/me/preferences

📄 contracts/endpoints/users.ts
  ADD GetPreferences and UpdatePreferences endpoint types

📄 contracts/mocks/get-user-preferences.json
  CREATE mock data for preferences

📄 00-ux-scenarios.md
  ADD settings page to coverage matrix

📄 stories/ or epics/
  ADD story for settings screen (or note for next sprint planning)
```

#### For Type 4 (Screen Restructured):

```
📄 DELETE: old-page-spec.md (merged into other screen)
📄 UPDATE: target-page-spec.md (absorb content from deleted spec)
📄 UPDATE api-contracts.md: merge screen mappings
📄 UPDATE stories: mark old story as superseded
```

#### For Type 5 (New Feature):

```
📄 UPDATE: affected-page-spec.md (new section/component)
📄 UPDATE api-contracts.md (if feature needs API data)
📄 UPDATE PRD: add new FR for the feature
📄 ADD story to current epic
```

### 2. Present the Complete Plan

Show the full plan organized by artifact:

```
Sync Plan:
═══════════════════════════════════════

Page Specs (2 updates, 1 new):
  📝 01b.1-home-returning.md — layout diagram + spacing
  📝 01b.2-my-words.md — add OBJECT ID + content
  📄 NEW settings.md — create from built screen

API Contracts (1 update):
  📝 api-contracts.md — add lastPracticed to WordSummary + settings screen section

TypeScript Contracts (2 updates):
  📝 contracts/models/word.ts — add lastPracticed field
  📝 contracts/endpoints/users.ts — add preferences endpoints

Mock Data (1 update, 1 new):
  📝 contracts/mocks/get-words.json — add lastPracticed
  📄 NEW contracts/mocks/get-user-preferences.json

Scenarios Index (1 update):
  📝 00-ux-scenarios.md — add settings to coverage matrix

Stories (1 new):
  📄 NEW story for settings screen

Total: 8 file updates, 3 new files
═══════════════════════════════════════
```

### 3. Backend Impact Summary (UI-only phase)

If `{phase_mode}` is **ui-only** AND the plan includes any contract changes (TypeScript interfaces, api-contracts.md, endpoints, or mock data), add a summary section after the main plan:

```
Backend Impact (not built yet):
  These contract changes will affect future Phase 8 backend work:
  - [Model name]: backend must include [field] field
  - New [endpoint]: backend must implement this endpoint
  - [Model name]: [field] type changed from X to Y
  ...
  This is informational — no action needed now, but recorded in design log.
```

This makes the downstream impact visible to the user before they approve, so there are no surprises when they start building the backend.

If `{phase_mode}` is **full-stack**, skip this section — the impact is direct and obvious from the plan itself.

### 4. Get Approval

Ask the user to review and approve. They might:
- Approve as-is → continue
- Remove items ("don't update the PRD, I'll do that later") → adjust plan
- Add items ("also update the design system, I added a new component") → adjust plan

### 5. Continue

Display: "[C] Continue to Execute | [A] Advanced Elicitation | [P] Party Mode"

- IF A: Invoke `bmad-advanced-elicitation`, then return to menu
- IF P: Invoke `bmad-party-mode`, then return to menu
- IF C: Load `./step-04-execute.md`
