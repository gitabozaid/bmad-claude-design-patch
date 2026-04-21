# Attachment Checklist Template

Format for the checklist printed to the terminal.

## Template

```
╔══════════════════════════════════════════════════════════════════╗
║ CLAUDE DESIGN — ATTACHMENTS CHECKLIST                              ║
║ Epic: {{slug}} — {{name}}                                          ║
╠══════════════════════════════════════════════════════════════════╣
║ Upload these files to your Claude Design project:                 ║
║                                                                    ║
║  REQUIRED:                                                         ║
║  [ ] 1. {{prd-path}}                                               ║
║         (full PRD)                                                 ║
║                                                                    ║
║  [ ] 2. {{ux-doc-path}}                                            ║
║         (full UX design specification)                             ║
║                                                                    ║
║  [ ] 3. {{epic-path}}                                              ║
║         (this epic's definition)                                   ║
║                                                                    ║
║  [ ] 4. Stories for this epic ({{N}} files):                      ║
{{#each stories}}
║         - {{this.path}}                                            ║
{{/each}}
║                                                                    ║
{{app_shell_attachment_line}}
║                                                                    ║
║  OPTIONAL:                                                         ║
║  [ ] 5. {{design-system-path}}                                     ║
║         (skip if design system is attached org-level)              ║
║                                                                    ║
║  [ ] 6. Reference screenshots                                      ║
║         (inspiration, competitor UI, existing screens)             ║
║                                                                    ║
║  NOTE: these file paths are absolute. Use your OS file manager     ║
║        to locate them, or `open {{project-root}}` to open the      ║
║        project in Finder/Explorer.                                 ║
╚══════════════════════════════════════════════════════════════════╝
```

## Placeholder: `{{app_shell_attachment_line}}`

Conditional block inserted above the OPTIONAL section, based on `design-progress.yaml: app_shell.status`:

- **`status == "implemented"`** — render the REQUIRED codebase attachment block:

```
║  [ ] 5. [REQUIRED] Attach your codebase to the Claude Design project  ║
║         - Local: select the frontend/ directory                    ║
║           (exclude node_modules, .next, .git)                      ║
║         - Remote: link your GitHub repo                            ║
║         - Claude Design reads AppLayout + all components           ║
║         - Path to shell: {{layout_component_path}}                 ║
```

Re-number the OPTIONAL items that follow (5 → 6, 6 → 7).

- **`status == "none"`** — render a softer OPTIONAL version:

```
║  [ ] 5. [OPTIONAL] Attach your codebase to the Claude Design project ║
║         - Useful for design system component inference             ║
║         - No app shell to preserve (status: none)                  ║
```

- **`status == "pending"`** — do not render the checklist; halt with an error (Phase 4 pre-flight should have caught this).

## Rationale

- Absolute paths prevent confusion across different project roots
- Checkbox prefixes let users track progress as they upload
- Banner borders make the block visually distinct when copy-pasted
- Optional section clearly separated from required
- Codebase attachment is REQUIRED when app shell is implemented in code — ensures Claude Design respects the shell across all per-epic projects
