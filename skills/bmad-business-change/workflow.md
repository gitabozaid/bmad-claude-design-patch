# Business Change Orchestrator

**Goal:** Handle the full lifecycle of a business-level change during active BMAD development — from understanding the change through PRD update, artifact cascade, gap analysis, story management, and verification. Nothing falls through the cracks.

**Your Role:** Change orchestrator. You compose existing BMAD skills (/bmad-edit-prd, /bmad-correct-course) and add the critical missing layers: gap analysis, story generation, and verification.

---

## Why This Skill Exists

When a business requirement changes mid-development, updating the PRD is only 20% of the work. The other 80% is:
- Cascading to all artifacts (architecture, contracts, specs, mocks)
- Discovering which EXISTING stories and code are now stale
- Creating NEW stories that the change requires (in the correct phase!)
- Verifying nothing was missed

Previously this required manual coordination of /bmad-edit-prd + /bmad-correct-course + manual story review. This skill automates the full chain and adds the gap analysis that prevents missed work items.

---

## Initialization

### Configuration Loading

Load config from `{project-root}/_bmad/bmm/config.yaml` and resolve:
- `project_name`, `user_name`, `communication_language`, `document_output_language`
- `planning_artifacts`, `implementation_artifacts`
- YOU MUST ALWAYS SPEAK in `{communication_language}`
- YOU MUST ALWAYS WRITE documents in `{document_output_language}`

### Load Project State

Read these files to understand where the project is:
- `{project-root}/_bmad-output/roadmap-progress.yaml` — current phase, epic, story
- `{project-root}/_bmad-output/implementation-artifacts/sprint-status.yaml` — story statuses
- `{project-root}/_bmad-output/planning-artifacts/epics.md` — all epics and stories

---

## Phase 1: Triage

Understand what the user wants to change and classify the magnitude.

### 1.1 Listen and Understand

Let the user describe the change. Ask clarifying questions until you understand:
- What specifically is changing?
- Why is it changing?
- What's the user's vision for how it should work?

### 1.2 Classify Magnitude

Based on the description, classify as:

| Magnitude | Examples | Workflow |
|-----------|----------|----------|
| **Small** | Copy change, styling tweak, single field addition, i18n update | Skip discussion → Quick PRD edit → Targeted cascade → Verify |
| **Medium** | New UI element, changed business rule, added validation, new component | Brief discussion → PRD edit → Gap analysis → Cascade → Verify |
| **Large** | New feature, monetization model change, architectural shift, new user flow | Full discussion with party mode → PRD edit → Full gap analysis → Full cascade → Story management → Verify |

Present classification to user: "This looks like a **[magnitude]** change. Here's my plan: [outline]. Does this match your expectation?"

User can override: "Actually this is bigger/smaller than you think."

---

## Phase 2: Discussion (Medium/Large only)

### For Large changes:
Invoke `/bmad-party-mode` via Skill tool. Ask the agents to discuss:
- Is this change sound from product/architecture/UX perspectives?
- What are the risks and edge cases?
- What's the recommended approach?

Evaluate agent feedback — agree/disagree with rationale. Present your synthesis to the user. Iterate until alignment.

### For Medium changes:
Brief discussion with user. No party mode unless user requests it.

### For Small changes:
Skip — go directly to Phase 3.

---

## Phase 3: PRD Update

Invoke `/bmad-edit-prd` via Skill tool to update the PRD with the agreed changes.

Wait for it to complete. The PRD is now the source of truth for the change.

**Important:** Before moving to Phase 4, extract a **Change Summary** from the PRD diff:
- What concepts were added/removed/modified?
- What FRs changed?
- What NFRs changed?

Store this summary — it drives the gap analysis.

---

## Phase 4: Gap Analysis

This is the core value of this skill. Read the full procedure from `./references/gap-analysis.md`.

**Inputs:** Change Summary from Phase 3, current project state from initialization.

**Outputs:** A Screen-Centric Impact Report (template in `./references/impact-report-template.md`).

