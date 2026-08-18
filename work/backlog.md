# Backlog

Work on the reference material itself. Unsorted collection dump — order carries no meaning.

Tags:

- `[idea]` new idea worth exploring
- `[drift]` noticed inconsistency between docs or code
- `[follow-up]` concrete agreed work

## Items

- [follow-up] The research split from `docs/decisions/2026-08-18-consuming-repo-layout.md` is now in
  `workflow/artifacts.md`'s authority table, but the research skill that has to honour it is unbuilt.
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
- [follow-up] walkthrough.md names skills that still don't exist: `/pick`, `/scan-codebase`,
  `/complete-ticket`, `/ship`. `/interview-me`, `/shape`, and `/critique` now do. `bundle-git` owns
  claim, status, and merge, so `/complete-ticket` should call its script rather than reimplementing
  the merge — and the internal, non-user-facing dispatch skills still need defining too, not just
  the slash commands a human types.
- [follow-up] Make `docs/conventions/git.md` a setup-skill template (`skills/setup/templates/git.md`)
  with this repo's copy as the dogfooded instance, same relationship as `work/backlog.md`.
- [follow-up] Extract the Finding protocol section out of `workflow/lifecycle.md` into its own doc.
  Critic, Reviewer, and Implementer (fix mode) all load it; it is the clearest multi-consumer
  contract in the tree and currently reachable only by loading the whole lifecycle doc. Now more
  pressing: `agents/critic.md` and `agents/reviewer.md` both point at `lifecycle.md` by path for the
  two severities, so each drags in the whole lifecycle doc to read two definitions.
- [drift] `skills/record-decision/SKILL.md` is frontmatter only — four lines, no body. Nothing tells
  an agent what to do, and it never points at its own
  `${CLAUDE_SKILL_DIR}/templates/decision-record.md`, so the template is unreachable.
- [follow-up] `shape` publishes the approved bundle by hand — `git add`/`commit`/`push` from the
  prompt, sourcing `bundle-git`'s `_config.sh` for `INTEGRATION_TARGET`. Every other state
  transition is a script; this one is prose, so a collision retry or a wrong target branch depends
  on the model following instructions. Consider `bundle-git/scripts/publish-bundle.sh`.
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
- [follow-up] `bundle-git` documents input rules it should enforce, both verified by running it:
  `claim-ticket.sh:35` parses `depends_on` with a `sed` that mishandles three of the four YAML forms
  — quoted or unpadded numbers block the claim forever, block-sequence style fails open and lets a
  dependent ticket start early — and `claim-ticket.sh:25` / `ticket-status.sh:12` count `ls tickets`
  entries, so a stray file flips the branch strategy.
- [follow-up] `scripts/find-by-frontmatter.py:163` parses the whole file instead of stopping at the
  closing `---`, so any body with a bullet list crashes it. Every filled ticket triggers it.
- [drift] `workflow/bundle.md` puts the characterization-test mandate on the plan, but a refactor on
  the intent-plus-tickets route has no plan, so the mandate has no home there.
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
- [drift] Skill names are settled in `README.md` and `docs/walkthrough.md`, but the unbuilt ones
  hold nothing: `scan-codebase` (`audit` on the `old-workflow` tag), `backlog`, `pick`,
  `interview-me`, `research`, and the stage drivers. Whoever implements each should claim its name
  from the README table.
- [follow-up] Five skills stay on the `old-workflow` tag because they encode the superseded
  contract: `backlog`, `pick`, `interview-me`, `research`, and `audit` (→ `scan-codebase`). They are
  blocked behind the Ship→Land rename and the Finding-protocol extraction — write them fresh against
  `workflow/` afterwards, with `git show old-workflow:skills/<name>/SKILL.md` as reference, rather
  than restoring and patching paths. The stage drivers (`shape`, `critique`, `implement`, `review`,
  `ship`) are a full rewrite regardless.
