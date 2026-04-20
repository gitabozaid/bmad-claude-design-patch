# Gap Analysis Procedure

The gap analysis is the core value of /bmad-business-change. It answers: "Given this PRD change, what work is missing?"

## Inputs

- **Change Summary**: Extracted from PRD diff — what concepts/FRs/NFRs changed
- **Project State**: Current phase, completed/pending stories, epic structure

## Step 1: Extract Changed Concepts

From the PRD diff, build a list of **changed concepts**. A concept is a domain term or feature area.

Example: If FR-SUB1 changed from "feature gating" to "credits only", the changed concepts are:
- `subscription-model` (changed)
- `feature-gating` (removed)
- `credits` (added)
- `voice-mode-selection` (added)

## Step 2: Scan Artifacts for Impact

For each artifact type, search for references to changed concepts:

### 2.1 Architecture (`architecture.md`)
Grep for changed concepts. Flag sections that reference them.
- System components mentioning the concept
- API routes affected
- DB schema changes needed
- Middleware/service layer changes

### 2.2 API Contracts (`api-contracts.md`)
- Endpoints that handle the changed concept
- Request/response types that reference it
- New endpoints needed
- TypeScript interface changes described in the document

### 2.3 Page Specs (`design-process/**/pages/**/*.md`)
- Screens that display or interact with the changed concept
- UI elements that reference it (buttons, forms, displays)
- User flows that include it

### 2.4 TypeScript Contracts (`frontend/src/contracts/`)
- Model interfaces referencing the concept
- Endpoint types referencing it
- Mock data that includes it
- Note: Don't EDIT these files — just identify what needs changing. Actual changes happen through story protocol.

## Step 3: Scan Stories for Impact

### 3.1 Read All Epics and Stories
Load `epics.md` and scan every story's:
- Title and description
- Acceptance criteria
- Referenced FRs

### 3.2 Classify Each Story

For each story, determine:

| Status | Impact | Action |
|--------|--------|--------|
| **Completed** + concept match | Code is stale | Flag for code update (new story or inline fix) |
| **In-progress** + concept match | Story needs updating | Update story ACs and tasks |
| **Pending** + concept match | Story spec is stale | Update story description/ACs in epics.md |
| **No match** | Not affected | Skip |

### 3.3 Check for MISSING Stories

This is the critical step that was previously missed.

For each changed concept, ask:
- Does this concept need a NEW screen or UI element? → New UI story needed
- Does this concept need a NEW API endpoint? → New backend story needed
- Does this concept change how an EXISTING screen works? → Modification story needed

**Phase-aware story creation:**
Read `roadmap-progress.yaml` to determine current phase:
- **Phase 5 (Build UI)**: Create UI stories with mock data
- **Phase 6 (Deploy UI)**: Flag for post-deploy update
- **Phase 7 (Plan Backend)**: Create backend stories
- **Phase 8 (Build Backend)**: Create backend implementation stories
- **Other phases**: Flag for future planning

## Step 4: Scan Completed Code

For stories marked as "completed" that are affected:

1. Read the story file to find which files were created/modified
2. If story file has a "files" or "Dev Agent Record" section, extract file paths
3. If not, check git log for commits referencing the story number
4. List the specific source files that need updating

## Step 5: Build Impact Report

Compile findings into the Screen-Centric Impact Report format (see `./impact-report-template.md`).

Group by SCREEN (not by artifact type) because developers think in screens:
- "The Practice Screen needs: spec update + new story for voice mode selector + code update to remove tier gating"
- NOT: "epics.md needs update, page spec needs update, practice-type-selector.tsx needs update"

## Common Pitfalls

1. **Don't skip TypeScript contracts** — They're code but they're also specs. Note what needs changing in api-contracts.md.
2. **Don't defer vaguely** — "Future story needed" is not acceptable. Specify: which phase, which epic, what the story does.
3. **Check the CURRENT phase** — A UI feature added to the PRD during Phase 5 needs a Phase 5 UI story, not a Phase 8 backend story.
4. **Cross-reference laterally** — If "subscription" changes, find EVERY artifact that mentions subscription, not just the obvious ones.
