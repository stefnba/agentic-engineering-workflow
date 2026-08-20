# 2026-08-20-recap-skill — Session recap skill

## Problem

The workflow deliberately leaves the session's own thread unpersisted. Narrowing "stays
conversational and produces no artifact" ([lifecycle.md](../../../workflow/lifecycle.md), Discover);
a codebase scan's findings "may live only in chat, triaged live"
([artifacts.md](../../../workflow/artifacts.md), Authority); a Reviewer's backlog candidates have no
persistence mechanism at all. So what a session proposed, settled, rejected, or left hanging exists
only in that conversation — and a tab switch, a compaction, or a day's gap takes it. The human's only
recovery today is scrolling the transcript: `bundle-status.sh` answers what the repository holds, and
`handoff` writes a file for the next agent, but nothing reports the conversation back to the person
sitting in it.

## Outcome

A human in any session — bundle session, ticket session, or a session with no bundle at all — asks
for a recap and gets one message back: what this conversation is about, what it settled, what is
still open, and which human gate is due if the conversation established one. It is recollection,
labelled as such, produced without touching the repository and without moving any work forward.

## Scope

**In scope:**

- a `recap` skill: `skills/recap/SKILL.md`, installed like every other skill in this repo
- its entry in `README.md`'s Supporting skills table, and the count and enumeration in the sentence
  above the tables
- a factual correction to [components.md](../../../workflow/components.md)'s Permissions section,
  which states that a skill's tool list withholds a capability. It does not: `allowed-tools`
  pre-approves and withholds nothing, and `disallowed-tools` is the field that removes tools from the
  pool. BC-5 and BC-6 below depend on the corrected reading, and a new skill cannot ship contradicting
  the document that governs it.

**Non-goals — do not build:**

- NG-1: persistence of any kind — no file, no backlog line, no glossary entry, no decision record.
  `handoff` owns writing a session down, and recap does not become the fix for the loss recorded in
  [2026-08-10-interview-persists-nothing-shape-claims-the-bundle.md](../../../docs/decisions/2026-08-10-interview-persists-nothing-shape-claims-the-bundle.md);
  a human who wants this recap kept runs `/handoff`.
- NG-2: repository, bundle, or ticket state — `bundle-git`'s `bundle-status.sh` owns derived state,
  and duplicating it would put a second, staler answer in front of the human.
- NG-3: material shared with `handoff` — no extracted reference file, no cross-loading. Two skills
  with different consumers and different outputs; a shared file would bind them to one voice.
- NG-4: a baseline eval or eval harness for the skill. There is none in this repo, and a synthetic
  transcript is weaker evidence than a live dry run; if skill evals arrive, they arrive for every
  skill at once, from the backlog.
- NG-5: an entry in [docs/walkthrough.md](../../../docs/walkthrough.md) — that document is
  stage-bound navigation and recap is not stage-bound.
- NG-6: an argument that filters the recap to one thread. The recap is short by construction; if the
  unfiltered version proves unreadable in a long session, that is a backlog line.
- NG-7: auditing or correcting the other skills whose frontmatter was written against the wrong
  reading of `allowed-tools` — `backlog`, `pick`, and any other. The correction in scope fixes the
  document; sweeping the skills is separate work and reaches the backlog at Land.

## Behavior

- BR-1: Invoked at any point in any session, `recap` reports that conversation and nothing else.
- BR-2: The report names what the session is about.
- BR-3: The report digests what was discussed and what was suggested, briefly.
- BR-4: The report states what is settled or already done within the conversation, separated from
  what was only suggested.
- BR-5: The report states which threads are still open.
- BR-6: When the conversation establishes that a human gate is due, the report names it; it never
  passes one, and never presents a recap as satisfying one.
- BR-7: When the conversation does not establish gate state, the report says nothing about gates
  rather than inferring one; when it does establish it, the report marks it as possibly moved since,
  because a gate can be passed in another session.
- BR-8: The report is framed as recollection rather than as verified fact.
- BR-9: When the session's earliest available context is a summary rather than the conversation's own
  start, the report says so.
- BR-10: A session with no bundle, no ticket, and no repository work in it still produces a recap of
  whatever was discussed.

## Public contracts

- Invocation: `/recap`, taking no arguments (BR-1, NG-6).
- Model invocation stays enabled: the skill's description fires on a human asking where the session
  stands, what has been covered, or what is still open (BR-1).

## Binding constraints

- BC-1: `recap` reads nothing and runs nothing — no file read, no command, no search, no subagent.
  The conversation is its only source.