The gap analysis answers three questions:
1. **What artifacts need updating?** (architecture, api-contracts, page specs, TypeScript contracts, mocks)
2. **What NEW stories are needed?** (in the correct phase — Phase 5 = UI stories, Phase 8 = backend stories)
3. **What EXISTING code is now stale?** (completed stories whose implementation no longer matches the PRD)

---

## Phase 5: User Approval Gate

Present the Impact Report to the user. This is a decision point.

Display:
```
CHANGE: {one-line summary}
MAGNITUDE: {small/medium/large}

SCREENS AFFECTED: {count}
{For each screen: name, what changes, new/existing/both}

ARTIFACTS TO UPDATE: {count}
{List with specific sections}

NEW STORIES NEEDED: {count}
{List with epic, story number, title, phase}

EXISTING CODE TO UPDATE: {count}
{List with story reference, file paths, what changed}

ESTIMATED EFFORT: {low/medium/high}
```

Then ask:
- **[P] Proceed** — Execute the full cascade and story management
- **[M] Modify** — Adjust the plan (remove/add items)
- **[S] Split** — This is too big, let's break it into smaller changes
- **[A] Abort** — Cancel, the change is not worth the effort

Wait for user input. Only proceed on [P].

---

## Phase 6: Cascade

Now update all affected artifacts. Use a combination of:

### 6.1 Planning Artifacts
Launch agents (in parallel where possible) to update:
- **Architecture** — voice layer, subscription model, DB schema, API routes
- **API Contracts** — endpoints, request/response types, new endpoints
- **Page Specs** — affected screen specs

**Important:** Each agent MUST only edit planning/design artifacts (markdown files in `_bmad-output/` and `design-process/`). Agents MUST NOT edit TypeScript code files — that happens through the story protocol.

### 6.2 TypeScript Contracts & Mocks (Planning Only)
Update the **api-contracts.md** document to reflect new TypeScript interfaces, endpoints, and mock data shapes. The actual `.ts` files will be updated when stories are implemented — not here.

**Why not update code directly?** Because code changes go through the story protocol (create story → implement → review → ship). Updating code outside that protocol creates untested, unreviewed changes.

---

## Phase 7: Story Management

Based on the Gap Analysis:

### 7.1 New Stories
For each new story identified:
1. Add to `epics.md` under the correct epic
2. Add to `sprint-status.yaml` with status `backlog`
3. Update `roadmap-progress.yaml` if epic story counts changed

Determine the correct epic:
- If the change adds a new screen → new story in the relevant existing epic
- If the change modifies an existing screen → story in the same epic as the original
- If the change is cross-cutting → may need stories in multiple epics

### 7.2 Existing Stories
For stories that are affected:
- **Pending stories (not yet implemented):** Update the story description and ACs in epics.md
- **Completed stories (code exists):** Add a modification note to the story entry in epics.md. The actual code update will happen through a new story or during the next story that touches that screen.

### 7.3 Sprint Status
Update `sprint-status.yaml`:
- New stories added with status `backlog`
- Affected pending stories flagged with note
- Sprint plan may need reordering

---

## Phase 8: Verification Gate

Read the full verification checklist from `./references/verification-checklist.md`.

Run every check. If ANY check fails, report what's missing and fix it before completing.

The verification ensures:
1. Every PRD change is reflected in at least one artifact
2. Every new concept has a TypeScript contract definition (in api-contracts.md)
3. Every affected screen has a story (new or modified)
4. Every completed story flagged as stale has a remediation plan
5. Sprint status is consistent with epics

---

## Completion

When all phases are complete:

Display:
```
BUSINESS CHANGE COMPLETE

Change: {summary}
PRD: Updated ({count} FRs modified)
Artifacts: {count} updated
New Stories: {count} added
Existing Stories: {count} flagged for update
Verification: All {count} checks passed

Next Steps:
{List what the user should do next — e.g., "Continue with Story 4.5" or "Start new story 4.6 for voice mode selector"}
```
