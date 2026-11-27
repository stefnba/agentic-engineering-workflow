# Project skills in git worktrees, in Claude Code and Codex

For a reader who wants facts only: how do Claude Code and Codex find project skills when a session starts inside a git worktree? This note records what the sources show and proposes nothing.

Sources and method: Claude Code 2.1.332, released 2026-11-24 on npm, and Codex CLI 0.172.0, released 2026-11-24. Two research subagents ran on 2026-11-27, one per harness. The Claude Code researcher read the docs at code.claude.com, the changelog and issues in anthropics/claude-code; that repository holds no source code. The Codex researcher read the docs at developers.openai.com and the source of openai/codex at `main` commit `afe555b` (2026-11-27), which is 432 commits ahead of the 0.172.0 tag, so the release may differ. Codex paths are relative to `codex-rs/` at that commit. Neither researcher ran either harness. A checker subagent then reopened the source of every tagged claim and reported 15 failures and flags, which were applied: three claims rewritten to what the source says, tags corrected, and sources added to the Summary.

Tags:

- `[read]`: seen in a file, page or issue.
- `[tested]`: a command was run and its result observed.
- `[reported]`: a source's claim about something else, not observed here.
- `[inferred]`: a conclusion drawn from the claims it names.
- `[unverified]`: a claim whose source could not be reopened in the check.

## Summary

- **Both harnesses walk up from the start directory and stop at the worktree's own root**, so a session started in a linked worktree finds the skills inside that worktree `[inferred]` from the Claude Code skills docs, line 183, and the Codex root-marker code below.
- **Claude Code falls back to the main checkout's skills when the worktree has no `.claude/skills` at its root** (2.1.277 and later) `[read]` worktrees docs, lines 268-272. The Codex sources read show no such fallback `[inferred]` from the Codex sections below.
- **Both follow a symlinked skill folder** `[inferred]` from the Claude Code skills docs, line 172, and the Codex skills docs, line 149. Codex does not discover a `SKILL.md` that is itself a symlink `[read]` `ext/skills/src/loader/discovery_tests.rs:69-101`. Claude Code's docs do not say whether a symlinked `.claude/skills` parent folder is followed `[read]` skills docs.
- **Three of the four open Claude Code worktree issues concern sessions that move into a worktree with EnterWorktree**; the fourth concerns `claude --worktree` `[inferred]` from the open issues below. No Codex issue found reports skills failing to load in a git worktree `[read]` searches listed under Codex.

The table restates the sections below, with their tags:

| Point                           | Claude Code 2.1.332                                  | Codex 0.172.0                                         |
| ------------------------------- | ---------------------------------------------------- | ----------------------------------------------------- |
| Project skills folder           | `.claude/skills/`                                    | `.agents/skills/`                                     |
| Search                          | Start directory and each parent up to the root       | Start directory and each parent up to the root        |
| Root in a linked worktree       | The worktree root                                    | The nearest ancestor with a `.git` entry: the worktree root (inferred) |
| Fallback to the main checkout   | Yes, when the worktree has no `.claude/skills`       | None in the sources read                              |
| Symlinked skill folder          | Followed                                             | Followed, except at system scope                      |

## Claude Code

### Where it looks

