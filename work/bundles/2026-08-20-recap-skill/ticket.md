---
intent: spec.md
depends_on: []
---

# 01 — Add the recap skill

## Context

`skills/` holds fifteen skills today; none reports the conversation itself back to the human, and
`README.md`'s Supporting skills table and the sentence above it both enumerate the set. This ticket
adds `skills/recap/SKILL.md`, its `.claude/skills/` symlink, the README entries, and the factual
correction to `workflow/components.md` that the skill's own enforcement claim depends on. Recap is
not stage-bound, so no `workflow/` document gains an obligation.

## Outcome

`/recap` exists as an installed skill: invoked in any session it reports that conversation's subject,
digest, settled points, open threads, and due gate, reads nothing, and writes nothing — with the
reading and acting tools withheld by its frontmatter rather than by instruction.

**Delivers:** BR-1 … BR-10, BC-1 … BC-7, INV-1, AC-1 … AC-6

## Scope

- `skills/recap/SKILL.md` (new) — the whole skill, per BC-2
- `.claude/skills/recap` (new) — symlink to `../../skills/recap`, per this repo's `CLAUDE.md`
- `README.md` (modified) — one row in Supporting skills, plus the count and the name enumeration in
  the sentence above the tables, which today reads "Fifteen exist … `setup`, `backlog`, …"
- `workflow/components.md` (modified) — the Permissions section's first bullet, which claims a tool
  list withholds a capability outright. True of an agent's `tools:`; false of a skill's
  `allowed-tools`. Correct it to the real split and name `disallowed-tools` as the withholding field

## Not in this ticket

- Auditing the other skills whose `allowed-tools` was written against the wrong reading — NG-7;
  reaches the backlog at Land
- A recap-to-handoff conversion, or any shared material between the two skills — NG-1, NG-3
- Any eval, harness, or baseline for skills — NG-4
- `docs/walkthrough.md`, the rest of `workflow/`, and the Workflow skills table — NG-5

## Implementation notes

- Read `${CLAUDE_PLUGIN_ROOT}/skills/writing-for-agents/SKILL.md` before drafting, and its
  `references/skill-mechanics.md` for frontmatter — it owns how an agent-facing document is written
  and how a description is worded to fire. NG-4 removes only its baseline step; the rest applies.
- `skills/pick/SKILL.md` is the closest model in voice and shape: a read-only skill that presents to
  the human and hands the decision back. `skills/handoff/SKILL.md` is the near neighbour to stay
  distinct from — read it to avoid converging on it, not to borrow from it.
- BC-5's mechanism is settled, not for rediscovery:
  https://code.claude.com/docs/en/skills#pre-approve-tools-for-a-skill — `allowed-tools` "does not
  restrict which tools are available: every tool remains callable"; `disallowed-tools` holds "tools
  removed from Claude's available pool while this skill is active", and "the restriction clears when
  you send your next message". A recap completes within its invoking turn, so that lifetime covers
  it; enumerate the tool set this repo's sessions actually expose.
- BC-6's residue follows from the same page: a tool the field does not name — an MCP tool, a tool
  added later — stays callable, and so does everything on the next turn.
- The symlink loads at the next session start, not mid-session, so the dry run below follows the
  file's instructions by hand rather than by invoking `/recap`.

## Autonomy boundaries

**May decide:**

- The skill's section set, headings, ordering, and prose, within BR-2 … BR-10
- The exact wording of the description, provided it fires on the cases in the Public contracts
  section of the spec
- Whether the recap's categories are fixed headings or shaped per session
- Which tool names `disallowed-tools` enumerates, provided AC-5 holds
- The wording of the `workflow/components.md` correction, provided it stays a factual correction and
  changes no rule

**Must preserve:**

- BC-1: recap reads nothing and runs nothing — the conversation is its only source
- BC-6: the skill states what `disallowed-tools` does not cover, rather than claiming full enforcement
- INV-1: a recap changes nothing outside the conversation, in any session state
- NG-2: derived repository, bundle, and ticket state stays with `bundle-status.sh`
- NG-3: no material is shared with, or extracted from, `handoff`

## Done when

**Pre-change evidence:**

- Recorded before the change: `ls skills/recap` fails, and `grep -n 'recap' README.md` returns
  nothing. No behavior test applies — this slice ships one document, and NG-4 rules out building a
  harness for it.

**Conditions:**

- [ ] `skills/recap/SKILL.md` exists and is the only file under `skills/recap/` (AC-6)
- [ ] `.claude/skills/recap` resolves to it
- [ ] `README.md` lists `recap` in the Supporting skills table, in the name enumeration above the
      tables, and the count in that sentence reads sixteen
- [ ] The skill's frontmatter carries no `context: fork`, and its `disallowed-tools` names every
      tool that reads, writes, runs, searches, or dispatches (AC-5, AC-6)
- [ ] The skill's body states what `disallowed-tools` leaves prompt-level — unenumerated tools, and
      turns after the invoking one (AC-5)
- [ ] Every path the skill references resolves under a consuming repo's layout, by the link forms in
      `workflow/components.md`, and none is a bare relative path into the plugin (AC-6)
- [ ] The skill links `workflow/` documents rather than restating them (AC-6)
- [ ] The skill's text instructs the agent on all three cases no live session can be made to
      exhibit: gate state not established, earliest context a summary, no repository work in the
      session (AC-4)
- [ ] A dry run — following the delivered `SKILL.md` against this implementation session's own
      conversation — is pasted in the PR body, and reports subject, digest, settled points and open
      threads (AC-1)
- [ ] That dry run names the Accept gate as due, marks it as possibly moved since, and proposes no
      action, dispatches nothing, and approves nothing (AC-2)
- [ ] That dry run is framed as recollection rather than as checked fact, and required no tool call
      to produce (AC-3)
- [ ] `workflow/components.md`'s Permissions section states the `allowed-tools` / `disallowed-tools`
      split correctly and no rule in it changed

**Commands:**

**Requires:** none

```bash
ls skills/recap/                              # expect: SKILL.md, and nothing else
readlink .claude/skills/recap                 # expect: ../../skills/recap
grep -c 'recap' README.md                     # expect: at least 2 (table row, enumeration)
grep -nE '\(([^)]*/)[^)]*\)|[A-Za-z0-9_.-]+/[A-Za-z0-9_./-]+' skills/recap/SKILL.md
                                              # expect: every path hit is ${CLAUDE_PLUGIN_ROOT}/…,
                                              # ${CLAUDE_SKILL_DIR}/… or ${CLAUDE_PROJECT_DIR}/…,
                                              # or a bare skill name; no bare relative path
grep -n 'disallowed-tools\|context: fork' skills/recap/SKILL.md
                                              # expect: a disallowed-tools line, no context: fork
```

## Escalate instead of guessing if…

- Meeting BR-6 (naming the due gate) or BR-10 (a session with no repository work) turns out to need a
  repository read, which would contradict BC-1 and reopen the spec.
- The distinction from `handoff` stops holding while drafting — if the honest shape is one skill with
  two modes, that is a Plan-gate decision, not a drafting one.
- `disallowed-tools` turns out not to behave as the linked documentation describes in the installed
  version, which would move BC-5 from structural to prompt-level and change what the human approved.
