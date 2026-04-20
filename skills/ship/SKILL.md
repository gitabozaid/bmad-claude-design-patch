---
name: ship
description: 'Ship current branch changes via PR workflow: commit, push, create PR, wait for CI, merge, return to main. Use when the user says "ship it" or "ship".'
---

# Ship Workflow

You are shipping code changes through a PR workflow. Follow these steps exactly. Do NOT stop between steps unless there is a genuine blocker.

## Pre-flight Checks

1. Run `git status` to confirm there are changes to ship.
2. If no changes exist, inform the user and stop.
3. Run `git branch --show-current` to check the current branch.
4. If on `main`, stop and tell the user: "You need to be on a feature branch. Create one first with `git checkout -b feat/your-feature-name`."

## Step 1: Stage and Commit

1. Review all changed files with `git diff` and `git diff --cached`.
2. Stage the relevant files (prefer specific files over `git add .`).
3. Write a commit message following the project convention:
   - Format: `feat(scope): description` or `fix(scope): description`
   - End with `Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>`
4. If there are already commits on the branch and nothing new to commit, skip to Step 2.

## Step 2: Push

1. Push the branch to origin: `git push -u origin HEAD`
2. If push fails, diagnose and fix (do NOT force push).

## Step 3: Create PR

1. Check if a PR already exists for this branch: `gh pr view --json state 2>/dev/null`
2. If no PR exists, create one:
   ```
   gh pr create --title "<short title>" --body "$(cat <<'EOF'
   ## Summary
   <bullet points of what changed>

   ## Test plan
   - [ ] CI passes (typecheck + lint + phpstan)
   - [ ] Manual verification of changes

   Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
   EOF
   )"
   ```
3. Print the PR URL.

## Step 4: Wait for CI

1. Wait for CI checks to complete: `gh pr checks --watch`
2. If CI fails:
   a. Read the failure logs: `gh run view <run-id> --log-failed`
   b. Fix the issues locally.
   c. Commit the fix (new commit, do NOT amend).
   d. Push again.
   e. Repeat until CI passes.
3. Maximum 3 fix attempts. After that, stop and ask the user for help.

## Step 5: Merge

1. Merge the PR: `gh pr merge --squash --delete-branch`
2. If merge fails, diagnose and inform the user.

## Step 6: Return to main

1. `git checkout main`
2. `git pull origin main`
3. Confirm success and print a summary of what was shipped.
