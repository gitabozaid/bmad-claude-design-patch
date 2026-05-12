# Attachment Checklist Template

Format for the chat-level checklist printed to the terminal. The user pastes story files into a new chat inside the existing product project; project-level docs (PRD, UX, Architecture, Epics) are already attached at the project level — they are listed in the "Already attached" section for reference only.

## Template

```
╔══════════════════════════════════════════════════════════════════╗
║ CLAUDE DESIGN — CHAT ATTACHMENTS CHECKLIST                         ║
║ Epic: {{slug}} — {{name}}                                          ║
║ Inside product project: {{product_project_url}}                    ║
╠══════════════════════════════════════════════════════════════════╣
║ Already attached at the project level (do NOT re-upload):          ║
║   ✓ prd.md                                                         ║
║   ✓ ux-design-specification.md                                     ║
║   ✓ architecture.md                                                ║
║   ✓ epics.md                                                       ║
║                                                                    ║
║ Upload these into the NEW chat (chat-level, latest versions):      ║
║                                                                    ║
║  [ ] Stories for this epic ({{N}} files):                          ║
{{#each stories}}
║         - {{this.path}}                                            ║
{{/each}}
║                                                                    ║
║ OPTIONAL:                                                          ║
║  [ ] Reference screenshots (inspiration, competitor screens)       ║
║  [ ] Updated design-system docs IF the design system changed       ║
║      since this product project was created                        ║
║                                                                    ║
║ NOTES:                                                             ║
║  • Stories must be uploaded fresh in every new chat — they may     ║
║    have been updated by a prior /bmad-sync-from-design run, and    ║
║    the version uploaded to an older chat is now stale.             ║
║  • There is no "app shell" attachment — Claude Design carries      ║
║    shell consistency across chats inside the project automatically.║
║                                                                    ║
║ Paths are absolute. Open the project root in Finder/Explorer:      ║
║   open {{project_root}}                                            ║
╚══════════════════════════════════════════════════════════════════╝
```

## Rationale

- The product-level docs are listed but checked-✓ — confirms they're already attached, prevents re-upload churn
- Stories are checkbox-able for the user to track progress as they drag-drop into the chat
- Banner borders make the block visually distinct when copy-pasted
- Absolute paths prevent confusion across project roots
- The "stale story version" warning is critical: sync-from-design can rewrite story files, and an older chat's attached version becomes outdated. Always re-upload from disk for a new chat.
