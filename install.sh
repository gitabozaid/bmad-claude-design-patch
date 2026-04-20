#!/bin/bash
# BMAD Claude Design Patch (v3) — installer
# For NEW projects using BMM-native + Claude Design + full-stack stories.
# Old projects (using bmad-figma-patch) should NOT run this — they stay on v1.

set -e

PATCH_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(pwd)"
CLAUDE_SKILLS_DIR="$PROJECT_DIR/.claude/skills"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║ BMAD Claude Design Patch (v3) — Installer                     ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Project: $PROJECT_DIR"
echo "Patch:   $PATCH_DIR"
echo ""

# ---------- Prerequisite: BMAD must be initialized ----------

if [ ! -d "$PROJECT_DIR/_bmad/bmm" ]; then
    echo "ERROR: No _bmad/bmm/ found at $PROJECT_DIR"
    echo ""
    echo "BMAD must be initialized first. Run 'bmad setup' (or equivalent) before installing this patch."
    exit 1
fi

# ---------- Old-patch detection ----------
# v1 patch (bmad-figma-patch) leaves these fingerprints. Refuse to install if present.

OLD_PATCH_MARKERS=(
    "$PROJECT_DIR/_bmad/wds/workflows/wds-4-ux-design/steps-w/step-02a-figma-mcp.md"
    "$PROJECT_DIR/design-process/C-Scenarios"
    "$PROJECT_DIR/.claude/skills/bmad-roadmap"
)

FOUND_OLD=""
for marker in "${OLD_PATCH_MARKERS[@]}"; do
    if [ -e "$marker" ]; then
        FOUND_OLD="$marker"
        break
    fi
done

FORCE_MIGRATE=""
for arg in "$@"; do
    if [ "$arg" = "--force-migrate" ]; then
        FORCE_MIGRATE=1
    fi
done

if [ -n "$FOUND_OLD" ] && [ -z "$FORCE_MIGRATE" ]; then
    echo "WARNING: This project appears to already have the old bmad-figma-patch (v1) installed."
    echo "         Marker: $FOUND_OLD"
    echo ""
    echo "The v3 patch is designed for NEW projects. Installing it over v1 is not recommended"
    echo "and will mix incompatible skills/agents/artifacts."
    echo ""
    echo "Recommended options:"
    echo "  1. Keep this project on the old patch — continue working as before"
    echo "  2. Use v3 on a NEW project instead"
    echo ""
    echo "If you understand the implications and want to migrate anyway, re-run with --force-migrate"
    echo "and see the README Migration Guide for manual steps you must take first."
    exit 1
fi

if [ -n "$FORCE_MIGRATE" ]; then
    echo "WARNING: --force-migrate specified. Proceeding with install over old patch."
    echo "         See README Migration Guide for manual steps you must complete."
    echo ""
fi

# ---------- Install new skills (symlink into .claude/skills/) ----------

mkdir -p "$CLAUDE_SKILLS_DIR"

echo "[1/7] Installing new skills..."

# bmad-roadmap-v2
ln -sf "$PATCH_DIR/skills/bmad-roadmap-v2" "$CLAUDE_SKILLS_DIR/bmad-roadmap-v2"
echo "      /bmad-roadmap-v2 (orchestrator)"

# bmad-claude-design-prep
ln -sf "$PATCH_DIR/skills/bmad-claude-design-prep" "$CLAUDE_SKILLS_DIR/bmad-claude-design-prep"
echo "      /bmad-claude-design-prep"

# bmad-sync-from-design
ln -sf "$PATCH_DIR/skills/bmad-sync-from-design" "$CLAUDE_SKILLS_DIR/bmad-sync-from-design"
echo "      /bmad-sync-from-design"

# bmad-create-epics-and-stories-v2
ln -sf "$PATCH_DIR/skills/bmad-create-epics-and-stories-v2" "$CLAUDE_SKILLS_DIR/bmad-create-epics-and-stories-v2"
echo "      /bmad-create-epics-and-stories-v2"

# ---------- Install carried-over skills ----------

echo "[2/7] Installing carried-over skills (ship, business-change, sync-artifacts)..."

ln -sf "$PATCH_DIR/skills/ship" "$CLAUDE_SKILLS_DIR/ship"
echo "      /ship"

ln -sf "$PATCH_DIR/skills/bmad-business-change" "$CLAUDE_SKILLS_DIR/bmad-business-change"
echo "      /bmad-business-change"

ln -sf "$PATCH_DIR/skills/bmad-sync-artifacts" "$CLAUDE_SKILLS_DIR/bmad-sync-artifacts"
echo "      /bmad-sync-artifacts"

# ---------- Deferred-work protocol overlays ----------
# Overlay base BMM skills with the deferred-work protocol.
# If BMAD updates these files upstream, re-run this installer to re-apply.

echo "[3/7] Overlaying deferred-work protocol into base BMM skills..."

CODE_REVIEW_STEPS="$PROJECT_DIR/.claude/skills/bmad-code-review/steps"
RETRO_DIR="$PROJECT_DIR/.claude/skills/bmad-retrospective"

if [ -d "$CODE_REVIEW_STEPS" ]; then
    cp "$PATCH_DIR/skills/bmad-code-review/steps/step-04-present.md" "$CODE_REVIEW_STEPS/"
    echo "      Overlaid bmad-code-review/steps/step-04-present.md"