- BC-2: The skill is a single `SKILL.md` under `skills/recap/`, with no supporting files.
- BC-3: Every path and cross-skill reference in it resolves in a consuming repo, by the link forms
  and plugin rules in [components.md](../../../workflow/components.md).
- BC-4: It restates no `workflow/` document; where it needs one, it links it
  ([components.md](../../../workflow/components.md), Knowledge arrives two ways).
- BC-5: BC-1 is enforced structurally as far as the tool platform allows: `disallowed-tools` lists
  every tool that reads, writes, runs, searches, or dispatches.
- BC-6: The skill states plainly what BC-5 does not cover — tools it cannot enumerate, and turns
  after the one that invoked it — rather than claiming enforcement it does not have.
- BC-7: The skill runs inline. A forked context receives no conversation, which is the only thing
  recap reports on.

## Invariants

- INV-1: A recap changes nothing outside the conversation — no write, no command, no dispatch, no
  gate passed — in any session state, including one where a gate is due and the obvious next action
  is unambiguous.

## Acceptance criteria

- AC-1 (BR-1, BR-2, BR-3, BR-4, BR-5): Given a session that discussed several things and settled
  some of them, when the human asks for a recap, then one message reports the subject, a brief
  digest of what was discussed and suggested, what is settled or done, and what is still open.
- AC-2 (BR-6, BR-7, INV-1): Given a session whose conversation establishes that a human gate is due,
  when the human asks for a recap, then the report names that gate, marks it as possibly moved since,
  and approves, dispatches and writes nothing.
- AC-3 (BR-8): Given any session, when the human asks for a recap, then the report is framed as
  recollection rather than as checked fact.
- AC-4 (BR-7, BR-9, BR-10): Given the delivered skill, when it is read, then it instructs the agent
  to report a session that establishes no gate state, a session whose earliest context is a summary,
  and a session with no repository work in it — the three cases no live session can be made to
  exhibit on demand.
- AC-5 (BC-1, BC-5, BC-6, INV-1): Given the delivered skill, when its frontmatter and body are read,
  then `disallowed-tools` covers every reading, writing, running, searching and dispatching tool, and
  the body states what that leaves prompt-level.
- AC-6 (BC-2, BC-3, BC-4, BC-7): Given the delivered skill, when its file set, frontmatter and every
  referenced path are checked, then it is one `SKILL.md`, it runs inline, every reference resolves
  under a consuming repo's layout, and no `workflow/` document is restated.

## Test intent

- Seam: the delivered `skills/recap/SKILL.md`, and a recap produced by following it. There is no
  automated harness for a skill in this repo, and NG-4 rules out building one here.
- Levels: AC-4, AC-5 and AC-6 are properties of the delivered document, checkable by reading it and
  by command. AC-1 through AC-3 are behavioral and proven by one dry run — the implementing agent
  follows the delivered file against its own conversation and pastes the result into the PR body.
  That evidence is re-derivable rather than attested: any reader, the Reviewer included, gets a recap
  by following the same file against their own session.
- Risk cases: a session at a due gate, where an agent is likeliest to act rather than report; a
  session whose gate state is stale or unestablished; a compacted session; a session with no
  repository work in it; the temptation to answer "what is settled" by reading the repository.
- Locked tests: none.
- Accepted at the Plan gate: no harness judges recap quality. A recap that is accurate but poorly
  chosen — the wrong things called settled, the interesting thread missed — fails no automated check,
  and the Reviewer judges it by reading the delivered text and its own re-derived recap.

## References

- [components.md](../../../workflow/components.md) — how a role is packaged as a skill; binds BC-2
  through BC-7, and is itself corrected by this bundle.
- [Claude Code skills reference](https://code.claude.com/docs/en/skills) — `allowed-tools` "does not
  restrict which tools are available"; `disallowed-tools` removes tools from the pool for the
  invoking turn. The mechanism BC-5, BC-6 and the components.md correction rest on.
- [2026-08-08-distribute-as-claude-code-plugin.md](../../../docs/decisions/2026-08-08-distribute-as-claude-code-plugin.md)
  — everything in this tree ships to consuming repos, which is why BC-3 binds.
- [2026-08-10-interview-persists-nothing-shape-claims-the-bundle.md](../../../docs/decisions/2026-08-10-interview-persists-nothing-shape-claims-the-bundle.md)
  — records the unpersisted-session cost this recap reports on and deliberately does not fix (NG-1).
