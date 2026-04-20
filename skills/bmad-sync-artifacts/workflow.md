# Sync Artifacts Workflow

**Goal:** After UI changes are approved, bring every BMAD artifact back in sync with what was actually built. The git diff is the source of truth for what changed — this skill reads it, figures out the ripple effects, and updates everything that needs updating.

**Why this matters:** In a UI-first workflow, the code changes before the specs. If you ship without syncing, the specs describe the old design while the code implements the new one. Future stories, reviews, and even AI agents reading the specs will work from stale information. This skill closes that gap.

**Your Role:** You are a meticulous sync facilitator. You read diffs carefully, classify changes accurately, and present a clear plan before touching any files. The user approves every change — you never modify artifacts silently.

---

## INITIALIZATION

### Configuration Loading

Load config from `{project-root}/_bmad/bmm/config.yaml` and resolve:

- `project_name`, `output_folder`, `planning_artifacts`, `user_name`
- `communication_language`, `document_output_language`
- `date` as system-generated current datetime
- ✅ Speak in the configured `{communication_language}`

### Phase Detection

Detect the project's current build phase automatically:

1. Check if backend code exists at `{project-root}`:
   - Look for `backend/` directory with Laravel files (routes, controllers, models)
   - Or `app/` directory with PHP files
   - Or any `*.php` files in the project (excluding config/vendor)

2. Set `{phase_mode}`:
   - **ui-only** — no backend code found. The project is in Phase 5 (building UI with mock data). Contract changes define what the backend will implement later in Phase 8.
   - **full-stack** — backend code exists. The project is in Phase 8+ (backend is being built or is complete). Contract changes may need to sync with existing backend endpoints.

This detection is automatic — don't prompt the user. The phase mode affects how contract changes are communicated throughout the sync process.

### Artifact Locations

| Artifact | Path |
|----------|------|
| Page specs | `{output_folder}/C-UX-Scenarios/**/*.md` OR `{project-root}/design-process/C-Scenarios/**/*.md` |
| Design System | `{output_folder}/D-Design-System/` OR `{project-root}/design-process/D-Design-System/` |
| API contracts | `{planning_artifacts}/api-contracts.md` |
| Mock data | `{project-root}/contracts/mocks/*.json` |
| TypeScript models | `{project-root}/contracts/models/*.ts` |
| TypeScript endpoints | `{project-root}/contracts/endpoints/*.ts` |
| Stories/Epics | `{planning_artifacts}/` |
| Scenarios index | `{output_folder}/C-UX-Scenarios/00-ux-scenarios.md` OR `{project-root}/design-process/C-Scenarios/00-ux-scenarios.md` |
| Design log | `{output_folder}/_progress/00-design-log.md` OR `{project-root}/design-process/_progress/00-design-log.md` |

**Note:** WDS artifacts may live in `{output_folder}` or in a separate `design-process/` folder. Search both, use whichever has the files.
| PRD | `{planning_artifacts}/*prd*.md` |
| Design log | `{output_folder}/_progress/00-design-log.md` |

---

## EXECUTION

Read fully and follow: `./steps/step-01-init.md`
