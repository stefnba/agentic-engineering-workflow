---
status: todo
depends_on: [01]
---

# 03 — Implement skill: zero-arg dispatch

## Scope

`skills/implement/SKILL.md` loses its required arguments (BR-10). Zero-arg resolution per
ID-7. Mode from state: `fixes-pending` → the no-op of BR-11, reporting the state and pointing
at `/fix <PR>`, taking no action on the ticket loop; any other state (including no PR found)
→ the next unblocked ticket, unchanged. Malformed verdict block → the stop of BR-12. The
inferred mode is echoed before acting; explicit arguments override inference. The
`argument-hint` frontmatter reflects the new optional bundle/ticket form. Point at
`skills/review/references/protocol.md` for the state derivation and marker definitions
(BR-15) — implement never restates them. The existing ticket-mode steps (TDD loop, verify,
reconcile, close-out) are amended only where dispatch and close-out text changes — the
red-green process itself is untouched.

## Done when

- `grep -c "fixes-pending" skills/implement/SKILL.md` ≥ 1 and
  `grep -l "references/protocol.md" skills/implement/SKILL.md` lists the file
- The implement half of AC-6 passes.

## Not in this ticket

The fix skill itself (→ 04); the review side (→ 02); the workflow doc (→ 05). No change to
the seam rules, drift rules, or the red-green loop's steps.