else
    echo "      SKIP: $CODE_REVIEW_STEPS not found — bmad-code-review not installed by base BMAD"
fi

if [ -d "$RETRO_DIR" ]; then
    cp "$PATCH_DIR/skills/bmad-retrospective/workflow.md" "$RETRO_DIR/"
    echo "      Overlaid bmad-retrospective/workflow.md"
else
    echo "      SKIP: $RETRO_DIR not found — bmad-retrospective not installed by base BMAD"
fi

# ---------- Seed implementation-artifacts templates ----------

echo "[4/7] Seeding implementation-artifacts templates (only if absent)..."

ARTIFACTS_DIR="$PROJECT_DIR/_bmad-output/implementation-artifacts"
mkdir -p "$ARTIFACTS_DIR"

DEFERRED_WORK="$ARTIFACTS_DIR/deferred-work.md"
if [ ! -f "$DEFERRED_WORK" ]; then
    cp "$PATCH_DIR/templates/deferred-work.md" "$DEFERRED_WORK"
    echo "      Seeded deferred-work.md"
else
    echo "      deferred-work.md exists — leaving as-is"
fi

DESIGN_PROGRESS="$ARTIFACTS_DIR/design-progress.yaml"
if [ ! -f "$DESIGN_PROGRESS" ]; then
    cp "$PATCH_DIR/templates/design-progress.yaml" "$DESIGN_PROGRESS"
    echo "      Seeded design-progress.yaml"
else
    echo "      design-progress.yaml exists — leaving as-is"
fi

# Note: roadmap-progress.yaml is created by /bmad-roadmap-v2 on first activation
# (needs project name, which is unknown at install time). Not seeded here.

# ---------- Create handoffs directory ----------

echo "[5/7] Preparing design-process/claude-design-handoffs/ directory..."

HANDOFFS_DIR="$PROJECT_DIR/design-process/claude-design-handoffs"
mkdir -p "$HANDOFFS_DIR"
echo "      $HANDOFFS_DIR/ ready"

# ---------- Verification ----------

echo "[6/7] Verifying installation..."

ERRORS=0
check() {
    if [ ! -e "$1" ]; then
        echo "      MISSING: $1"
        ERRORS=$((ERRORS+1))
    fi
}

check "$CLAUDE_SKILLS_DIR/bmad-roadmap-v2/SKILL.md"
check "$CLAUDE_SKILLS_DIR/bmad-roadmap-v2/references/story-protocol.md"
check "$CLAUDE_SKILLS_DIR/bmad-roadmap-v2/references/phase-01-discover.md"
check "$CLAUDE_SKILLS_DIR/bmad-roadmap-v2/references/phase-04-claude-design-loop.md"
check "$CLAUDE_SKILLS_DIR/bmad-roadmap-v2/references/phase-06-build.md"
check "$CLAUDE_SKILLS_DIR/bmad-claude-design-prep/SKILL.md"
check "$CLAUDE_SKILLS_DIR/bmad-claude-design-prep/references/prompt-template.md"
check "$CLAUDE_SKILLS_DIR/bmad-sync-from-design/SKILL.md"
check "$CLAUDE_SKILLS_DIR/bmad-sync-from-design/references/comparison-logic.md"
check "$CLAUDE_SKILLS_DIR/bmad-create-epics-and-stories-v2/SKILL.md"
check "$CLAUDE_SKILLS_DIR/ship/SKILL.md"
check "$CLAUDE_SKILLS_DIR/bmad-business-change/SKILL.md"
check "$CLAUDE_SKILLS_DIR/bmad-sync-artifacts/SKILL.md"
check "$ARTIFACTS_DIR/design-progress.yaml"
check "$HANDOFFS_DIR"

# ---------- Done ----------

echo "[7/7] Summary..."
echo ""
if [ "$ERRORS" -eq 0 ]; then
    echo "✅ Done! All files installed successfully."
else
    echo "⚠️  $ERRORS check(s) failed. Review errors above."
fi

echo ""
echo "What's included:"
echo ""
echo "  New skills (v3):"
echo "    /bmad-roadmap-v2              — 9-phase orchestrator"
echo "    /bmad-claude-design-prep      — prep kit per epic for Claude Design session"
echo "    /bmad-sync-from-design        — deep sync from design handoff to artifacts"
echo "    /bmad-create-epics-and-stories-v2 — wraps BMM + adversarial/edge-case reviews"
echo ""
echo "  Carried over:"
echo "    /ship                         — PR workflow"
echo "    /bmad-business-change         — scope change orchestrator"
echo "    /bmad-sync-artifacts          — standalone artifact sync"
echo "    Deferred-work protocol overlays (bmad-code-review, bmad-retrospective)"
echo ""
echo "Prerequisites:"
echo "  - BMAD must be initialized (bmad setup)"
echo "  - Claude.ai Pro subscription or higher (for Claude Design)"
echo "  - Phase 4 is a MANUAL step in browser — no automation possible"
echo ""
echo "Start with: /bmad-roadmap-v2"
echo ""

if [ "$ERRORS" -ne 0 ]; then
    exit 1
fi
