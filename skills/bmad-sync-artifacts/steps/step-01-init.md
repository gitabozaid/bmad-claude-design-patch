# Step 1: Read the Diff and Load Context

## MANDATORY EXECUTION RULES (READ FIRST):

- 📖 Read the complete step file before taking any action
- ✅ Speak in `{communication_language}`
- 🚫 Do not classify or plan yet — this step is only about gathering information

## YOUR TASK:

Understand what changed in the code by reading the git diff, then load the BMAD artifacts that might be affected.

## SEQUENCE:

### 1. Run Git Diff

Run `git diff` (staged + unstaged) to see all code changes since the last commit. If there are recent commits that haven't been synced, also check `git log --oneline -5` and offer to include those.

Focus on files that affect the UI:
- `*.tsx`, `*.ts` — component and page files
- `*.css`, `*.scss` — styling changes
- `*.json` — mock data or config changes
- New files — could indicate a new screen

Ignore files that don't affect artifacts:
- `package.json`, `lock files`, config files
- Test files
- Build artifacts

### 2. Identify Affected Screens

From the diff, determine which screens were changed. Map changed files back to page specs:

```
Changed: src/app/(main)/home/page.tsx
  → Page spec: 01b.1-home-returning.md

Changed: src/components/WordCard.tsx
  → Used in: 01b.2-my-words.md, 01b.8-word-detail.md

New file: src/app/(main)/settings/page.tsx
  → No existing page spec (new screen)
```

If the mapping isn't obvious, ask the user which screen a file belongs to.

### 3. Load Affected Artifacts

For each affected screen, load:
- The page spec
- The relevant section from `api-contracts.md` (the screen's contract mapping)
- Any related stories (if they exist)

Also load:
- `00-ux-scenarios.md` (in case screen inventory changed)
- The design log (to understand current status)

### 4. Present Summary

Show what you found:

```
Git diff summary:
- Modified: 3 files (home/page.tsx, WordCard.tsx, globals.css)
- New: 1 file (settings/page.tsx)

Affected screens:
- Home (returning) — 01b.1
- My Words — 01b.2
- Word Detail — 01b.8
- Settings — NEW (no spec exists)

Artifacts loaded: [list]
```

### 5. Continue

Display: "[C] Continue to Classification | [M] Abort"

When C selected → load `./step-02-classify.md`
