# Comparison Logic

Rules for detecting what changed between the existing stories and the final designs in the Claude Design bundle.

## Principle

The bundle's final designs are the source of truth. Existing stories are the baseline. Changes flow FROM bundle TO stories.

## Layered comparison

### Layer 1: Screen identity

For each story in the epic:
- Extract the screen's canonical name (from story title or Design Reference if present)
- Search the bundle's list of screens for a matching name

Matching strategy (in order):
1. Exact name match → CONFIRMED same screen
2. Slug match (after normalization) → CONFIRMED same screen
3. Semantic similarity > 0.85 (e.g., "Login Page" vs "Sign In") → PROBABLE RENAME — ask user if ambiguous
4. No match → CANDIDATE FOR REMOVAL

For each bundle screen:
- If no matching story found → CANDIDATE FOR NEW STORY

### Layer 2: Screen structure (section-level)

For screens that match (same identity), compare their sections:

- Extract section list from the bundle's visual (header, main, sidebar, footer, custom named sections)
- Extract implied section list from the story's acceptance criteria and tasks

Change detection:
- Section present in bundle but not implied by story → ADDED SECTION
- Section implied by story but not in bundle → REMOVED SECTION
- Section present in both but with different component list → MODIFIED SECTION

### Layer 3: Components within a section

For matched sections, compare the components:

- Bundle component list: extracted from the visual design (cards, buttons, inputs, etc.)
- Story component list: extracted from tasks or acceptance criteria

- Component in bundle not in story → ADDED COMPONENT
- Component in story not in bundle → REMOVED COMPONENT
- Same component slot filled differently (e.g., "card" replaced by "accordion") → REPLACED COMPONENT

### Layer 4: Copy / content

For each text element in matched components:
- Labels (button text, heading text)
- Copy (body text, descriptions)
- Error messages
- Placeholders

- Bundle text differs from story's specified copy → MODIFIED COPY
- New text in bundle with no story equivalent → ADDED COPY

### Layer 5: State coverage

For each screen, identify which states are DESIGNED:
- Default
- Loading
- Empty
- Error
- Hover (for interactive elements)
- Disabled
- Focused

Compare to the story's Edge Cases list:
- State designed but not in story Edge Cases → ADD to Edge Cases
- State in story but not designed → FLAG (Claude Design may have missed it; user decides)

## Edge cases

### Screen merge (2 stories → 1 screen)

If two stories (X.1, X.2) both semantically match a single bundle screen:
- Classify as MERGE
- Action: combine the two stories' acceptance criteria into one, archive the second story, update epic file

### Screen split (1 story → 2 screens)

If one story has two matching bundle screens:
- Classify as SPLIT
- Action: keep the original story for the first bundle screen, create a new story for the second, update epic file

### Ambiguous matches

If multiple stories are equally similar to a bundle screen (< 0.2 confidence gap):
- HALT — ask user to disambiguate

## Output

The comparison layer produces a structured `changes[]` array with items like:

```yaml
- type: ADDED_SCREEN
  bundle_screen: "Email Verification"
  position: 3    # where to insert among existing stories
  implied_story_id: "1.3"
  
- type: MODIFIED_SECTION
  story_id: "1.2"
  screen: "Language Selection"
  section: "Options List"
  changes:
    - added_component: "Search input"
    - modified_copy: "Continue" → "Start learning"

- type: REMOVED_SCREEN
  story_id: "1.5"
  screen: "Newsletter Signup"
  
- type: PRD_CONFLICT        # HALT case
  screen: "Home"
  detail: "Bundle shows a share-to-social button; PRD FR-22 says sharing is deferred to Phase 2"
```

This array feeds into the propagation rules in the next reference.
