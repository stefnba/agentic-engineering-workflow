---
name: handoff
description: Compact this conversation into a handoff document that a fresh agent can resume from.
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
---

# Handoff

Write a handoff document so that an agent with none of this conversation in context can pick up the work without stalling.

The test to write against: **the next agent should not have to ask the user anything you already know.** Everything below follows from that.

**If arguments were passed, treat them as the next session's focus** — go deeper on the threads that serve it, compress or drop the ones that don't.

## Check before you describe

**Confirm what you're about to assert** — re-read the file, re-run the command, look at what's actually uncommitted, rather than trusting recall. A handoff that misreports state is worse than none: it sends the next agent confidently in the wrong direction, and recall drifts over a long session.

**Separate what you verified from what you reasoned your way to but never checked.** The next agent will build on both and needs to know which parts are load-bearing.

**Say when you don't know**, rather than guessing — "unknown whether the migration was applied, worth checking first" is useful; a confident guess in its place is a trap.

**Leave things as you found them** — don't commit, stash, or tidy on the way out unless the user asked. They may be mid-thought, and a handoff that rearranges the state it's describing defeats itself.

**Run `date '+%Y-%m-%d %H:%M'`** for the header and filename timestamp — a conversation carries no clock, and a timestamp from memory will be a plausible-looking guess.

**Take the repository name and branch from the environment**, not from memory — `git rev-parse --show-toplevel` and `git branch --show-current`.

**Add a Worktree field only when this session ran in an isolated worktree** distinct from the repo's primary checkout; most sessions don't need it.

## What belongs in the document

**Write what exists only in this conversation**: approaches that failed and why, the reasoning behind choices, corrections the user made, preferences they mentioned in passing, and things you discovered that surprised you.

**Point at content captured elsewhere** — specs, plans, ADRs, issues, commits, diffs, READMEs, test files — by path, URL, or commit SHA instead of restating it. The next agent can open a file; it cannot recover a discarded approach, or the fact that the user already rejected it.

## Structure

**Don't reorder or reconstruct the section set from memory** — it's what keeps handoffs comparable to each other; the canonical list is below.

**Read `${CLAUDE_SKILL_DIR}/example-structure.md` once you know which sections apply**, for shape and detail level — how much to say per section, how terse to be. It doesn't define which sections exist or their order; that's below.

### Sections

Full section list, in order, each with the question it answers:

- **Objective** — what the work is trying to accomplish, and what's explicitly out of scope.
- **Findings** — what you learned that wasn't already known: how the system actually behaves, contra assumptions.
- **Open questions** — what nobody has decided yet, and who owns the decision if known.
- **Ground covered** — approaches or areas already explored, so the next agent doesn't re-tread them.
- **Working tree** — uncommitted files: what each one is, and whether it's deliberate WIP or debris.
- **Current state** — what currently works, what's stubbed or faked, what to distrust.
- **What's been done** — commits and completed changes, by SHA or path.
- **Next steps** — ordered, concrete actions, each ending on a completion criterion.
- **Decisions and constraints** — choices already made and why, so the next agent doesn't relitigate them.
- **Dead ends** — approaches tried and abandoned, and why, so they aren't retried.
- **Key files** — paths worth opening first, with a one-line reason each.
- **Verification** — commands that confirm the state, and which failures predate this session.
- **Suggested skills** — skills installed in this environment relevant to what's next.

**Take the sections that match the work and drop the rest** — a discovery session may have nothing to say about a working tree, an implementation session may have no open questions. An empty heading is worse than a missing one: it implies there was nothing to report.

**Track length to the complexity of the work** — most handoffs land well under 150 lines.

**Write for an agent, not a human** — no progress-report framing, no assessment of how the session went.

**List only skills that actually exist in this environment**, for Suggested skills — check what's available instead of inventing plausible-sounding names; a fabricated name sends the next agent hunting for something that isn't there.

**Say when to reach for each suggested skill**, not just that it exists.

## Redaction

**Don't copy secrets into the document** — API keys, tokens, passwords, connection strings, personal data. Pointing at a secret is fine (`uses STRIPE_SECRET_KEY from .env`); reproducing its value is not.

**Write it as though someone who shouldn't see the secrets will read it** — the document lands outside the workspace, where the repo's `.gitignore` and access controls don't reach it.

## Saving and handing off

**Write the document to** `~/.claude/handoffs/<repo>-<slug>-<YYYYMMDD-HHMM>.md`, creating the directory if it doesn't exist. That's outside the repo, so it never appears in `git status` or gets swept into a commit along with whatever internal reasoning it contains; outside the temp directory, so it's still there if the next session happens next week.

**Don't print the document into the conversation** — you're usually running this because context is short, and the next agent will read it from disk anyway.

**Close with all three of:**

- the absolute path
- two or three lines on what the document covers, so the user can tell it caught the right things without opening it
- a line they can paste straight into the next session:

```text
Read ~/.claude/handoffs/api-auth-refactor-20260807-1430.md and continue from there.
```

Without all three, the document is written but not actually handed off.
