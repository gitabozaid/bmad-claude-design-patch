# Step 4: Execute Sync

## MANDATORY EXECUTION RULES (READ FIRST):

- 📖 Read the complete step file before taking any action
- ✅ Speak in `{communication_language}`
- ✅ Only execute changes that were in the approved plan from step 3
- 🚫 Never add changes that weren't in the plan without asking first

## YOUR TASK:

Apply every update from the approved sync plan. Work through the plan methodically — one artifact at a time.

## EXECUTION ORDER:

The order matters because some artifacts reference others. Update in this sequence:

### 1. TypeScript Contracts (models → endpoints)

Update the TypeScript interfaces and endpoint types first, because api-contracts.md and mock data reference these types.

- Read the current file
- Apply the planned changes (add/remove/modify fields or endpoints)
- Verify the result compiles logically (types reference each other correctly)

### 2. API Contracts Document

Update `{planning_artifacts}/api-contracts.md`:

- Model definitions section — must match the TypeScript interfaces exactly
- Endpoint definitions section — must match the TypeScript endpoint types
- Screen contracts section — add/update/remove screen mappings
- For new screens: add a new screen section with the anchor name

### 3. Mock Data

Update or create JSON mock files in `contracts/mocks/`:

- Every field in the mock must match the updated TypeScript interface
- New fields get realistic values (not placeholders)
- Removed fields get deleted from every object in the mock
- New mock files get enough data to fill the screen (not just one item)

### 4. Page Specs

Update existing page specs in `{output_folder}/C-UX-Scenarios/`:

For each page spec in the plan:
- **Layout diagram** — update the ASCII diagram if structure changed
- **OBJECT IDs** — add new ones, remove deleted ones
- **Content** — update text, labels, translations for changed elements
- **States** — update if state behavior changed
- **Component references** — update design system references if components changed
- **API Contracts reference link** — add if new screen, verify if existing

For new page specs:
- Create following the same template as existing specs in the project
- Include all sections: metadata, overview, layout, sections with OBJECT IDs, states
- Add the API contracts reference link

### 5. Scenarios Index

If the screen inventory changed (new screen, deleted screen, restructured):

- Update `00-ux-scenarios.md` coverage matrix
- Update the scenario file if screen was added/removed from a scenario

### 6. Stories / Epics

If the plan includes story updates:

- For new screens: create a story note (the full story can be created later with `/bmad-create-story`)
- For restructured screens: mark affected stories as needing review
- Don't create full BMAD stories here — just note what needs to be created

### 7. PRD (only if Type 5 — New Feature)

If the plan includes PRD updates:

- Add a new FR (functional requirement) for the feature
- Use the next available FR number
- Keep it concise — one paragraph describing the feature

## AFTER EACH ARTIFACT:

After updating each artifact group, briefly confirm:

```
✅ TypeScript contracts updated (word.ts — added lastPracticed)
✅ api-contracts.md updated (WordSummary model + my-words screen mapping)
✅ Mock data updated (get-words.json — 30 objects updated)
✅ Page spec updated (01b.2-my-words.md — new OBJECT ID + content)
...
```

## CONTINUE:

After all updates are applied:

Display: "[C] Continue to Verification | [M] Abort (revert changes)"

When C selected → load `./step-05-complete.md`
