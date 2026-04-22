#!/bin/bash
# BMAD Claude Design Patch (v3) — installer
#
# Modes:
#   (default)    Fresh install — copies files into the project (self-contained).
#                Records the patch commit in .bmad/.patch-version.
#   --upgrade    Update existing install to the latest patch commit.
#                Backs up any locally-modified files before overwriting.
#   --status     Check current patch version vs remote. Read-only.
#   --symlink    Dev mode: symlink skills instead of copying (for iterating
#                on the patch across multiple projects). Not for production.
#
# For new projects using BMM-native + Claude Design + full-stack stories.
# Old projects on bmad-figma-patch must migrate explicitly via --force-migrate.

set -e

PATCH_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(pwd)"
CLAUDE_SKILLS_DIR="$PROJECT_DIR/.claude/skills"
PATCH_VERSION_FILE="$PROJECT_DIR/.bmad/.patch-version"
BACKUP_ROOT="$PROJECT_DIR/.bmad/backups"

# Parse args
MODE="fresh"
FORCE_MIGRATE=""
for arg in "$@"; do
    case "$arg" in
        --upgrade)      MODE="upgrade" ;;
        --status)       MODE="status" ;;
        --symlink)      MODE="symlink" ;;
        --force-migrate) FORCE_MIGRATE=1 ;;
    esac
done

# ─────────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────────

patch_current_commit() {
    git -C "$PATCH_DIR" rev-parse --short HEAD 2>/dev/null
}

patch_current_message() {
    git -C "$PATCH_DIR" log -1 --format=%s 2>/dev/null
}

patch_remote_commit() {
    git -C "$PATCH_DIR" fetch origin main 2>/dev/null || true
    git -C "$PATCH_DIR" rev-parse --short origin/main 2>/dev/null
}

read_installed_commit() {
    [ -f "$PATCH_VERSION_FILE" ] || return 1
    grep -E "^commit:" "$PATCH_VERSION_FILE" | awk '{print $2}'
}

write_patch_version() {
    local commit="$1"
    local msg="$2"
    local count="$3"
    mkdir -p "$(dirname "$PATCH_VERSION_FILE")"
    local installed_at
    installed_at="$(date -u +%FT%TZ)"
    cat > "$PATCH_VERSION_FILE" <<EOF
# Auto-maintained by bmad-claude-design-patch install.sh
# Shows which commit of the patch is currently installed in this project.
# Do NOT edit manually. Use 'install.sh --upgrade' to update, or
# 'install.sh --status' to check drift from the remote.

patch: bmad-claude-design-patch
commit: $commit
commit_message: "$msg"
installed_at: $installed_at
patch_repo: git@github.com:gitabozaid/bmad-claude-design-patch.git
files_installed: $count
mode: $MODE
EOF
}

# Backs up a file if it differs from source, then copies source over dst.
# Usage: install_file <src> <dst>
BACKUP_TIMESTAMP=""
BACKUPS_MADE=0
install_file() {
    local src="$1"
    local dst="$2"
    if [ -f "$dst" ] && ! cmp -s "$src" "$dst"; then
        # File exists and differs — back it up
        if [ -z "$BACKUP_TIMESTAMP" ]; then
            BACKUP_TIMESTAMP="$(date -u +%FT%H%M%SZ)"
        fi
        local backup_dir="$BACKUP_ROOT/$BACKUP_TIMESTAMP"
        local rel="${dst#$PROJECT_DIR/}"
        mkdir -p "$backup_dir/$(dirname "$rel")"
        cp "$dst" "$backup_dir/$rel"
        BACKUPS_MADE=$((BACKUPS_MADE + 1))
    fi
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
}

# Copies all files from a source directory to a destination directory,
# backing up any locally-modified file before overwriting.
install_directory() {
    local src_dir="$1"
    local dst_dir="$2"
    mkdir -p "$dst_dir"
    # Remove dst symlink if present (migration from symlink → copy mode)
    if [ -L "$dst_dir" ]; then
        rm "$dst_dir"
        mkdir -p "$dst_dir"
    fi
    (cd "$src_dir" && find . -type f ! -path '*/.DS_Store') | while read -r rel_path; do
        install_file "$src_dir/$rel_path" "$dst_dir/$rel_path"
    done
}

# ─────────────────────────────────────────────────────────────────
# Status mode — read-only
# ─────────────────────────────────────────────────────────────────

