---
name: handoff
description: Compact this conversation into a handoff document that a fresh agent can resume from. Prefix the arguments with `problem-only` to withhold this session's analysis, plan, and conclusions so the next one re-derives them.
argument-hint: "[problem-only] What will the next session be used for?"
disable-model-invocation: true
---

# Handoff

Write a handoff document so that an agent with none of this conversation in context can pick up the work without stalling. The test to write against: **the next agent should not have to ask the user anything you already know.**

**Fill `${CLAUDE_SKILL_DIR}/templates/handoff.md`, and read it before drafting anything.** It owns the section set, its order, what belongs in each section, and what `problem-only` changes; delete its guidance comments as you fill. Don't reconstruct the section set from memory or restate the template's rules here.

**Determine the mode from `$ARGUMENTS`.** If it begins with `problem-only`, strip that word and fill the template in its problem-only mode. Otherwise fill it in full.

**Treat what remains of the arguments as the next session's focus** — go deeper on the threads that serve it, compress or drop the ones that don't.

## Check before you describe

**Confirm what you're about to assert** — re-read the file, re-run the command, look at what's actually uncommitted, rather than trusting recall. A handoff that misreports state is worse than none: it sends the next agent confidently in the wrong direction, and recall drifts over a long session.

**When a check disagrees with your recall, the check wins — and say so in one line.** A document that silently corrects itself leaves the next agent unable to tell which other claims came from the same stale memory. This holds in problem-only mode too: a contradiction you observed is an observation.

**Mark the claims you didn't check** — append `— unverified` to those, and leave the checked ones bare. The next agent builds on both and has to tell them apart; marking only the unchecked half keeps the document short.

**Say when you don't know**, rather than guessing — "unknown whether the migration was applied, worth checking first" is useful; a confident guess in its place is a trap.

**Leave things as you found them** — don't commit, stash, or tidy on the way out unless the user asked. They may be mid-thought, and a handoff that rearranges the state it's describing defeats itself.

## What belongs in the document

**Write what exists only in this conversation**: approaches that failed and why, the reasoning behind choices, corrections the user made, preferences they mentioned in passing, and things you discovered that surprised you.

**Point at content captured elsewhere** — specs, plans, ADRs, issues, commits, diffs, READMEs, test files — by path, URL, or commit SHA instead of restating it. The next agent can open a file; it cannot recover a discarded approach, or the fact that the user already rejected it.

## Redaction

**Name secrets, never reproduce them** — API keys, tokens, passwords, connection strings, personal data. `uses STRIPE_SECRET_KEY from .env` is the form the next agent needs; the value itself never appears.

**Write it as though someone who shouldn't see the secrets will read it** — the document lands outside the workspace, where the repo's `.gitignore` and access controls don't reach it.

## Saving and handing off

**Write the document to** `~/.claude/handoffs/<repo>-<slug>-<YYYYMMDD-HHMM>.md`, creating the directory if it doesn't exist. That's outside the repo, so it never appears in `git status` or gets swept into a commit along with whatever internal reasoning it carries; outside the temp directory, so it's still there if the next session happens next week. The slug is two to four kebab-case words naming the work — `auth-token-migration`, not the mode and not the arguments verbatim.

**Take both timestamps from one `date '+%Y-%m-%d %H:%M'` call** — the frontmatter keeps that format, the filename drops the separators: `2026-08-07 14:30` becomes `20260807-1430`. A conversation carries no clock, so a timestamp from memory is a plausible-looking guess.

**Keep the document out of the conversation** — report the path and let the next agent read it from disk. You're usually running this because context is short, and printing it spends what's left.

**Close with all three of:**

- the absolute path
- two or three lines on what the document covers, so the user can tell it caught the right things without opening it
- a line they can paste straight into the next session:

```text
Read ~/.claude/handoffs/api-gateway-auth-token-migration-20260807-1430.md and continue from there.
```

Without all three, the document is written but not actually handed off.
