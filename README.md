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

**Install:**
```bash
cd /path/to/your/project
bash ~/Desktop/workspace/abozaid/bmad-claude-design-patch/install.sh
```

**Start the roadmap:**
```bash
/bmad-roadmap-v2
```

That's it. The orchestrator walks you through all 9 phases.

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

## Before Phase 4 — App Shell in Code (one-time prerequisite)

Claude Design doesn't have a Figma-style shared layout across projects. To guarantee consistency across journey-per-project designs, the app shell (header, footer, sidebar, navigation — the chrome that appears on most screens) lives **in the codebase**, not in each Claude Design project.

The workflow:

1. Go to [claude.ai/design](https://claude.ai/design) and create a project named **"00 — App Shell"**
2. Design the shell and all variants:
   - Default state, scrolled state, mobile (hamburger), desktop
   - Any role-gated differences (admin vs regular user)
3. Export → **Hand off to Claude Code**
4. In Claude Code, paste the handoff prompt on a new branch `chore/app-shell`
5. Claude Code implements `AppLayout.tsx` (or your stack's equivalent):
   - Next.js App Router → `app/layout.tsx`
   - Next.js Pages Router → `pages/_app.tsx`
   - Vue → `layouts/default.vue`
   - Vanilla React → `src/App.tsx`
6. Review + merge to `main` — this is a **foundation change**, not a story. No Kateb, no Naqed, no retrospective.
7. Run `/bmad-roadmap-v2`. At the Phase 4 pre-flight, answer `[yes]` and provide the path to AppLayout. The orchestrator records it in `design-progress.yaml` and proceeds to the per-epic loop.

**The payoff:** every per-epic Claude Design project attaches the codebase (which now contains the shell) so all generated screens respect the same shell automatically. And the story protocol enforces "shell is fixed" on the build side (Saneh) and compare side (Naqed).

### Pre-flight options

When `/bmad-roadmap-v2` reaches Phase 4, it asks:

- **`[yes]`** — the shell is implemented; tell me the path
- **`[no]`** — guide me through the shell workflow (do the steps above, come back)
- **`[skip]`** — my product has no persistent shell (single-screen landing, minimal PWA, interstitial). Skip all shell-related instructions. Codebase attachment becomes OPTIONAL instead of REQUIRED.

The `[skip]` choice is sticky — the orchestrator won't re-ask.

### Shell revision mid-project

If during Phase 6 (Build) a story surfaces a shell-level issue ("header should be smaller", "nav items wrong"), the story protocol's "Escape to App Shell" path kicks in: iterate in the "00 — App Shell" Claude Design project, re-implement AppLayout, re-merge to main. Stories already shipped auto-inherit the new shell (it's a shared component).

---

## Design System setup (one-time, before Phase 4)

Before the first epic of Phase 4 (but after the App Shell workflow above):
1. Open [claude.ai/design](https://claude.ai/design)
2. Create an organization for this project
3. Upload your project's design system (link GitHub repo OR upload component library folder)
4. Review the extracted tokens + components
5. Toggle "Published" so every project under the organization inherits it

Every subsequent Claude Design project for this product automatically uses the same design system. No need to repeat per epic.

---

## Story protocol (Phase 6, full-stack)

Each story runs through 10 steps in a single branch:

```
Step 1:  Branch
Step 2:  Saneh — Full-Stack Build (UI + API + DB + tests in one pass)
Step 3:  User Review [PAUSE]
Step 4:  Naqed — Visual QA
         4a. Design Compliance (vs Bundle URL)
         4b. Critique (UX)
         4c. Audit (a11y + perf)
Step 5:  User Final Approval [PAUSE]
Step 6:  Simplify
Step 7:  Code Review
Step 8:  PR Review (parallel)
Step 9:  Verify (stack-detected)
Step 10: Ship
```

**User Final Approval at Step 5** classifies your fixes:
- Code-level → re-invoke Saneh
- Design-level → escape back to Phase 4 for that epic

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