- The project location is `.claude/skills/<skill-name>/SKILL.md` `[read]` [skills docs](https://code.claude.com/docs/en/skills.md), lines 162-166, as of 2026-11-27.
- Project skills load from `.claude/skills/` in the start directory and in every parent up to the repository root `[read]` skills docs, line 181.
- A nested `.claude/skills/` below the start directory loads only after Claude reads or edits a file there, or after `/add-dir` (2.1.257 and later) `[read]` skills docs, line 185.
- After `/cd` (2.1.246 and later), the new directory's project skills are added `[read]` skills docs, line 181.
- The shared `.claude/settings.json` is read from the session's primary working directory; `.claude/settings.local.json` is read and written at the repository root `[read]` [settings docs](https://code.claude.com/docs/en/settings.md), lines 85 and 94.
- The skills docs do not mention `.agents/skills/`. Feature request [#16345](https://github.com/anthropics/claude-code/issues/16345) for it was closed as a duplicate on 2026-10-22, and [#31005](https://github.com/anthropics/claude-code/issues/31005) was open as of 2026-11-26 `[read]`.

### Inside a worktree

- In a linked worktree, made with `--worktree` or `git worktree add`, the parent search stops at the worktree root `[read]` skills docs, line 183.
- When the worktree has no `.claude/skills` at its root, for example because it is ignored by git, the main checkout's project skills load (2.1.277 and later). When it has its own, only that copy loads. `.claude/agents` and `.claude/commands` follow the same rule `[read]` [worktrees docs](https://code.claude.com/docs/en/worktrees.md), lines 268-272.
- Project-scope plugins, and "don't ask again" approvals saved to the main checkout's `settings.local.json`, are shared with the main checkout. The approval rule does not hold on Windows and in a few other cases `[read]` worktrees docs, lines 264-267; settings docs, lines 85-89.
- For worktree sessions started from the desktop app, settings, hooks, skills, agents, commands and `.mcp.json` come from the main checkout's root, and `${CLAUDE_PROJECT_DIR}` points there. `CLAUDE.md` and `.claude/rules/` still load from the worktree `[read]` worktrees docs, line 274.
- Auto memory is shared by all worktrees of a repository; `CLAUDE.local.md` exists only in the worktree that created it `[read]` [memory docs](https://code.claude.com/docs/en/memory.md), lines 127 and 516.

Worktree changes in the changelog `[read]` [CHANGELOG.md](https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md):

| Version  | Change                                                                      |
| -------- | --------------------------------------------------------------------------- |
| 2.1.47   | Main-repo `.claude/agents/` and `.claude/skills/` included from a worktree   |
| 2.1.63   | Project configs shared across worktrees                                     |
| 2.1.69   | Fixed duplicate `CLAUDE.md`, slash commands, agents and rules in nested worktrees |
| 2.1.78   | Fixed `--worktree` not loading skills and hooks from the worktree           |
| 2.1.277  | Fixed untracked main-repo skills not loading under `--worktree`             |
| 2.1.321  | Fixed skills vanishing after entering a worktree in SDK and desktop sessions |
| 2.1.332  | Fixed `CLAUDE.md` being sent twice after EnterWorktree                       |

### Symbolic links

- A `<skill-name>` entry can be a symlink to a directory. Claude Code reads `SKILL.md` from the target and loads it once even when several locations point at it `[read]` skills docs, line 172.
- The docs do not say whether a symlinked `.claude/skills` parent is supported. In the changelog, 2.1.178 fixed the Linux sandbox failing when `.claude/skills` is a symlink. 2.0.62 fixed skill files inside symlinked skill directories becoming circular symlinks `[read]` CHANGELOG.md.
- Plugin skills handle symlinks differently `[read]` skills docs, line 172. Since 2.1.257, symlinked plugin skill paths are refused `[read]` CHANGELOG.md.
- Issues about a symlinked user-level `~/.claude/skills` `[read]`:
  - [#38051](https://github.com/anthropics/claude-code/issues/38051): skills not loaded. Closed as completed on 2026-03-24.
  - [#109687](https://github.com/anthropics/claude-code/issues/109687): every skill loads twice once a file under the target is touched. Open as of 2026-11-13.
  - [#72631](https://github.com/anthropics/claude-code/issues/72631): the IDE palette does not index new symlinked skills. Closed as not planned.

### Reported worktree issues, as of 2026-11-27

Closed as completed `[read]`:

- [#25816](https://github.com/anthropics/claude-code/issues/25816): agents not found from a git worktree. Closed 2026-02-18.
- [#27069](https://github.com/anthropics/claude-code/issues/27069): skills appear twice in worktrees. Closed 2026-08-19.
- [#98052](https://github.com/anthropics/claude-code/issues/98052): worktree-isolated subagents load `CLAUDE.md` twice. Closed 2026-09-29; the 2.1.286 changelog lists a fix for the same symptom.

Open `[read]`:

- [#28041](https://github.com/anthropics/claude-code/issues/28041): `claude --worktree` does not copy `.claude/` subfolders into the worktree.
- [#99275](https://github.com/anthropics/claude-code/issues/99275): `EnterWorktree(path)` never loads the worktree's root `CLAUDE.md`.
- [#102589](https://github.com/anthropics/claude-code/issues/102589): after EnterWorktree, a skill committed on the worktree branch is "Unknown skill" (2.1.296). It replaces #88931, closed as not planned on 2026-10-15.
- [#112412](https://github.com/anthropics/claude-code/issues/112412), opened 2026-11-26: after EnterWorktree, commands, skills and settings keep loading from the launch directory. The reporter says #99275 still reproduces on 2.1.332.

[#35628](https://github.com/anthropics/claude-code/issues/35628), a docs request about how `--worktree` loads skills, was closed as not planned `[read]`.

#99275, #102589 and #112412 concern a session that moves into a worktree with EnterWorktree, and #28041 concerns `claude --worktree`. None reports a problem with a session started by `git worktree add` and then `claude` inside it `[inferred]` from the four issues.

## Codex

### Where it looks

- The docs say Codex scans `.agents/skills` in every directory from the current working directory up to the repository root `[read]` [skills docs](https://developers.openai.com/codex/skills.md), line 138.
- The docs list `$CWD/.agents/skills`, `$CWD/../.agents/skills` and `$REPO_ROOT/.agents/skills`, and call `$REPO_ROOT` "the topmost root folder" `[read]` skills docs, lines 142-144.
- The loader walks up from the cwd, adds `<dir>/.agents/skills` for each ancestor that has it as a directory, and stops at the resolved project root `[read]` `ext/skills/src/host_roots.rs:241-262`.
- `find_project_root` returns the nearest ancestor of the cwd that holds a `project_root_markers` entry. Unset markers fall back to the defaults; an empty list, or no marker found, makes the cwd the root `[read]` `ext/skills/src/host_roots.rs:375, 396-402, 444-448`. The default marker list is `[".git"]` `[read]` `config/src/project_root_markers.rs:5`.
- The docs call the root "the topmost root folder", and the code returns the nearest ancestor with a marker `[inferred]` from the two claims above.
- Codex also adds a `skills` folder inside each project config layer's folder, at repo scope `[read]` `ext/skills/src/host_roots.rs:141-149`. Which directory that config folder is was not checked.
- `AGENTS.md` follows the same root rule: Codex joins the `AGENTS.md` files from the root down to the cwd and never reads above the root `[read]` `core/src/agents_md.rs:1-18`. The docs say the root is "typically the Git root" `[read]` [AGENTS.md guide](https://developers.openai.com/codex/guides/agents-md.md), line 12.

### Inside a worktree

- The marker check counts any successful metadata lookup on `<ancestor>/.git` as a match, so `.git` need not be a directory `[read]` `ext/skills/src/host_roots.rs:411-427`. The lookup follows symlinks `[read]` `file-system/src/lib.rs:90-98`.
- In a `git worktree add` checkout, `.git` is a file at the worktree's top folder, so the project root is that folder and only skills and `AGENTS.md` files inside the worktree are found `[inferred]` from the two claims above. Not tested.
- Codex's own worktree code places each managed worktree at `<worktree root>/<4-char id>/<repository name>` `[read]` `worktree/src/paths.rs:13-37`. These are ordinary git worktrees, so the same rule applies `[inferred]`.

### Symbolic links

- The docs say Codex supports symlinked skill folders and follows the target `[read]` skills docs, line 149.
- Directory symlinks are followed at repo, user and admin scope and ignored at system scope `[read]` `ext/skills/src/loader/host.rs:161-164`; `ext/skills/src/loader/discovery.rs:76-81`.
- The root check tests `.agents/skills` with `is_directory` `[read]` `ext/skills/src/host_roots.rs:256`, and the metadata lookup follows symlinks `[read]` `file-system/src/lib.rs:94-98`. So a symlinked `.agents/skills` that points at a directory counts as a directory `[inferred]`.
- A `SKILL.md` that is itself a symlink is not discovered; a unit test checks this `[read]` `ext/skills/src/loader/discovery_tests.rs:69-101`.

### Reported issues, as of 2026-11-27

- [#11314](https://github.com/openai/codex/issues/11314): skills not loaded from a symlinked `.agents/skills`. Closed as not planned on 2026-02-14; the reporter says the link was invalid and a valid relative link works `[read]`.
- [#22506](https://github.com/openai/codex/issues/22506): symlinked `SKILL.md` files not discovered. Closed as not planned on 2026-05-13 `[read]`.
- [#21185](https://github.com/openai/codex/issues/21185): asks for uncommitted local instructions, such as an `AGENTS.local.md`, in app-created worktrees. Open; one comment says the CLI is affected too `[read]`.
- [#12863](https://github.com/openai/codex/issues/12863): the Codex app fails with "branch name is already used by worktree" for worktrees made with plain `git worktree`. Open, with a report dated 2026-11-02 `[read]`.

## Not settled

- Whether Claude Code follows a symlinked `.claude/skills` parent folder for project skills: neither the docs nor the changelog says so directly.
- Where a CLI session started by `git worktree add`, outside the desktop app, reads `CLAUDE.md` and settings, beyond the lines cited above.
- Claude Code's source is not public, so no Claude Code claim rests on code.
- No Codex issue reports skills or `AGENTS.md` failing inside a git worktree, and the Codex skills and `AGENTS.md` docs do not mention worktrees.
- Where Codex's managed worktree root is, and which folder the project config layer uses.
- The Codex claims rest on `main`, not on the 0.172.0 tag.
- Neither harness was run, so no claim is `[tested]`.
