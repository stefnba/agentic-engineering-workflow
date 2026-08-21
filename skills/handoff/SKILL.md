---
name: handoff
description: Compact this conversation into a handoff document that a fresh agent can resume from. Prefix the arguments with `problem-only` to withhold this session's analysis, plan, and conclusions so the next one re-derives them.
argument-hint: "[problem-only] What will the next session be used for?"
disable-model-invocation: true
---

# Handoff

Write a handoff document so that an agent with none of this conversation in context can pick up the work without stalling. The test to write against: **the next agent should not have to ask the user anything you already know.**

**Build the document from `${CLAUDE_SKILL_DIR}/templates/handoff.md`, and read it before drafting anything.** It's the shape of the file you write at the path under Saving and handing off — you fill a copy there and the repo's own template stays untouched. It owns the section set, its order, what belongs in each section, and what `problem-only` changes; delete its guidance comments as you fill. Don't reconstruct the section set from memory or restate the template's rules here.

**Determine the mode from `$ARGUMENTS`.** If it begins with `problem-only`, strip that word and fill the template in its problem-only mode. Otherwise fill it in full.

**Treat what remains of the arguments as the next session's focus** — go deeper on the threads that serve it, compress or drop the ones that don't.

## Check before you describe

**Run your checks before you draft, not while you write.** Re-read the files, re-run the commands, look at what's actually uncommitted — including `git status` and `git log` yourself, since the environment's snapshot of them dates from session start and drifts. A claim drafted first and checked later is usually kept: you end up defending recall instead of reporting state, and a handoff that misreports state is worse than none.

**When a check disagrees with your recall, the check wins — and say so in one line**, in the section the corrected claim lives in: a wrong SHA under What's been done, a wrong tree state under Working tree. A document that silently corrects itself leaves the next agent unable to tell which other claims came from the same stale memory. This holds in problem-only mode too: a contradiction you observed is an observation.

**Mark an unchecked claim about the repository or the system with `— unverified`**, and leave the confirmed ones bare. What only this conversation can source — a preference the user voiced, an approach they rejected, your own reasoning — has nothing to check it against, so it carries no marker; the next agent reads it as this session's word.

**Take the clock from one `date '+%Y-%m-%d %H:%M | %Y%m%d-%H%M'` call before you draft** — the left form is the frontmatter's, the right one the filename's. A conversation carries no clock, so a timestamp from memory is a plausible-looking guess, and hand-transforming one form into the other is where it breaks.

**Say when you don't know**, rather than guessing — "unknown whether the migration was applied, worth checking first" is useful; a confident guess in its place is a trap. That's the case where nothing was there to check, distinct from a claim you could have checked and didn't.

**Leave things as you found them** — don't commit, stash, or tidy on the way out unless the user asked. They may be mid-thought, and a handoff that rearranges the state it's describing defeats itself.

## What belongs in the document

**Write what exists only in this conversation**: approaches that failed and why, the reasoning behind choices, corrections the user made, preferences they mentioned in passing, and things you discovered that surprised you. Problem-only mode keeps the observed half of that list and drops the reasoned half — the template draws the line section by section.

**Point at content captured elsewhere** — specs, plans, ADRs, issues, commits, diffs, READMEs, test files — by path, URL, or commit SHA instead of restating it. The next agent can open a file; it cannot recover a discarded approach, or the fact that the user already rejected it.

## Redaction

**Name secrets, never reproduce them** — API keys, tokens, passwords, connection strings, personal data. `uses STRIPE_SECRET_KEY from .env` is the form the next agent needs; the value itself never appears.

**Write it as though someone who shouldn't see the secrets will read it** — the document lands outside the workspace, where the repo's `.gitignore` and access controls don't reach it.

## Saving and handing off

**Write the document to** `~/.claude/handoffs/<repo>-<slug>-<YYYYMMDD-HHMM>.md`, creating the directory if it doesn't exist. That's outside the repo, so it never appears in `git status` or gets swept into a commit along with whatever internal reasoning it carries; outside the temp directory, so it's still there if the next session happens next week. The slug is two to four kebab-case words naming the work — `auth-token-migration`, not the mode and not the arguments verbatim. Check the path first: if it exists, another session claimed it, so add a distinguishing word rather than overwriting their document.

**Keep the document out of the conversation** — report the path and let the next agent read it from disk. You're usually running this because context is short, and printing it spends what's left.

**Close with all three of:**

- the absolute path
- two or three lines on what the document covers, so the user can tell it caught the right things without opening it
- a line they can paste straight into the next session:

```text
Read ~/.claude/handoffs/api-gateway-auth-token-migration-20260807-1430.md and continue from there.
```

Without all three, the document is written but not actually handed off.
