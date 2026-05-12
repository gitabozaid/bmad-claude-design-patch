# BMAD Claude Design Patch (v3)

A BMAD patch that replaces the WDS + per-screen-spec workflow with **BMM-native + [Claude Design](https://claude.ai/design) + full-stack stories**. 9 phases instead of 11. One consolidated UX doc. One design source of truth per epic (Claude Design bundle). One PR per story (full-stack slice).

**Who this is for:** new BMAD projects that want a clean, design-first flow where Claude Design drives visuals and each story is a full-stack slice (UI + API + DB + tests in one PR).

**Who this is NOT for:** projects already built on the old `bmad-figma-patch` (v1). Keep them on v1 — this patch explicitly refuses to install over v1 without `--force-migrate`.

---

## Quick start

**Prerequisites:**
- BMAD initialized in the project (`bmad setup` or equivalent)
- [Claude.ai](https://claude.ai) Pro (or higher) subscription — Claude Design is Pro+
- New project, OR existing project that's never had v1 installed

**Fresh install:**
```bash
cd /path/to/your/project
bash ~/Desktop/workspace/abozaid/bmad-claude-design-patch/install.sh
```

Copies the patch files into your project (self-contained — the project owns its copy, not a link to the patch repo). Records the installed commit in `.bmad/.patch-version`.

**Start the roadmap:**
```bash
/bmad-roadmap-v2
```

That's it. The orchestrator walks you through all 9 phases.

## Install modes

```bash
# Fresh install (default) — copies files into the project
bash install.sh

# Update existing install to the latest patch commit
bash install.sh --upgrade

# Check which commit is installed + drift from remote (read-only)
bash install.sh --status

# Dev mode only — symlink instead of copy (for iterating on the patch itself)
bash install.sh --symlink
```

### How upgrades work

`--upgrade` copies the latest patch files over the existing install. Any file that was **locally modified** (differs from what was originally installed) is **backed up first** to `.bmad/backups/<timestamp>/` before being overwritten. Unmodified files are silently overwritten.

Your project data (`design-progress.yaml`, `deferred-work.md`, `bundle.md` files, etc.) is never overwritten — those are treated as project-owned and only seeded on fresh install if absent.

### Migration from earlier symlink installs

Older versions of this installer (pre-v3.2) symlinked skills into `.claude/skills/` instead of copying. Running `--upgrade` on such a project auto-detects the symlinks and converts them to real copies. No manual steps needed.

---

## The 9 phases

```
Phase 1: Discover              PRD + Architecture
Phase 2: UX Design             bmad-create-ux-design (one consolidated doc)
Phase 3: Epics & Stories       bmad-create-epics-and-stories-v2
Phase 4: Per-Epic Design Loop  Claude Design → sync-from-design (manual step)
Phase 5: Sprint Planning       bmad-sprint-planning
Phase 6: Build                 Story protocol (full-stack per story)
Phase 7: Deploy                Full-stack production deploy
Phase 8: Harden                NFR + test review + E2E
Phase 9: Evolve                Ongoing evolution
```

**Phase 4 is the only phase with manual browser work.** You design screens in claude.ai/design, export a handoff bundle, and the skill syncs changes back to stories automatically.

---

## Skills added by this patch

| Skill | Purpose |
|-------|---------|
| `/bmad-roadmap-v2` | 9-phase orchestrator (replaces `/bmad-roadmap` for new projects) |
| `/bmad-claude-design-prep` | Per-epic Phase 4 prep: generates attachment checklist + ready-to-paste prompt + handoff landing file |
| `/bmad-sync-from-design` | Reads handoff bundle, deep-compares vs stories, propagates changes to all artifacts |
| `/bmad-create-epics-and-stories-v2` | Wraps BMM skill + runs adversarial + edge-case reviews on every story |
| `/ship` | PR workflow (carried from v1) |
| `/bmad-business-change` | Scope change orchestrator (carried from v1) |
| `/bmad-sync-artifacts` | Standalone artifact sync (carried from v1) |

Plus overlays on base BMM skills (`bmad-code-review`, `bmad-retrospective`) to include the deferred-work protocol.

---

## What v3 removes vs v1

| Removed | Reason |
|---------|--------|
| WDS workflow (wds-0, wds-2, wds-3, wds-4, wds-7) | Replaced by single `bmad-create-ux-design` that reads PRD directly |
| `/bmad-create-api-contracts` | No UI/backend split → no contracts needed |
| `/bmad-validate-spec` + bulk variant | No per-screen specs to validate |
| Banna + Haddad agents | Merged into Saneh (full-stack builder) |
| Kateb agent | Responsibilities moved to `/bmad-create-epics-and-stories-v2` + `/bmad-sync-from-design` |
| Mir'a step in story protocol | Sync happens in Phase 4, not per-story |
| UI-only deploy phase | Deploys full-stack (Phase 7) |

---

## How Phase 4 works (the new part)

Phase 4 runs a loop per epic. For each epic:

1. Orchestrator invokes `/bmad-claude-design-prep --epic=<slug>`
2. Skill prints:
   - **Attachment checklist** — which files to upload to Claude Design (PRD, UX doc, epic file, story files)
   - **Ready-to-paste prompt** — with aesthetics guidance to avoid generic AI output
3. You open [claude.ai/design](https://claude.ai/design), create a project, upload files, paste prompt
4. You iterate on the designs until satisfied
5. You export → "Hand off to Claude Code" → get a bundle URL + handoff prompt
6. You paste these into `design-process/claude-design-handoffs/<epic-slug>/bundle.md`
7. Run `/bmad-sync-from-design --epic=<slug>`
8. Skill:
   - Fetches the bundle via WebFetch
   - Compares final designs vs existing stories (screen-level, section-level, component-level, copy-level, state coverage)
   - Propagates changes autonomously to all affected artifacts
   - Marks the epic `design-complete`
   - Prints a diff summary
9. Orchestrator advances to the next epic

---

## Phase 4 setup (one-time, before per-epic loops)

Phase 4 uses **ONE Claude Design project for the whole product**, hosting one chat per epic/journey inside it. Two setup steps:

### Setup 1 — Org-level Design System

Done once per organization, then inherited by every project in it:

1. Open [claude.ai/design](https://claude.ai/design) and switch to (or create) the org for this product.
2. Open **Design System** in the org.
3. Upload the canonical inputs:
   - `tokens.css` — Tailwind v4 CSS variables (colors / spacing / radius / typography)
   - `design-system-brief.md` — brand identity + aesthetic guardrails
   - `typography-specimens.md` — type scale specimens
   - `component-inventory.md` — Tier 2 + Tier 3 expected components
   - `fonts/*.woff2` + `fonts/fonts.css` — self-hosted fonts
   - Or link a GitHub repo containing the above
4. Wait for Claude Design to generate preview cards (~5–10 min).
5. Sanity-check the auto-generated preview cards (Color · Primary, Type · Headings, etc.). Use the per-card "Looks good" / "Needs work…" buttons to refine.
6. Toggle **Published**.

### Setup 2 — Product project

Done once per product:

1. From the Claude Design homepage, click **+ Create new design** (or **Use this system → ↗ New design** from the design system page).
2. Project name: **the product name** (NOT an epic name).
3. Design system: the one you just published.
4. Pick **High fidelity + Interactive prototype** → **Create**.
5. Inside the project, drag-drop the **stable product docs** ONCE onto the canvas. Claude Design auto-files them into a project-level `uploads` folder; they inherit into every new chat automatically:
   - `prd.md`
   - `ux-design-specification.md`
   - `architecture.md`
   - `epics.md`
6. No acknowledgement message needed. Per-chat prompts (printed by `/bmad-claude-design-prep`) name the files explicitly so Claude Design knows to consult them.
7. Record the project URL in `_bmad-output/implementation-artifacts/design-progress.yaml: product_project.url`.

### Why no separate "App Shell" project

Claude Design carries shell consistency across chats inside the same project automatically. Shell evolution happens organically inside the journey/epic chats and is captured in each handoff bundle. The earlier patch revision included a `chore/app-shell` workflow as a separate prerequisite — it was removed (2026-05-12) once it became clear the project-level model made it unnecessary.

If during Phase 6 (Build) a story surfaces a shell-level issue, the story protocol's "Escape to App Shell" path now routes back into the same product project (start a new chat, iterate on the shell, sync) — no separate project required.

### Why stories upload per-chat and not at project level

Stories get rewritten by `/bmad-sync-from-design` (acceptance criteria + edge cases + Design Reference block). If stories were uploaded at the project level, an older chat would inherit the pre-sync version while disk has the post-sync version → drift. Per-chat upload from disk guarantees every chat sees the latest version.

---

## Story protocol (Phase 6, full-stack)

Each story runs through 9 steps in a single branch. Pause model (revised 2026-05-12): one PAUSE per story (light) + one PAUSE per epic (holistic). No Critique sub-step — the Claude Design bundle IS the approved visual.

```
Step 1: Branch
Step 2: Saneh — Full-Stack Build (UI + API + DB + tests in one pass)
Step 3: Naqed — Visual + Technical QA (automated, no pause)
        3a. Compliance (screenshot diff vs Bundle URL, RTL+LTR)
        3b. Audit (a11y + perf)
Step 4: User Review [PAUSE — light, per story]
        User sees the cleaned screen, does a quick visual + flow check.
        Fixes classified two-way (CONTENT / JOURNEY).
Step 5: Simplify
Step 6: Code Review
Step 7: PR Review (parallel)
Step 8: Verify (stack-detected)
Step 9: Ship
```

After the last story of each epic, run **Epic Close-out**:

```
E1: User Final Approval [PAUSE — per epic, holistic walk-through]
    Approve epic OR surface fixes (CONTENT → re-invoke Saneh on
    affected story / JOURNEY → escape to Phase 4).
E2: /bmad-retrospective
E3: /bmad-testarch-trace
E4: Mark epic complete; advance to next epic.
```

**Fix classification (Step 4 or E1):**
- CONTENT-level → re-invoke Saneh on the affected story
- JOURNEY-level → escape back to Phase 4 for that epic (re-design + re-sync)

**Per-epic wrappers** (first epic only: test-infra setup; after each epic: retrospective + test trace) are in the Story Protocol reference file.

---

## Migration from v1 (advanced — not recommended)

If you absolutely must migrate an existing project from v1 to v3:

1. **Archive** the old WDS-specific content:
   ```bash
   mkdir -p .bmad-legacy
   mv design-process/C-Scenarios .bmad-legacy/
   mv design-process/G-Specifications .bmad-legacy/ 2>/dev/null
   mv docs/api-contracts.md .bmad-legacy/ 2>/dev/null
   ```
2. **Keep** the existing PRD + Architecture (they're compatible)
3. **Run** the install with `--force-migrate`:
   ```bash
   bash ~/Desktop/workspace/abozaid/bmad-claude-design-patch/install.sh --force-migrate
   ```
4. **Re-run Phase 2** (`/bmad-create-ux-design`) to produce the consolidated UX doc
5. **Re-run Phase 3** (`/bmad-create-epics-and-stories-v2`) to regenerate epics + stories
6. **Proceed to Phase 4** (Claude Design)

In-flight stories and shipped work are unaffected — this only replaces planning artifacts going forward.

---

## Troubleshooting

### WebFetch can't read the Claude Design bundle

If `/bmad-sync-from-design` reports "thin content" from WebFetch:
1. Go to claude.ai/design
2. Export the bundle as a ZIP (alternate export option)
3. Save it to `design-process/claude-design-handoffs/<epic-slug>/bundle.zip`
4. Re-run: `/bmad-sync-from-design --epic=<slug> --bundle-zip=<path>`

### BMAD update overwrote an overlay

The patch overlays two BMM files:
- `bmad-code-review/steps/step-04-present.md`
- `bmad-retrospective/workflow.md`

If BMAD auto-updates, these may revert. Fix:
```bash
cd /path/to/project
bash ~/Desktop/workspace/abozaid/bmad-claude-design-patch/install.sh
```
The install is idempotent; it re-applies overlays.

### Claude Design token usage

Claude Design consumes tokens aggressively during iteration. Tips:
- Start with detailed prompts so you need fewer iterations
- Upload brand assets upfront — prevents "AI slop" defaults
- Reference components by name from your attached codebase
- Batch decisions (comment on multiple elements in one chat turn) rather than one-at-a-time

### Claude Design not available

Claude Design requires Pro or higher. If you don't have it, use the v1 patch (`bmad-figma-patch`) which works with Figma MCP or HTML prototypes instead.

---

## Repo layout

```
bmad-claude-design-patch/
├── install.sh                  Main installer
├── README.md                   This file
├── LICENSE                     MIT
├── skills/
│   ├── bmad-roadmap-v2/        9-phase orchestrator
│   ├── bmad-claude-design-prep/
│   ├── bmad-sync-from-design/
│   ├── bmad-create-epics-and-stories-v2/
│   ├── ship/                   (from v1)
│   ├── bmad-business-change/   (from v1)
│   ├── bmad-sync-artifacts/    (from v1)
│   ├── bmad-code-review/       (overlay from v1)
│   └── bmad-retrospective/     (overlay from v1)
└── templates/
    ├── bundle.md               Copied to design-process/claude-design-handoffs/
    ├── design-progress.yaml    Copied to _bmad-output/implementation-artifacts/
    ├── roadmap-progress.yaml   Template for /bmad-roadmap-v2
    └── deferred-work.md        (from v1)
```

---

## Related

- [BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD) — the upstream BMAD framework
- [Old patch: bmad-figma-patch (v1)](https://github.com/gitabozaid/bmad-patch) — for existing projects
- [Claude Design](https://claude.ai/design) — Anthropic's visual design tool (Pro+)
- [Anthropic Cookbook — Frontend Aesthetics](https://platform.claude.com/cookbook/coding-prompting-for-frontend-aesthetics) — prompt guidance embedded in the prep skill

---

## License

MIT — see [LICENSE](LICENSE).