if [ "$MODE" = "status" ]; then
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║ BMAD Claude Design Patch (v3) — Status                        ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo "Project: $PROJECT_DIR"
    echo ""

    if [ ! -f "$PATCH_VERSION_FILE" ]; then
        echo "❌ Patch not installed (no .bmad/.patch-version found)."
        echo "   Run: bash $PATCH_DIR/install.sh"
        exit 1
    fi

    INSTALLED="$(read_installed_commit)"
    REMOTE="$(patch_remote_commit)"
    CURRENT="$(patch_current_commit)"

    echo "Installed commit: $INSTALLED"
    echo "Local patch HEAD: $CURRENT"
    echo "Remote main:      $REMOTE"
    echo ""

    if [ "$INSTALLED" = "$CURRENT" ]; then
        if [ "$CURRENT" = "$REMOTE" ]; then
            echo "✅ Up-to-date with remote."
        else
            BEHIND=$(git -C "$PATCH_DIR" rev-list --count "${CURRENT}..${REMOTE}" 2>/dev/null || echo "?")
            echo "⚠️  Local patch is $BEHIND commit(s) behind remote."
            echo "   Pull the patch repo, then run --upgrade."
        fi
    else
        BEHIND=$(git -C "$PATCH_DIR" rev-list --count "${INSTALLED}..${CURRENT}" 2>/dev/null || echo "?")
        echo "⚠️  Installed is $BEHIND commit(s) behind local patch HEAD."
        echo "   Run: bash $PATCH_DIR/install.sh --upgrade"
    fi
    exit 0
fi

# ─────────────────────────────────────────────────────────────────
# Common: prerequisite checks (fresh + upgrade + symlink)
# ─────────────────────────────────────────────────────────────────

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║ BMAD Claude Design Patch (v3) — Installer                     ║"
echo "║ Mode: $MODE"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Project: $PROJECT_DIR"
echo "Patch:   $PATCH_DIR"
echo ""

if [ ! -d "$PROJECT_DIR/_bmad/bmm" ]; then
    echo "ERROR: No _bmad/bmm/ found at $PROJECT_DIR"
    echo "BMAD must be initialized first. Run 'bmad setup' before installing."
    exit 1
fi

# Old v1-patch detection — only on fresh install
if [ "$MODE" = "fresh" ]; then
    OLD_PATCH_MARKERS=(
        "$PROJECT_DIR/_bmad/wds/workflows/wds-4-ux-design/steps-w/step-02a-figma-mcp.md"
        "$PROJECT_DIR/design-process/C-Scenarios"
        "$PROJECT_DIR/.claude/skills/bmad-roadmap"
    )
    FOUND_OLD=""
    for marker in "${OLD_PATCH_MARKERS[@]}"; do
        [ -e "$marker" ] && { FOUND_OLD="$marker"; break; }
    done

    if [ -n "$FOUND_OLD" ] && [ -z "$FORCE_MIGRATE" ]; then
        echo "WARNING: Old bmad-figma-patch (v1) detected at:"
        echo "  $FOUND_OLD"
        echo ""
        echo "Installing v3 over v1 is not supported without explicit migration."
        echo "Options:"
        echo "  1. Keep on v1 (recommended for existing projects)"
        echo "  2. Re-run with --force-migrate after reading the README Migration Guide"
        exit 1
    fi
fi

# Fresh mode: block re-install if already installed
if [ "$MODE" = "fresh" ] && [ -f "$PATCH_VERSION_FILE" ]; then
    INSTALLED="$(read_installed_commit)"
    echo "ERROR: Patch already installed (commit $INSTALLED)."
    echo "To update, run: bash $PATCH_DIR/install.sh --upgrade"
    exit 1
fi

# ─────────────────────────────────────────────────────────────────
# Install logic
# ─────────────────────────────────────────────────────────────────

# List of skill directories installed by this patch
NEW_SKILLS=(
    "bmad-roadmap-v2"
    "bmad-claude-design-prep"
    "bmad-sync-from-design"
    "bmad-create-epics-and-stories-v2"
    "ship"
    "bmad-business-change"
    "bmad-sync-artifacts"
)

# Counters
FILES_INSTALLED=0

mkdir -p "$CLAUDE_SKILLS_DIR"

# Detect symlink migration (upgrade mode picks this up)
SYMLINK_MIGRATION=0
for skill in "${NEW_SKILLS[@]}"; do
    if [ -L "$CLAUDE_SKILLS_DIR/$skill" ]; then
        SYMLINK_MIGRATION=1
        break
    fi
done

if [ "$MODE" = "upgrade" ] && [ $SYMLINK_MIGRATION -eq 1 ]; then
    echo "Detected symlink install from earlier version — migrating to copy mode..."
    echo ""
fi

echo "[1/6] Installing skills..."

for skill in "${NEW_SKILLS[@]}"; do
    SRC="$PATCH_DIR/skills/$skill"
    DST="$CLAUDE_SKILLS_DIR/$skill"

    if [ ! -d "$SRC" ]; then
        echo "      SKIP: $SRC not found in patch repo"
        continue
    fi

    if [ "$MODE" = "symlink" ]; then
        # Dev mode: symlink
        [ -e "$DST" ] && rm -rf "$DST"
        ln -sf "$SRC" "$DST"
        echo "      /$skill (symlink)"
    else
        # Fresh or upgrade: copy with backup-on-modified
        install_directory "$SRC" "$DST"
        FILE_COUNT=$(find "$SRC" -type f ! -name '.DS_Store' | wc -l | tr -d ' ')
        FILES_INSTALLED=$((FILES_INSTALLED + FILE_COUNT))
        echo "      /$skill (copied, $FILE_COUNT files)"
    fi
