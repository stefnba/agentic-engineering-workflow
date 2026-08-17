# Backlog

Work on the reference material itself. Unsorted collection dump — order carries no meaning.

Tags: `[idea]` new idea worth exploring, `[drift]` noticed inconsistency between docs or code,
`[follow-up]` concrete agreed work.

## Items

- [drift] docs/agents/git.md's Worktrees section references an "optional Release promotion section
  below" that doesn't exist in the file — dangling internal reference, resolve or remove.
- [follow-up] walkthrough.md already names specific skills (`/pick`, `/scan-codebase`,
  `/interview-me`, `/shape`, `/complete-ticket`, `/ship`, `bundle-git`) as if they exist. Each still
  needs to actually be defined as its own modular skill file — including internal, non-user-facing
  ones (`bundle-git`, claim/dispatch mechanics) that no human ever types directly, not just the
  slash commands a human invokes.
- [follow-up] Add reference skill `/codebase-design` — supplies shared vocabulary (module, interface,
  depth, seam, adapter, leverage, locality) for other skills to borrow; not a session driver itself.
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
