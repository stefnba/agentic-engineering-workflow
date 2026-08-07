---
name: handoff
description: Compact this conversation into a handoff document that a fresh agent can resume from.
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
---

# Handoff

Write a handoff document so that an agent with none of this conversation in context can pick up the work without stalling.

The test to write against: **the next agent should not have to ask the user anything you already know.** Everything below follows from that.

If arguments were passed, treat them as the next session's focus. Bias the whole document toward it — go deeper on the threads that serve it, and compress or drop the ones that don't.

## Check before you describe

A handoff that misreports state is worse than none — it sends the next agent confidently in the wrong direction, and recall drifts over a long session. Confirm what you're about to assert rather than remembering it: re-read the file, re-run the command, look at what's actually uncommitted.

Separate what you verified from what you reasoned your way to but never checked. The next agent will build on both and needs to know which parts are load-bearing. Where you genuinely don't know, say so — "unknown whether the migration was applied, worth checking first" is useful; a confident guess in its place is a trap.

Leave things as you found them. Don't commit, stash, or tidy on the way out unless the user asked: they may be mid-thought, and a handoff that rearranges the state it's describing defeats itself.

This applies to the document's own header. You have no reliable sense of the current time — a conversation carries no clock, and anything you produce from memory will be a plausible-looking guess. Run `date '+%Y-%m-%d %H:%M'` and use its output, both in the header and for the filename timestamp. Take the repository name and branch from the environment the same way rather than recalling them.

## What belongs in the document

The content worth writing is what exists **only in this conversation**: approaches that failed and why, the reasoning behind choices, corrections the user made, preferences they mentioned in passing, and things you discovered that surprised you.

Content already captured elsewhere — specs, plans, ADRs, issues, commits, diffs, READMEs, test files — should be referenced by path, URL, or commit SHA instead of restated. The next agent can open a file. It cannot recover a discarded approach, or the fact that the user already rejected it.

## Structure

Read [example-structure.md](example-structure.md) before you start writing, and follow its section order. Don't reconstruct the shape from memory — the section set is the part of this skill that keeps handoffs comparable to each other.

### Sections

Full section list, in order:

- Objective
- Findings
- Open questions
- Ground covered
- Working tree
- Current state
- What's been done
- Next steps
- Decisions and constraints
- Dead ends
- Key files
- Verification
- Suggested skills

**Note**: Not every section fits every session. A discovery session may have nothing to say about a working tree; an implementation session may have no open questions. Take the ones that match the work and drop the rest — an empty heading is worse than a missing one, because it implies there was nothing to report.

Length should track the complexity of the work; most handoffs land well under 150 lines. Write for an agent rather than a human: no progress-report framing, no assessment of how the session went.

For **suggested skills**, list only skills that actually exist in this environment — check what's available instead of inventing plausible-sounding names, since a fabricated name sends the next agent hunting for something that isn't there. Say when to reach for each one, not just that it exists.

## Redaction

Don't copy secrets into the document: API keys, tokens, passwords, connection strings, or personal data. Pointing at a secret is fine (`uses STRIPE_SECRET_KEY from .env`); reproducing its value is not.

This matters more than usual here because the document lands outside the workspace, where the repo's `.gitignore` and access controls don't reach it. Write it as though someone who shouldn't see the secrets will read it.

## Saving and handing off

**Destination**: Write to `~/.claude/handoffs/<repo>-<slug>-<YYYYMMDD-HHMM>.md`, creating the directory if it doesn't exist.

Outside the repo, so it never appears in `git status` or gets swept into a commit along with whatever internal reasoning it contains; outside the temp directory, so it's still there if the next session happens next week.

Don't print the document into the conversation. You're usually running this because context is short, and the next agent will read it from disk anyway.

Close instead with the absolute path, two or three lines on what the document covers so the user can tell it caught the right things without opening it, and a line they can paste straight into the next session:

```text
Read ~/.claude/handoffs/api-auth-refactor-20260807-1430.md and continue from there.
```

Without that last part the document is written but not actually handed off.