done

# Deferred-work overlays (always copied — they overlay base BMM skills)
echo ""
echo "[2/6] Overlaying deferred-work protocol into base BMM skills..."

CODE_REVIEW_STEPS="$PROJECT_DIR/.claude/skills/bmad-code-review/steps"
RETRO_DIR="$PROJECT_DIR/.claude/skills/bmad-retrospective"

if [ -d "$CODE_REVIEW_STEPS" ]; then
    install_file "$PATCH_DIR/skills/bmad-code-review/steps/step-04-present.md" "$CODE_REVIEW_STEPS/step-04-present.md"
    FILES_INSTALLED=$((FILES_INSTALLED + 1))
    echo "      Overlaid bmad-code-review/steps/step-04-present.md"
else
    echo "      SKIP: bmad-code-review not installed by base BMAD"
fi

if [ -d "$RETRO_DIR" ]; then
    install_file "$PATCH_DIR/skills/bmad-retrospective/workflow.md" "$RETRO_DIR/workflow.md"
    FILES_INSTALLED=$((FILES_INSTALLED + 1))
    echo "      Overlaid bmad-retrospective/workflow.md"
else
    echo "      SKIP: bmad-retrospective not installed by base BMAD"
fi

# Templates — copy-if-absent (never overwrite on upgrade, they hold project data)
echo ""
echo "[3/6] Seeding implementation-artifacts templates (only if absent)..."

ARTIFACTS_DIR="$PROJECT_DIR/_bmad-output/implementation-artifacts"
mkdir -p "$ARTIFACTS_DIR"

seed_if_absent() {
    local src="$1"
    local dst="$2"
    local name="$3"
    if [ ! -f "$dst" ]; then
        cp "$src" "$dst"
        echo "      Seeded $name"
    else
        echo "      $name exists — leaving as-is (project data preserved)"
    fi
}

seed_if_absent "$PATCH_DIR/templates/deferred-work.md" "$ARTIFACTS_DIR/deferred-work.md" "deferred-work.md"
seed_if_absent "$PATCH_DIR/templates/design-progress.yaml" "$ARTIFACTS_DIR/design-progress.yaml" "design-progress.yaml"

# Ensure design-process/claude-design-handoffs/ exists
HANDOFFS_DIR="$PROJECT_DIR/design-process/claude-design-handoffs"
mkdir -p "$HANDOFFS_DIR"

echo ""
echo "[4/6] Preparing design-process/claude-design-handoffs/ directory..."
echo "      $HANDOFFS_DIR/ ready"

# Write patch-version file (fresh + upgrade; symlink mode also writes it for consistency)
echo ""
echo "[5/6] Recording patch version..."

COMMIT="$(patch_current_commit)"
MESSAGE="$(patch_current_message)"
write_patch_version "$COMMIT" "$MESSAGE" "$FILES_INSTALLED"
echo "      .bmad/.patch-version → commit $COMMIT"

# Verification
echo ""
echo "[6/6] Verifying installation..."

ERRORS=0
check() {
    if [ ! -e "$1" ]; then
        echo "      MISSING: $1"
        ERRORS=$((ERRORS+1))
    fi
}

check "$CLAUDE_SKILLS_DIR/bmad-roadmap-v2/SKILL.md"
check "$CLAUDE_SKILLS_DIR/bmad-roadmap-v2/references/story-protocol.md"
check "$CLAUDE_SKILLS_DIR/bmad-claude-design-prep/SKILL.md"
check "$CLAUDE_SKILLS_DIR/bmad-sync-from-design/SKILL.md"
check "$CLAUDE_SKILLS_DIR/bmad-create-epics-and-stories-v2/SKILL.md"
check "$CLAUDE_SKILLS_DIR/ship/SKILL.md"
check "$CLAUDE_SKILLS_DIR/bmad-business-change/SKILL.md"
check "$CLAUDE_SKILLS_DIR/bmad-sync-artifacts/SKILL.md"
check "$ARTIFACTS_DIR/design-progress.yaml"
check "$HANDOFFS_DIR"
check "$PATCH_VERSION_FILE"

# Summary
echo ""
if [ "$ERRORS" -eq 0 ]; then
    echo "✅ Done."
    if [ $BACKUPS_MADE -gt 0 ]; then
        echo "   $BACKUPS_MADE file(s) had local modifications and were backed up to:"
        echo "   .bmad/backups/$BACKUP_TIMESTAMP/"
    fi
else
    echo "⚠️  $ERRORS check(s) failed. Review errors above."
fi

echo ""
echo "Mode:    $MODE"
echo "Commit:  $COMMIT"
echo "Start:   /bmad-roadmap-v2"
echo ""

if [ "$ERRORS" -ne 0 ]; then
    exit 1
fi
