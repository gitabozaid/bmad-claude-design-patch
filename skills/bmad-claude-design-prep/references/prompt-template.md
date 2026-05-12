# Prompt Template

This is the template the skill fills in and prints to the terminal for the user to paste into the new Claude Design chat (inside the existing product project).

## Placeholders

- `{{epic_name}}` — e.g., "Onboarding"
- `{{epic_slug}}` — e.g., "epic-2-foundation-auth-onboarding"
- `{{epic_description}}` — one-line summary from the epic file
- `{{product_type}}` — e.g., "language learning PWA", "B2B SaaS dashboard"
- `{{platform}}` — from UX doc: PWA, Desktop, Responsive
- `{{viewports}}` — list of supported viewports (mobile breakpoint, tablet, desktop)
- `{{languages}}` — AR + EN / EN only / etc.
- `{{direction}}` — LTR / RTL / both
- `{{role_context}}` — Public / Authenticated / Admin-only / Mixed
- `{{screens_list}}` — generated from story files
- `{{project_level_docs_list}}` — names of the stable docs at project level (PRD, UX, Architecture, Epics), listed so Claude Design knows to consult them

## Template

```
Goal: Design all screens for the "{{epic_name}}" epic ({{epic_slug}}).

Context:
{{epic_description}}

The following project-level docs are already attached to this Claude Design
project — read them as needed:
{{project_level_docs_list}}

This new chat also has the following epic-specific stories attached:
{{stories_list_filenames}}

Screens to design (in order of user flow):
{{screens_list}}

Product type: {{product_type}}
Platform: {{platform}}
Viewports to support: {{viewports}} — every screen must look intentional at every
listed viewport. The product is fully responsive; no surface is single-platform.
Languages: {{languages}} ({{direction}} support required)
Role/visibility: {{role_context}}

Design system:
The org-level design system is already attached. Use its tokens, typography,
spacing, radius, components verbatim. Do NOT introduce new tokens; if a value is
missing, reuse the closest existing one or flag it.

App shell / chrome consistency:
Claude Design carries shell consistency across chats inside this project
automatically. Use the same header, sidebar, and navigation patterns that
previous chats in this project established. If this is the first chat in the
project, establish the shell here and document it inline so future chats can
inherit.

Requirements for every screen:
- Use the existing component library from the design system — match its spacing, typography, color tokens exactly
- Show all interactive states where applicable: default, loading, empty, error, hover, disabled, focused
- Show RTL rendering for any screen with Arabic content (if applicable)
- Show every supported viewport for each screen (do not just shrink the desktop layout)
- Design transitions between screens to be clear and purposeful
- Flag any screen that needs a modal or overlay; design it within this project

Aesthetic guidance (this is critical — avoid the generic "AI slop" output):

**Typography:** Avoid Inter, Roboto, Open Sans, Lato, system defaults. Choose something distinctive. Good options depending on the product tone:
- Code/technical: JetBrains Mono, Space Grotesk, IBM Plex
- Editorial: Playfair Display, Crimson Pro, Fraunces
- Startup/modern: Clash Display, Satoshi, Cabinet Grotesk
- Distinctive: Bricolage Grotesque, Newsreader

**Color & theme:** Commit to a cohesive palette. Dominant colors with sharp accents outperform timid evenly-distributed palettes. Avoid:
- Purple gradients on white (extremely cliche)
- Generic "SaaS blue" only
- Every button the same primary color

**Motion:** One well-orchestrated page load with staggered reveals beats scattered micro-interactions everywhere. Use animations for high-impact moments (CTA, state transitions, success confirmations).

**Backgrounds:** Create atmosphere with layered gradients, geometric patterns, or contextual textures — not plain solid colors.

**Layout:** Surprise me. Break predictable patterns. Think about what makes this product's context specific — don't default to a generic dashboard/landing page template.

Avoid:
- Generic AI-generated aesthetics (predictable layouts, cookie-cutter patterns)
- Overused fonts (Inter, Roboto, Arial, system fonts)
- Clichéd color schemes (purple gradients on white, "SaaS blue")
- Decorative elements that don't serve the interaction

Deliverables:
- All screens listed above, interactively connected
- Edge states as noted
- A modal/overlay design for any screen that needs one
- Each screen rendered at every supported viewport (not just the largest)

Iteration strategy: Start with core layouts. I'll iterate on specifics via inline comments. Don't try to nail everything on the first pass — focus on the overall direction and composition first.
```

## Usage in the skill

The skill:
1. Loads the template content
2. Replaces placeholders with values from loaded inputs
3. Prints the result inside banner borders for clean copy-paste
