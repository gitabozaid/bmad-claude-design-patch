# Phase 2: UX Design

**Goal:** Produce the single consolidated UX design specification that drives all later phases. Replaces the multi-phase WDS approach from the v1 roadmap (wds-0, wds-2, wds-3, wds-7).

**Exit condition:** `_bmad-output/planning-artifacts/ux-design-specification.md` exists with all 14 sections populated (Discovery → Core Experience → Design System → User Journeys → Component Strategy → UX Patterns → Responsive & a11y).

---

## Process

**Run:** `/bmad-create-ux-design` (BMM native — installed by BMAD, not by this patch).

The skill walks through a 14-step collaborative workflow, reading:
- `prd.md` from Phase 1
- `architecture.md` from Phase 1
- `product-brief.md` if present
- Existing project documentation in `docs/`

It produces ONE consolidated document `ux-design-specification.md` covering:

| Section | Content |
|---------|---------|
| Init + Discovery | Project context, target users |
| Core Experience | Platform decisions, effortless interaction |
| Emotional Response | User feelings, emotional goals |
| Inspiration | Analysis of inspiring products |
| Design System | Tokens (color, typography, spacing) + components |
| Defining Experience | The ONE core interaction |
| Visual Foundation | Color + typography decisions |
| Design Directions | Visual exploration |
| **User Journeys** | Detailed flows with Mermaid diagrams (these become epics in Phase 3) |
| Component Strategy | Custom components + library strategy |
| UX Patterns | Consistency patterns (buttons, forms, nav, feedback) |
| Responsive & a11y | Cross-device + accessibility strategy |

**Important:** The User Journeys section is the list that will become the Epic list in Phase 3. Review it carefully with the user — each journey corresponds to one future epic and one Claude Design project.

---

## Phase Completion

Before marking Phase 2 complete, verify:
- [ ] `ux-design-specification.md` exists at `_bmad-output/planning-artifacts/`
- [ ] The document has the User Journeys section populated
- [ ] Design system tokens (color, typography, spacing) are specified
- [ ] The user has reviewed and approved the journey list (confirmed before moving to Phase 3)

Update progress file:

```yaml
2-ux-design:
  status: complete
  completed: "{today}"
  journeys_count: 6     # informational — used by Phase 4 to track epic count
```

Announce completion and proceed to Phase 3.
