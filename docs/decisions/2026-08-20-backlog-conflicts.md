---
date: 2026-08-20
status: accepted
areas: [workflow, skills]
---

# A backlog conflict is resolved by keeping both sides, in the merge that hits it

## Context

`work/backlog.md` is written from several branches at once and by design: `shape`'s write boundary
permits it so a Shape session can append a Critic candidate, and Land drains leftovers into it from
its own worktree. Both writes are appends at the end of the file, so git's default merge calls them a
conflict — `CONFLICT (content): Merge conflict in work/backlog.md` — over two lines that both belong.

Reproduced against real git, and it survives the Land-worktree correction: moving Land to a detached
worktree on the integration target shrinks the window to the gap between fetch and push, but the
recovery merge still conflicts. It also predates Land — two Shape sessions appending to the same
branch hit it on `git pull`.

## Decision

**The rule:** a conflict in `work/backlog.md` is resolved by keeping both sides, always. The file is
an append-mostly list of independent lines, so there is no side that wins and no judgment call —
which makes it the one conflict in the workflow an agent may resolve without asking.

**The mechanism:** `land-bundle.sh` applies the rule in the merge that hits it. On a conflicted
merge it takes the three stages git already has for that one path, unions them with
`git merge-file --union`, stages it, and commits — but only if nothing else is left unmerged. Any
other conflicted path still stops and goes to the human.

## Rejected

- **`work/backlog.md merge=union` in `.gitattributes`.** Buys the same outcome and was verified
  working, but a workflow installed into someone else's repository does not get to change how their
  merges behave — for every person and tool, for a file most of them never touch, to fix a conflict
  only this workflow creates. Scoping the fix to the merge that needs it costs a helper function.
- **Offering it at `setup` as an opt-in.** Better, but it puts a question to the repository owner
  that the workflow can answer for itself, and leaves two code paths to keep correct.
- **`$GIT_DIR/info/attributes`.** Untracked and per-clone, so it imposes nothing on the repository —
  but it is invisible state that silently changes every merge in that clone, and it has to be
  installed somewhere before it can help.
- **Policy — only the bundle session writes the backlog.** Unexecutable. The Critic and Reviewer have
  no `Write` tool and so cannot be the writer, and `shape`'s boundary deliberately permits the file.
- **One file per entry** (`work/backlog/<slug>.md`). No shared surface, so no conflict ever — but it
  changes the artifact format, the `backlog` skill, and the write boundary to fix a merge behaviour,
  and it trades a readable list for a directory listing.

## Costs

- **Only Land's merges auto-resolve.** A Shape session that hits the conflict on `git pull` applies
  the rule by hand. That is the right split — the rule is the contract and the script is a
  convenience — but it means the rule has to stay written down, not just implemented.
- Union keeps both versions when two branches edit **the same existing line**, rather than
  conflicting. Measured. That leaves a visible duplicate in a list a human reads, never a lost entry.
- The helper reaches into merge stages, which is lower-level than the rest of these scripts.
