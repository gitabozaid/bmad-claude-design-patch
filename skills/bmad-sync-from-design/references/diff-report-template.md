# Diff Report Template

Format for the sync report saved to `.bmad/sync-reports/<epic-slug>-<ISO-date>.md` and printed to the terminal (condensed version).

## Full report (file)

```markdown
# Sync Report — Epic: {{epic_slug}}

- **Date (UTC):** {{timestamp}}
- **Bundle URL:** {{bundle_url}}
- **Epic:** {{epic_name}}
- **Status:** {{synced | halted_on_conflict | no_changes}}

## Summary

- Screens in bundle: {{N}}
- Stories before sync: {{M}}
- Stories after sync: {{K}}
- Total changes applied: {{C}}

### Change counts

| Category | Count |
|----------|-------|
| Added screens | {{N}} |
| Removed screens | {{N}} |
| Renamed screens | {{N}} |
| Modified sections | {{N}} |
| Component changes | {{N}} |
| Copy changes | {{N}} |
| State coverage updates | {{N}} |
| PRD conflicts (halted) | {{N}} |

## Per-story changes

### Story {{id}} — {{title}}
{{#each changes}}
- **[{{type}}]** {{description}}
{{/each}}

...(repeat per affected story)

## PRD conflicts (if any)

{{#each conflicts}}
### {{screen}}
- **Design implies:** {{design_statement}}
- **PRD says:** {{prd_statement}} ({{fr_ref}})
- **User decision:** {{decision}}
- **Applied:** {{action_taken}}
{{/each}}

## Files modified

{{#each files}}
- `{{path}}` — {{change_summary}}
{{/each}}

## Design Reference blocks

All {{N}} stories in epic {{epic_slug}} now have an up-to-date Design Reference block pointing to bundle `{{bundle_url}}`, synced at `{{timestamp}}`.

## Next step

Run `/bmad-roadmap-v2` to continue Phase 4 (next epic) or advance to Phase 5 if this was the last epic.
```

## Condensed terminal output

Print this to the terminal after writing the full report:

```
╔══════════════════════════════════════════════════════════════════╗
║ SYNC COMPLETE — Epic: {{epic_slug}}                                ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                    ║
║ Screens designed: {{N}}                                            ║
║ Stories affected: {{N}}                                            ║
║ Changes applied: {{C}}                                             ║
║                                                                    ║
║ ✅ Added screens: {{N}}                                             ║
║ ✅ Modified stories: {{N}}                                          ║
║ ⚠️  PRD conflicts: {{N}} {{"(halted — see report)" if N > 0 }}      ║
║                                                                    ║
║ Full report: .bmad/sync-reports/{{slug}}-{{date}}.md              ║
║                                                                    ║
║ Status: {{epic_slug}} → design-complete                            ║
╚══════════════════════════════════════════════════════════════════╝
```

## No-changes variant

If sync detects no changes (idempotent re-run):

```
ℹ️  Nothing to sync — epic {{epic_slug}} is already up-to-date with bundle {{bundle_url}}.
    Last sync: {{last_sync_timestamp}}
```
