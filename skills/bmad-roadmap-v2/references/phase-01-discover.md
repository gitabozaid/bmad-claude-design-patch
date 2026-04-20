# Phase 1: Discover

**Goal:** Produce the foundational artifacts that drive every later phase — Product Brief, PRD, and Architecture. Same as the v1 roadmap Phase 1.

**Exit condition:** `prd.md` and `architecture.md` exist under `_bmad-output/planning-artifacts/`, both validated.

---

## Steps

Execute these in order. **After each step completes, update the progress file immediately.**

### Step 1: Domain Research (optional)

**Run:** `/bmad-domain-research`

Skip if the domain is well-known and the user doesn't need research.

### Step 2: Market Research (optional)

**Run:** `/bmad-market-research`

Skip for internal tools or projects that aren't products.

### Step 3: Brainstorming (optional)

**Run:** `/bmad-brainstorming`

Skip if the user has a clear vision.

### Step 4: Product Brief (required)

**Run:** `/bmad-product-brief`

Produces `_bmad-output/planning-artifacts/product-brief.md`.

### Step 5: Create PRD (required)

**Run:** `/bmad-create-prd`

Produces `_bmad-output/planning-artifacts/prd.md`.

### Step 6: Validate PRD (required)

**Run:** `/bmad-validate-prd`

Fix any gaps flagged before proceeding.

### Step 7: Create Architecture (required)

**Run:** `/bmad-create-architecture`

Produces `_bmad-output/planning-artifacts/architecture.md`.

---

## Phase Completion

Before marking Phase 1 complete, verify:
- [ ] `_bmad-output/planning-artifacts/prd.md` exists
- [ ] `_bmad-output/planning-artifacts/architecture.md` exists
- [ ] PRD validation passed (no open CRITICAL gaps)

Update progress file:

```yaml
1-discover:
  status: complete
  completed: "{today}"
  skipped_steps: [domain_research]  # example — list any optional steps skipped with their reasons
```

Announce completion and proceed to Phase 2.
