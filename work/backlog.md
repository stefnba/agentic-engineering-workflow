# Backlog

Work on the reference material itself. Unsorted collection dump — order carries no meaning.

Tags:

- `[idea]` new idea worth exploring
- `[drift]` noticed inconsistency between docs or code
- `[follow-up]` concrete agreed work

## Items

- [follow-up] The research split from `docs/decisions/2026-08-18-consuming-repo-layout.md` is now in
  `workflow/artifacts.md`'s authority table, but the research skill that has to honour it is unbuilt.
- [follow-up] `skills/setup/SKILL.md` is a placeholder: it states what a run writes but nothing
  performs the interview or the writes. Implement it — `work/config.conf` from
  `skills/setup/templates/config.conf`, `docs/conventions/git.md`, the `AGENTS.md` pointer line, and
  the `WORKTREE_DIR` line in `.gitignore` (per `docs/decisions/2026-08-18-script-read-settings.md`).
- [follow-up] Structurally enforce the read-only agents. `agents/reviewer.md` and `agents/critic.md`
  now carry a `tools:` allowlist, which withholds file editing only — both keep `Bash` because
  verification and repository reading need it, so nothing stops a push, approve, or merge except the
  prompt. Both prompts and `workflow/lifecycle.md`'s Run conditions say so plainly rather than
  overclaiming. Close it with a hook or a permission rule, and the same question applies to the
  Architect's "write access only to the draft bundle" boundary.
- [follow-up] `bundle-git` has no Ship-side script: nothing lands a bundle branch on the integration
  target. The rules it must implement are settled — see "Landing a bundle" in
  `workflow/git-mechanics.md` — but nothing enforces them, and `TICKET_MERGE_METHOD` deliberately does not
  cover the land.
- [follow-up] Rename the Ship stage to Land — "ship" implies production release, which the workflow
  explicitly doesn't own (the integration target may be `dev`, promotion to the protected branch is
  a separate release process); "lands on the integration target" is already the docs' own phrasing.
  Rename sweeps lifecycle.md, walkthrough.md, artifacts.md ("Shipped" lifetime state → "Landed"),
  bundle.md, AGENTS.md, and the planned `/ship` skill name (→ `/land`).
- [drift] lifecycle.md and artifacts.md link _to_ walkthrough.md in three places added this session
  (Coordination's session/tab model, Discover's narrowing mechanics, Discovery evidence's
  scan-triage mechanics) — but walkthrough.md is the practical, derived "how you run this" guide,
  not an owning doc other docs should depend on, per AGENTS.md's "link to the owning doc" rule.
  Either move the referenced content to a proper owning doc and have both sides link to it, or
  confirm walkthrough.md legitimately owns these specific facts and the direction is fine as-is.
- [follow-up] walkthrough.md already names specific skills (`/pick`, `/scan-codebase`,
  `/interview-me`, `/shape`, `/complete-ticket`, `/ship`) as if they exist. Each still needs to
  actually be defined as its own modular skill file — including internal, non-user-facing ones
  (dispatch mechanics) that no human ever types directly, not just the slash commands a human
  invokes. `bundle-git` now exists and owns claim, status, and merge; `/complete-ticket` should call
  its script rather than reimplementing the merge.
- [follow-up] Make `docs/conventions/git.md` a setup-skill template (`skills/setup/templates/git.md`)
  with this repo's copy as the dogfooded instance, same relationship as `work/backlog.md`.
- [follow-up] Extract the Finding protocol section out of `workflow/lifecycle.md` into its own doc.
  Critic, Reviewer, and Implementer (fix mode) all load it; it is the clearest multi-consumer
  contract in the tree and currently reachable only by loading the whole lifecycle doc.
- [follow-up] Neither `skills/setup/` nor `skills/shape/` has a `SKILL.md` yet — both hold only their
  reference material (`setup/references/prerequisites.md`, `shape/templates/`).
- [drift] `workflow/git-mechanics.md` says the `bundle-git` skill owns bundle branch creation and
  cleanup, but the skill only creates the bundle branch and removes a ticket's worktree. Ship's
  branch and worktree cleanup is unimplemented. (The undefined "sync" it also claimed is gone.)
- [follow-up] `bundle-git`'s claim is verified over the `git://` smart protocol, never against
  github.com over HTTPS, and the chain claim → PR → `/complete-ticket` → derived `done` has never run
  joined — only its two halves separately. One real push settles both. Smaller gaps:
  `--match-head-commit` was confirmed to exist but never exercised against a mismatched head, and
  everything ran on darwin with git 2.52.
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
- [idea] Add a session-recap skill (`/recap`), callable from any session at any point. Reports the
  flow of the chat session itself — not repository, bundle, or ticket state: what this session is
  about, a very brief digest of what was discussed, what was suggested, what's already settled or
  done in the conversation, and which threads are still open. Earns its keep because the workflow
  deliberately leaves this unpersisted — narrowing "produces no artifact", scan findings stay
  "inline in chat only", Reviewer backlog candidates have no persistence mechanism — so a recap
  surfaces it before a tab switch or context compaction loses it. Read-only reporting only: it may
  name the human gate that is due but never passes one and dispatches nothing, and it marks
  recollection as recollection (including saying so when context was compacted). Don't name it
  `/status` and don't have it restate derived ticket status — `bundle-status.sh` already answers
  that, and it's a different question.
