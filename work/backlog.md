# Backlog

Work on the reference material itself. Unsorted collection dump — order carries no meaning.

Tags:

- `[idea]` new idea worth exploring
- `[drift]` noticed inconsistency between docs or code
- `[follow-up]` concrete agreed work

## Items

- [follow-up] Rename the Ship stage to Land — "ship" implies production release, which the workflow
  explicitly doesn't own (the integration target may be `dev`, promotion to the protected branch is
  a separate release process); "lands on the integration target" is already the docs' own phrasing.
  Rename sweeps workflow.md, walkthrough.md, artifacts.md ("Shipped" lifetime state → "Landed"),
  bundle.md, AGENTS.md, and the planned `/ship` skill name (→ `/land`).
- [drift] docs/agents/git.md's Worktrees section references an "optional Release promotion section
  below" that doesn't exist in the file — dangling internal reference, resolve or remove.
- [drift] workflow.md and artifacts.md link _to_ walkthrough.md in three places added this session
  (Coordination's session/tab model, Discover's narrowing mechanics, Discovery evidence's
  scan-triage mechanics) — but walkthrough.md is the practical, derived "how you run this" guide,
  not an owning doc other docs should depend on, per AGENTS.md's "link to the owning doc" rule.
  Either move the referenced content to a proper owning doc and have both sides link to it, or
  confirm walkthrough.md legitimately owns these specific facts and the direction is fine as-is.
- [follow-up] walkthrough.md already names specific skills (`/pick`, `/scan-codebase`,
  `/interview-me`, `/shape`, `/complete-ticket`, `/ship`, `bundle-git`) as if they exist. Each still
  needs to actually be defined as its own modular skill file — including internal, non-user-facing
  ones (`bundle-git`, claim/dispatch mechanics) that no human ever types directly, not just the
  slash commands a human invokes.
- [follow-up] Add reference skill `/codebase-design` — supplies shared vocabulary (module, interface,
  depth, seam, adapter, leverage, locality) for other skills to borrow; not a session driver itself.
- [follow-up] templates/ticket.md's Outcome section is thin for ticket-only bundles (no spec): it
  leans on one free-text paragraph for intent that spec-backed tickets get real structure for
  (BR/BC/INV/AC with IDs). Strengthen the ticket-only-bundle guidance to prompt for the same
  categories — behavior, constraints, non-goals, acceptance — without requiring the ID machinery a
  single-ticket bundle has nothing else to cross-reference.
- [follow-up] Finding protocol refinements (from independent judge ruling — keep two severities,
  harden the record):
  - Mandatory violated-referent field per finding (spec BR/AC/INV, ticket done-when, decision
    record, CI gate, or concrete failure mechanism) — nitpicks inadmissible by construction.
  - Binary confidence flag (`verified | suspected`); fix mode verifies suspected findings before
    fixing or rebutting.
  - Rule: a finding's severity may not increase across rounds.
  - Disposition record for concerns the human accepts at a gate (e.g. backlog entry) — accepted
    risks must not evaporate.
  - Make concern vs. escalation visibly distinct at the gate: concern = reviewer judgment,
    escalation = unresolved disagreement with both positions attached.
  - Write admission referents separately for Critic (plan-time) and Reviewer (PR-time) — same
    taxonomy, different bar.
