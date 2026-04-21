# Prompt Template

This is the template the skill fills in and prints to the terminal for the user to paste into Claude Design chat.

## Placeholders

- `{{epic_name}}` — e.g., "Onboarding"
- `{{epic_description}}` — one-line summary from the epic file
- `{{product_type}}` — e.g., "language learning PWA", "B2B SaaS dashboard"
- `{{platform}}` — from UX doc: Mobile-first PWA / Desktop / Responsive
- `{{languages}}` — AR + EN / EN only / etc.
- `{{direction}}` — LTR / RTL / both
- `{{role_context}}` — Public / Authenticated / Admin-only / Mixed
- `{{screens_list}}` — generated from story files
- `{{design_system_note}}` — if design system is attached at org-level, mention it; else note it's in the upload
- `{{app_shell_constraint}}` — conditional block, populated based on `design-progress.yaml: app_shell.status`:
  - if status is `implemented` → print the "App shell constraint" block (see below)
  - if status is `none` → leave empty string (no shell constraint applies)
  - if status is `pending` → this is a bug; Phase 4 should not start without app_shell resolved. Halt.

### App shell constraint block (inserted when `app_shell.status == implemented`)

```
App shell constraint:
The app shell (AppLayout, Header, Footer, Navigation) already exists in the
attached codebase at {{layout_component_path}}. DO NOT redesign it. All screens
must use the existing AppLayout as-is. Focus design effort on the MAIN CONTENT
AREA of each screen only. The header, footer, sidebar, and navigation are
fixed and must NOT be reimagined.
```

## Template

```
Goal: Design all screens for the "{{epic_name}}" epic.

Context:
{{epic_description}}

Screens to design (in order of user flow):
{{screens_list}}

Product type: {{product_type}}
Platform: {{platform}}
Languages: {{languages}} ({{direction}} support required)
Role/visibility: {{role_context}}

Design system:
{{design_system_note}}

{{app_shell_constraint}}

Requirements for every screen:
- Use the existing component library from the design system — match its spacing, typography, color tokens exactly
- Show all interactive states where applicable: default, loading, empty, error, hover, disabled, focused
- Show RTL rendering for any screen with Arabic content (if applicable)
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

Iteration strategy: Start with core layouts. I'll iterate on specifics via inline comments. Don't try to nail everything on the first pass — focus on the overall direction and composition first.
```

## Usage in the skill

The skill:
1. Loads the template content
2. Replaces placeholders with values from loaded inputs
3. Prints the result inside banner borders for clean copy-paste
