# Backlog

Candidate work and follow-ups nobody has picked yet.

## Items

- [follow-up] [skills] The research split from `docs/decisions/2026-08-18-consuming-repo-layout.md` is now in
  `workflow/artifacts.md`'s authority table, but the research skill that has to honour it is unbuilt.
- [follow-up] [agents] Structurally enforce the read-only agents. `agents/reviewer.md` and `agents/critic.md`
  now carry a `tools:` allowlist, which withholds file editing only — both keep `Bash` because
  verification and repository reading need it, so nothing stops a push, approve, or merge except the
  prompt. Both prompts and `workflow/lifecycle.md`'s Run conditions say so plainly rather than
  overclaiming. Close it with a hook or a permission rule, and the same question applies to the
  Architect's "write access only to the draft bundle" boundary.
- [follow-up] [skills] `land-bundle.sh cleanup` deletes every ticket branch and the bundle branch
  unconditionally, where `git show old-workflow:skills/bundle-git/SKILL.md` classified them first —
  merged, open PR, in flight — and refused to touch anything unmerged. Add that classification:
  `gh pr list --head` rather than ancestry, because a squash merge leaves none.
- [drift] [skills] [docs] `README.md` and `docs/walkthrough.md` name skills that hold nothing yet —
  `scan-codebase`, `research`, and `complete-ticket`. (`land` and `review` now exist.)
  Whoever builds one claims its name from the README table. One constraint is already settled:
  `bundle-git` owns claim, status, and merge, so `/complete-ticket` calls its script rather than
  reimplementing the merge.
- [follow-up] [skills] `shape` publishes the approved bundle by hand — `git add`/`commit`/`push` from the
  prompt, sourcing `bundle-git`'s `_config.sh` for `INTEGRATION_TARGET`. Every other state
  transition is a script; this one is prose, so a collision retry or a wrong target branch depends
  on the model following instructions. Consider `bundle-git/scripts/publish-bundle.sh`.
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
- [follow-up] [skills] Two skills stay on the `old-workflow` tag because they encode the superseded
  contract: `research` and `audit` (→ `scan-codebase`), along with the `researcher` agent they fork
  into. Write them fresh against `workflow/`, with `git show old-workflow:skills/<name>/SKILL.md` as
  reference, rather than restoring and patching paths; `researcher` preloads `backlog` via its
  `skills:` field, which now exists. Open first: `audit` wrote a `docs/research/audit-*.md` plus
  backlog lines autonomously, but `docs/walkthrough.md` and `workflow/artifacts.md` now say a
  codebase scan's findings stay inline in chat and get triaged live — settle which before writing
  it.
- [follow-up] [skills] A consuming repo has no read path into `workflow/` at all. The installed `AGENTS.md`
  pointer deliberately stops at naming the plugin, `docs/conventions/git.md`, `work/config.conf`, and the
  two caretaker skills: no placeholder resolves in project instructions, and the line routing every stage
  through its own skill was dropped on purpose. So a session that wants to read the contract — or
  `docs/walkthrough.md` — has nowhere to go, and an agent that never invokes a stage skill never learns
  the lifecycle exists. Ship a reference skill that loads `workflow/lifecycle.md` on demand, or accept
  that the stage skills are the only entry.
- [follow-up] [skills] `skills/bundle-git/tests/run.sh` pins that a stray file _inside_ `tickets/` can't flip
  the branch strategy, but nothing pins a sibling directory under `work/bundles/<id>/`. `ticket_base` is
  safe today by inspection; add the case before any design puts a directory there.
- [drift] [docs] `skills/record-decision/templates/decision-record.md` mandates YAML frontmatter with
  `areas:`, and `workflow/artifacts.md` reads the area vocabulary from records' frontmatter — but
  `2026-08-18-consuming-repo-layout.md` and `2026-08-18-script-read-settings.md` use a prose byline and
  `2026-08-18-fixed-bundle-land.md` has frontmatter without `areas:`. All three are immutable, so the fix
  is not an edit: either supersede them or accept that the vocabulary reads from the rest.
- [idea] [skills] `shape` picks the test seam while drafting and confirms it in the step-5 batch; the
  `old-workflow` shape confirmed it before drafting, because acceptance criteria are phrased at the seam
  and moving it late rewrites the spec around it.
