# Todo

Finding protocol refinements (from independent judge ruling — keep two severities, harden the record):

- [ ] Mandatory violated-referent field per finding (spec BR/AC/INV, ticket done-when, decision record, CI gate, or concrete failure mechanism) — nitpicks inadmissible by construction
- [ ] Binary confidence flag (`verified | suspected`); fix mode verifies suspected findings before fixing or rebutting
- [ ] Rule: a finding's severity may not increase across rounds
- [ ] Disposition record for concerns the human accepts at a gate (e.g. backlog entry) — accepted risks must not evaporate
- [ ] Make concern vs. escalation visibly distinct at the gate: concern = reviewer judgment, escalation = unresolved disagreement with both positions attached
- [ ] Write admission referents separately for Critic (plan-time) and Reviewer (PR-time) — same taxonomy, different bar

Add reference skill /codebase-design? -> /codebase-design is a reference, not a session driver. It supplies the vocabulary — module, interface, depth, seam, adapter, leverage, locality — and this skill borrows it.
