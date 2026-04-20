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

## Rationale

- Absolute paths prevent confusion across different project roots
- Checkbox prefixes let users track progress as they upload
- Banner borders make the block visually distinct when copy-pasted
- Optional section clearly separated from required
