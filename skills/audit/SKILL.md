---
name: audit
description: Sweep the repo for drift in a background fork — stale docs, broken references, glossary violations, contradicted decisions — into a docs/research/audit-*.md file plus backlog lines. Invoke bare for a full sweep or with an area to focus it; the result arrives when the fork completes.
argument-hint: "[area]"
disable-model-invocation: true
context: fork
agent: researcher
disallowed-tools: AskUserQuestion
hooks:
  PreToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/skills/research/scripts/write-boundary.sh"
---

# Audit

Sweep the repo for drift — the whole repo, or only this area when one is named:
**$ARGUMENTS**

Hunt where documents and reality diverge:

- Colocated READMEs describing code that has since moved, been renamed, or changed behavior
  — the README is supposed to win, which makes a stale one actively misleading.
- References that no longer resolve: paths in docs, cross-links, names of things deleted.
- `GLOSSARY.md` violations — avoided synonyms in docs or identifiers, and terms the repo
  uses that no glossary entry backs (where a glossary with entries exists).
- Code or docs contradicting a `docs/decisions/` record without a superseding record.
- `work/` drift — backlog lines shadowing live work items, tickets referencing things that
  moved, bundles whose spec no longer matches the code.

Verify each hit before it counts: open the file, grep for the name — a drift claim you
didn't check is itself drift. Write the doc (named `audit-*`) and the backlog lines as your
agent instructions define them, and deliver the doc's path plus the added lines as your
final message.
