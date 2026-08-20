# Backlog

Work on the reference material itself. Unsorted collection dump — order carries no meaning.

## Items

- [follow-up] [skills] The research split from `docs/decisions/2026-08-18-consuming-repo-layout.md` is now in
  `workflow/artifacts.md`'s authority table, but the research skill that has to honour it is unbuilt.
- [follow-up] [agents] Structurally enforce the read-only agents. `agents/reviewer.md` and `agents/critic.md`
  now carry a `tools:` allowlist, which withholds file editing only — both keep `Bash` because
  verification and repository reading need it, so nothing stops a push, approve, or merge except the
  prompt. Both prompts and `workflow/lifecycle.md`'s Run conditions say so plainly rather than
  overclaiming. Close it with a hook or a permission rule, and the same question applies to the
  Architect's "write access only to the draft bundle" boundary.
- [follow-up] [skills] `bundle-git` has no Land-side script: nothing lands a bundle branch on the integration
  target. The rules it must implement are settled — see "Landing a bundle" in
  `workflow/git-mechanics.md` — but nothing enforces them, and `TICKET_MERGE_METHOD` deliberately does not
  cover the land.- [follow-up] [skills] [docs] walkthrough.md names skills that still don't exist: `/pick`, `/scan-codebase`,
  `/complete-ticket`, `/land`. `/interview-me`, `/shape`, and `/critique` now do. `bundle-git` owns
  claim, status, and merge, so `/complete-ticket` should call its script rather than reimplementing
  the merge — and the internal, non-user-facing dispatch skills still need defining too, not just
  the slash commands a human types.
- [follow-up] [skills] Make `docs/conventions/git.md` a setup-skill template (`skills/setup/templates/git.md`)
  with this repo's copy as the dogfooded instance, same relationship as `work/backlog.md`.
- [follow-up] [skills] `shape` publishes the approved bundle by hand — `git add`/`commit`/`push` from the
  prompt, sourcing `bundle-git`'s `_config.sh` for `INTEGRATION_TARGET`. Every other state
  transition is a script; this one is prose, so a collision retry or a wrong target branch depends
  on the model following instructions. Consider `bundle-git/scripts/publish-bundle.sh`.
- [drift] [workflow] [skills] `workflow/git-mechanics.md` says the `bundle-git` skill owns bundle branch creation and
  cleanup, but the skill only creates the bundle branch and removes a ticket's worktree. Land's
  branch and worktree cleanup is unimplemented. (The undefined "sync" it also claimed is gone.)
- [follow-up] [skills] `bundle-git`'s claim is verified over the `git://` smart protocol, never against
  github.com over HTTPS, and the chain claim → PR → `/complete-ticket` → derived `done` has never run
  joined — only its two halves separately. One real push settles both. Smaller gaps:
  `--match-head-commit` was confirmed to exist but never exercised against a mismatched head, and
  everything ran on darwin with git 2.52.
- [follow-up] [skills] Add reference skill `/codebase-design` — supplies shared vocabulary (module, interface,
  depth, seam, adapter, leverage, locality) for other skills to borrow; not a session driver itself.
- [follow-up] [skills] `bundle-git` documents a `depends_on` input rule it doesn't enforce, verified by
  running it: `claim-ticket.sh` parses the line with a `sed` that handles only the flow form
  `[01, 02]`. `skills/shape/templates/ticket.md` names every unsafe form — quoted or unpadded
  numbers block the claim forever, a trailing comment reads as a dependency, block-sequence style
  fails open and lets a dependent ticket start early — so the rule reaches whoever writes a ticket
  from the template, and nothing catches a hand-edit that ignores it. (The sibling `ls tickets`
  count is fixed: `_config.sh`'s `ticket_base` globs `NN-<slug>.md`, with a regression test.)
- [drift] [workflow] `workflow/bundle.md` puts the characterization-test mandate on the plan, but a refactor on
  the intent-plus-tickets route has no plan, so the mandate has no home there.
- [idea] [skills] Add a session-recap skill (`/recap`), callable from any session at any point. Reports the
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
- [drift] [skills] [docs] Skill names are settled in `README.md` and `docs/walkthrough.md`, but the unbuilt ones
  hold nothing: `scan-codebase` (`audit` on the `old-workflow` tag), `backlog`, `pick`, `research`,
  and the stage drivers. Whoever implements each should claim its name from the README table.
- [follow-up] [skills] Four skills stay on the `old-workflow` tag because they encode the superseded
  contract: `backlog`, `pick`, `research`, and `audit` (→ `scan-codebase`). Nothing blocks them now
  that the Ship→Land rename and the Finding-protocol extraction are both done — write them fresh
  against `workflow/`, with `git show old-workflow:skills/<name>/SKILL.md` as reference, rather
  than restoring and patching paths. The stage drivers (`shape`, `critique`, `implement`, `review`,
  `land`) are a full rewrite regardless.
