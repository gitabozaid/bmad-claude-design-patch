# Phase 8: Harden

**Goal:** Address non-functional requirements (NFR): performance, accessibility, security, observability. Add comprehensive E2E tests. Review existing tests for quality.

**Exit condition:** NFR assessment complete, E2E test suite covering critical journeys, test review report with no unresolved high-severity issues.

---

## Steps

### Step 1: NFR Assessment

**Run:** `/bmad-testarch-nfr` (BMM native).

The skill evaluates the deployed application against NFR categories:
- **Performance** — LCP, CLS, TTFB, API latency
- **Accessibility** — WCAG AA compliance (contrast, focus management, screen reader)
- **Security** — OWASP top 10, auth flows, data handling
- **Observability** — logging, metrics, alerting
- **Reliability** — error handling, retry logic, fallbacks

Produces an NFR assessment report. Fix any CRITICAL or HIGH issues as part of this phase.

### Step 2: Test Review

**Run:** `/bmad-testarch-test-review` (BMM native).

The skill reviews the test suite built during Phase 6:
- Coverage gaps (critical paths not tested)
- Test quality (flaky, brittle, over-mocked)
- Missing test types (unit without integration, integration without E2E)

Produces a test review report. Improve tests to address findings.

### Step 3: E2E Test Generation

**Run:** `/bmad-qa-generate-e2e-tests` (BMM native).

The skill generates E2E tests for the critical user journeys identified in Phase 2 (UX doc). Tests run against the deployed application (staging preferred).

Every journey should have at least one happy-path E2E test by end of this phase.

---

## Phase Completion

Before marking Phase 8 complete, verify:
- [ ] NFR report produced with no unresolved CRITICAL/HIGH issues
- [ ] Test review report produced with major gaps addressed
- [ ] E2E test suite covers every journey's happy path
- [ ] All E2E tests pass in CI

Update progress file:

```yaml
8-harden:
  status: complete
  completed: "{today}"
  nfr_findings: 0    # count of unresolved CRITICAL/HIGH
  e2e_tests_added: 12
```

Announce completion and proceed to Phase 9.
