# Step 2: Classify Changes

## MANDATORY EXECUTION RULES (READ FIRST):

- 📖 Read the complete step file before taking any action
- ✅ Speak in `{communication_language}`
- 🚫 Do not update any files yet — this step is only about classification

## YOUR TASK:

For each affected screen, classify the type of change. The classification determines which artifacts need updating in the next step.

## CLASSIFICATION RULES:

### Type 1: Visual Only
**What it looks like in the diff:** CSS changes, layout reordering, color/spacing tweaks, font changes, animation additions. No new data fields, no removed fields, no new components that consume API data.

**Example:** Changed `gap-4` to `gap-6`, swapped section order, changed background color.

**Artifacts to update:** Page spec only (layout diagram, spacing tokens).

---

### Type 2: Content / Field Change
**What it looks like in the diff:** A form field added or removed, a data field that was displayed is no longer shown (or vice versa), text/microcopy changed, a component now consumes a different prop from the API.

**Example:** Removed email field from registration form, added "last practiced" date to word card, changed button text.

**Artifacts to update:** Page spec + api-contracts.md + mock data + possibly TypeScript interfaces.

---

### Type 3: New Screen
**What it looks like in the diff:** A new page/route file created that doesn't map to any existing page spec.

**Example:** New `src/app/(main)/settings/page.tsx` file.

**Artifacts to update:** New page spec + api-contracts.md + mock data + epic/stories + scenarios index.

---

### Type 4: Screen Restructured
**What it looks like in the diff:** A page file was deleted and its content moved elsewhere, or a page was split into two, or two pages were merged.

**Example:** `profile.tsx` split into `profile.tsx` + `settings.tsx`, or `review-session.tsx` absorbed `session-complete.tsx`.

**Artifacts to update:** Affected page specs (create/delete/modify) + api-contracts.md (screen mappings) + stories.

---

### Type 5: New Feature
**What it looks like in the diff:** New functionality that wasn't in the original specs — not just a new screen, but a new capability. Often involves multiple files across components, hooks, and utilities.

**Example:** Added dark mode toggle, added offline indicator, added social sharing feature.

**Artifacts to update:** Page spec + possibly api-contracts.md + possibly PRD (new FR) + add story to epic.

---

## SEQUENCE:

### 1. Classify Each Screen

For each affected screen from step 1, analyze the diff and assign a type:

```
Screen Classifications:
┌─────────────────────┬────────────┬──────────────────────────────┐
│ Screen              │ Type       │ Reason                       │
├─────────────────────┼────────────┼──────────────────────────────┤
│ Home (returning)    │ Visual     │ Only spacing and color changes│
│ My Words            │ Content    │ Added "last practiced" field  │
│ Settings            │ New Screen │ No existing spec              │
└─────────────────────┴────────────┴──────────────────────────────┘
```

### 2. Handle Ambiguity

If a screen has multiple types of changes (e.g., visual changes + a new field), use the **highest** type:
- Visual < Content < Restructure < New Screen < New Feature

If you're unsure about a classification, explain the ambiguity and ask the user.

### 3. Present Classifications

Show the classification table and ask for confirmation. The user might reclassify something — respect that.

### 4. Phase-Aware Contract Impact Note

If `{phase_mode}` is **ui-only** AND any screen has Type 2+ changes (Content/Field, New Screen, Restructured, or New Feature), add this note after the classification table:

```
⚠️ Contract Impact Note (UI-only phase):
No backend exists yet — these contract changes define the API shape
the backend will implement in Phase 8.
Changing contracts now means the backend must be built to match this new shape.
```

If `{phase_mode}` is **full-stack**, skip this note — the backend impact will be visible directly in the sync plan.

### 5. Continue

Display: "[C] Continue to Sync Plan | [A] Advanced Elicitation | [P] Party Mode"

- IF A: Invoke `bmad-advanced-elicitation` for deeper analysis, then return to menu
- IF P: Invoke `bmad-party-mode` for multi-perspective review, then return to menu
- IF C: Load `./step-03-plan.md`

