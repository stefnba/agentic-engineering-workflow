---
question: "How do Claude Code and Codex find project skills when a session starts inside a git worktree, or moves into one during the session?"
researched: "2026-11-28"
versions: "Claude Code 2.1.332; Codex 0.172.0 (rust-v0.172.0)"
---

# Project skills in git worktrees in Claude Code and Codex

## Answer

The two harnesses read different folders and draw the worktree boundary in different ways:

| Behavior                                   | Claude Code 2.1.332                                                                          | Codex 0.172.0                                                                       |
| ------------------------------------------ | -------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| Project skill folder                       | `.claude/skills/` only; `.agents/skills/` is not read                                        | `.agents/skills/`, plus `.codex/skills/` beside a project `.codex/config.toml`      |
| Upward scan stops at                       | The worktree root                                                                            | The nearest `.git` entry, file or folder, which is the worktree root                |
| Main checkout's skills in a CLI session    | Only when the worktree has no `.claude/skills` at its root (v2.1.277 or later)               | Never; the code has no main-checkout lookup                                         |
| Desktop app or Codex app worktree session  | The main checkout's skills, even when the worktree has its own                               | Not established; the app is closed source                                           |
| Move during the session                    | `/cd` applies the new folder's skills; after `EnterWorktree`, skills stay at the launch checkout (open report) | Each turn's working directory decides; a new one rebuilds the skill list |
| Symlinked skill folder                     | Followed, loaded once per target                                                             | Followed, deduplicated by canonical path                                            |
| Symlinked `SKILL.md` file                  | Undocumented                                                                                 | Skipped without a warning, by design                                                |
| Broken skill link                          | Undocumented                                                                                 | One warning; only that skill drops                                                  |

- **Evidence strength.** The Claude Code column rests on undated docs fetched 2026-11-28, the changelog and user issue reports; Claude Code is closed source. The Codex column rests on code and tests at tag `rust-v0.172.0`, plus undated docs. Neither harness was run.
- **Where the sources disagree.** For Claude Code, the docs say `EnterWorktree` takes "project configuration such as `CLAUDE.md` and settings" along; open issue #112412 (2026-11-26, 2.1.332) says skills stay at the launch checkout. For Codex, the docs call the stop point "the topmost root folder"; the code stops at the nearest `.git`. Codex app issue #47736 (closed as completed 2026-09-25) says a task that moved into a worktree kept following the skill loaded from the original checkout; the code reloads skills per turn's working directory.
- **Known open problems.** Claude Code: #112412 and #102589 (worktree-branch skills unused after `EnterWorktree`), #99145 and #99012 (desktop reads the main checkout), #99799 (`.worktreeinclude` skips symlinks) and #31005 (no `.agents/skills/`). Codex: #60668 (app lists a worktree skill twice), #18981 (hand-off skips setup that links skills), #33789 (hand-off leaves untracked `.agents/skills/` files behind), #34352 (after "Continue in worktree" the agent's working directory stays at the original checkout) and #30795 (watcher follows symlinks into large trees). Most closed Claude Code worktree reports were closed by an inactivity bot, not fixed.
- Inferred: with `.agents/skills/<name>` → `../../skills/<name>`, Codex in a linked worktree loads that worktree's own `skills/<name>`. Claude Code loads none of those skills unless `.claude/skills/` exposes them. This rests on the findings under the Claude Code, Codex and symlink sections below.

Sources: Claude Code and Codex docs, the Claude Code changelog, Codex source at `rust-v0.172.0`, and both issue trackers, all read 2026-11-28; see Method.

## Claude Code: where project-skill discovery looks in a worktree

Discovery folders and bounds:

- Project skills live at `.claude/skills/<skill-name>/SKILL.md`; the location table lists no `.agents/skills/` ([Claude Code docs, Skills, fetched 2026-11-28](https://code.claude.com/docs/en/skills.md)).
- The AGENTS.md support skips `.agents/`: "**Not read**: … anything under a `.agents/` directory" ([Claude Code docs, Memory, fetched 2026-11-28](https://code.claude.com/docs/en/memory.md)).
- No changelog line up to 2.1.332 mentions `.agents/` (tested 2026-11-28: `grep -n -i "\.agents\|agents/skills" CHANGELOG.md` on the file from `gh api --method GET repos/anthropics/claude-code/contents/CHANGELOG.md`).
- The scan starts in the launch folder and reads "every parent directory up to the repository root" ([Skills docs](https://code.claude.com/docs/en/skills.md)).
- In a linked worktree, "Claude Code searches parent directories only up to the worktree root" ([Skills docs](https://code.claude.com/docs/en/skills.md)).

Read-through to the main checkout:

- When the worktree has no `.claude/skills` at its root, "Claude Code loads the main checkout's project skills in the worktree session. In a worktree with its own `.claude/skills` directory, only that copy loads." This needs v2.1.277 or later ([Claude Code docs, Worktrees, "What worktrees share with the main checkout", fetched 2026-11-28](https://code.claude.com/docs/en/worktrees.md)).
- The rule applies "whether you create the worktree with `--worktree` or with `git worktree add`" ([Worktrees docs](https://code.claude.com/docs/en/worktrees.md)).
- The changelog shows the fallback changing over time ([CHANGELOG.md](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)):
  - 2.1.47: main-repository `.claude/skills/` "are now included" in worktree sessions.
  - 2.1.78: "Fixed `--worktree` flag not loading skills and hooks from the worktree directory".
  - 2.1.277: "Fixed project skills from the main repository not loading in `--worktree` sessions when `.claude/skills` is untracked".
- A maintainer (bcherny) on 2.1.233 said committed `.claude/` content "shows up there automatically", and untracked content is meant to be read from the main repository ([anthropics/claude-code#28041, comment 2026-08-19](https://github.com/anthropics/claude-code/issues/28041)).

Desktop app worktree sessions:

- "In a worktree session you start from the desktop app, Claude Code reads project configuration such as settings, hooks, skills, agents, commands, and `.mcp.json` servers from the main checkout's root." `CLAUDE.md` and `.claude/rules/` still load from the worktree ([Worktrees docs](https://code.claude.com/docs/en/worktrees.md)).
- Since about 2026-09-30, the desktop app passes the undocumented flag `--project-config-root <main checkout>` to every worktree session ([anthropics/claude-code#99012, open, 2026-10-02, 2.1.284](https://github.com/anthropics/claude-code/issues/99012)).
- The flag appears in none of the docs pages read nor the changelog (tested 2026-11-28: `grep -n -i "project-config-root"` on CHANGELOG.md, desktop.md, cli-reference.md, settings-reference.md and worktrees.md).
- A desktop session "lists and loads every skill from the main checkout", while `CLAUDE.md` comes from the worktree ([anthropics/claude-code#99145, open, 2026-10-03, 2.1.286](https://github.com/anthropics/claude-code/issues/99145)).
- Another report says the session lists both checkouts' skills, and the main checkout's copy wins. It dates the change to an app update on 2026-10-07 ([anthropics/claude-code#100497, closed by reporter with a workaround 2026-11-25, 2.1.293](https://github.com/anthropics/claude-code/issues/100497)).
- A desktop session launched inside a worktree whose `.claude/skills` is "a committed symlink to `../docs/skills`" got the main checkout's skills ([anthropics/claude-code#102589, comment 2026-11-26, bundled CLI 2.1.309](https://github.com/anthropics/claude-code/issues/102589)).

Moving during a session:

- `/cd` on v2.1.246 or later applies "the new directory's project configuration: … its skills" ([Claude Code docs, Permissions, "Move the session to another directory", fetched 2026-11-28](https://code.claude.com/docs/en/permissions.md)).
- The Skills page words it as "adds the new directory's project skills", which does not say whether the old folder's skills drop ([Skills docs](https://code.claude.com/docs/en/skills.md)).
- For `EnterWorktree`, the docs say "the move takes the session's working directory, write access, and project configuration such as `CLAUDE.md` and settings"; skills are not named ([Worktrees docs](https://code.claude.com/docs/en/worktrees.md)).
- After `EnterWorktree`, `.claude/skills/*` use the "root copy (Base directory points at root)". After a resume inside the worktree, skills are "not re-invoked; no new skill list injected" ([anthropics/claude-code#112412, open, 2026-11-26, 2.1.332](https://github.com/anthropics/claude-code/issues/112412)).
- `ExitWorktree` "Exits a worktree session and returns to the original directory"; no docs page says what it does to the skill list ([Claude Code docs, Tools reference, fetched 2026-11-28](https://code.claude.com/docs/en/tools-reference)).
- Changelog 2.1.321 fixed project skills "disappearing from the menu in SDK and desktop sessions after Claude entered a worktree" ([CHANGELOG.md](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)). Menu presence and which copy loads may be separate questions.

## Codex: where project-skill discovery looks in a worktree

Code at `rust-v0.172.0` (shallow clone, read 2026-11-28; paths under `codex-rs/`):

- The default project-root marker list is `.git` alone ([config/src/project_root_markers.rs](https://github.com/openai/codex/blob/rust-v0.172.0/codex-rs/config/src/project_root_markers.rs)).
- `find_project_root` probes `<ancestor>/.git` nearest first and returns on the first probe that succeeds, whatever the entry type; it never calls git ([ext/skills/src/host_roots.rs](https://github.com/openai/codex/blob/rust-v0.172.0/codex-rs/ext/skills/src/host_roots.rs)).
- The test `repo_ancestry_stops_at_project_root_and_preserves_root_to_cwd_order` uses a `.git` *file* holding `gitdir: fake`. It asserts that `outer/.agents/skills` above it is not returned ([ext/skills/src/host_roots_tests.rs](https://github.com/openai/codex/blob/rust-v0.172.0/codex-rs/ext/skills/src/host_roots_tests.rs)).
- Candidates are `<dir>/.agents/skills` for each folder from the working directory up to the root; only folders become roots ([host_roots.rs](https://github.com/openai/codex/blob/rust-v0.172.0/codex-rs/ext/skills/src/host_roots.rs)).
- With no marker found, only `<cwd>/.agents/skills` is scanned (test `repo_ancestry_without_project_marker_does_not_walk_parents`, [ext/skills/src/host_roots_tests.rs](https://github.com/openai/codex/blob/rust-v0.172.0/codex-rs/ext/skills/src/host_roots_tests.rs)).
- Each project config layer adds `<.codex folder>/skills` as a second repo-scope root ([host_roots.rs](https://github.com/openai/codex/blob/rust-v0.172.0/codex-rs/ext/skills/src/host_roots.rs)).
- `project_root_markers` can be changed in `config.toml`, but not from the project's own config layer ([host_roots.rs](https://github.com/openai/codex/blob/rust-v0.172.0/codex-rs/ext/skills/src/host_roots.rs)).
- Inferred: a linked worktree's `.git` file ends the walk at the worktree root, so the main checkout's `.agents/skills` is never reached. This holds even for a worktree nested inside the main checkout. It rests on the `find_project_root` and `.git`-file test findings.

Docs, undated, fetched 2026-11-28 ([Codex docs, Agent Skills](https://developers.openai.com/codex/skills.md); the URL answers 308 to [learn.chatgpt.com/docs/build-skills](https://learn.chatgpt.com/docs/build-skills)):

- "Codex scans `.agents/skills` in every directory from your current working directory up to the repository root."
- The location table calls `$REPO_ROOT` "The topmost root folder when you launch Codex inside a Git repository". The code stops at the nearest marker instead.

Which working directory feeds the loader:

- `skills_load_input_for_environments` uses the cwd of the turn's primary environment, else `config.cwd` ([core/src/skills.rs](https://github.com/openai/codex/blob/rust-v0.172.0/codex-rs/core/src/skills.rs)).
- It runs when each turn context is built ([core/src/session/turn_context.rs](https://github.com/openai/codex/blob/rust-v0.172.0/codex-rs/core/src/session/turn_context.rs)).
- `host_skills_for_step` reuses the cached snapshot only while the cwd and filesystem key are unchanged; otherwise it rebuilds ([core/src/skills.rs](https://github.com/openai/codex/blob/rust-v0.172.0/codex-rs/core/src/skills.rs)).
- The app-server `turn/start` request can "Override the working directory for this turn and subsequent turns" ([app-server-protocol/src/protocol/v2/turn.rs](https://github.com/openai/codex/blob/rust-v0.172.0/codex-rs/app-server-protocol/src/protocol/v2/turn.rs)).
- Inferred: a thread whose cwd moves into a worktree between turns gets that worktree's repo skills on the next turn. User, admin, system and plugin roots stay the same. This rests on the three findings above.

Worktree creation and hand-off:

- The `codex-worktree` crate returns a thread cwd equal to the new worktree root joined with the source cwd's path inside its repository ([worktree/src/lib.rs](https://github.com/openai/codex/blob/rust-v0.172.0/codex-rs/worktree/src/lib.rs)).
- Only `codex exec` (a global `--worktree` flag) and the TUI use that crate; no app-server crate does (tested 2026-11-28: `git grep -l "codex-worktree\|codex_worktree" HEAD -- 'codex-rs/*Cargo.toml'`).
- CLI worktrees became experimental in rust-v0.154.0 (2026-09-09) and on by default in rust-v0.156.0 (2026-09-22) ([Codex releases](https://github.com/openai/codex/releases)).
- In the app, "Handing off to or from Local moves your chat _and_ code so you can continue in the other checkout" ([Codex docs, app/worktrees.md, fetched 2026-11-28](https://developers.openai.com/codex/app/worktrees.md)). The docs do not say whether the thread's cwd changes.
- The app copies ignored `.worktreeinclude` paths into managed worktrees but "skips source symlinks". This applies only to app-managed local worktrees ([app/worktrees.md](https://developers.openai.com/codex/app/worktrees.md)).
- The IDE extension page gave nothing on how the extension picks the cwd (searched for "workspace", "cwd" and "working dir", [Codex docs, ide.md, fetched 2026-11-28](https://developers.openai.com/codex/ide.md)).

## Symlinked skill folders and SKILL.md files

Claude Code:

- "a `<skill-name>` entry in the enterprise, personal, or project location can be a symlink to a directory elsewhere on disk. Claude Code reads `SKILL.md` from the target and loads the skill once even if several locations point at the same target" ([Skills docs](https://code.claude.com/docs/en/skills.md)).
- No source covers a symlinked `SKILL.md` file inside a real folder (Skills page and changelog searched).
- Claude Code "refuses to create a worktree when `.claude`, `.claude/worktrees`, or the worktree directory itself is a symlink" ([Worktrees docs](https://code.claude.com/docs/en/worktrees.md)).
- Changelog 2.1.178 fixed the Linux sandbox failing to start "when `.claude/skills` or `.claude/hooks` is a symlink" ([CHANGELOG.md](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)). The report behind it was in a `--worktree` session ([anthropics/claude-code#44567](https://github.com/anthropics/claude-code/issues/44567)).

Codex, code at `rust-v0.172.0` (paths under `codex-rs/`):

- Repo, user and admin scopes follow directory symlinks; system scope ignores them ([ext/skills/src/loader/host.rs](https://github.com/openai/codex/blob/rust-v0.172.0/codex-rs/ext/skills/src/loader/host.rs)).
- Skills are deduplicated by canonical `SKILL.md` path, keeping the first discovery path (`loader/host_merge.rs`; test `deduplicated_symlinked_skill_preserves_first_discovery_path`).
- Symlinks to non-folders are dropped from the walk ([exec-server/src/local_file_system.rs](https://github.com/openai/codex/blob/rust-v0.172.0/codex-rs/exec-server/src/local_file_system.rs)). The test `ignores_symlinked_skill_files_and_directory_cycles` confirms a symlinked `SKILL.md` is not found (`ext/skills/src/loader/discovery_tests.rs`).
- A broken link fails its metadata call and becomes a walk error ([local_file_system.rs](https://github.com/openai/codex/blob/rust-v0.172.0/codex-rs/exec-server/src/local_file_system.rs)). Discovery reports it as "failed to scan skill path …" and keeps the other skills ([ext/skills/src/loader/discovery.rs](https://github.com/openai/codex/blob/rust-v0.172.0/codex-rs/ext/skills/src/loader/discovery.rs)).
- A link cycle is cut by a set of visited canonical folders, and the depth cap is 6 (`local_file_system.rs`; `MAX_SCAN_DEPTH` in `ext/skills/src/loader/mod.rs`).
- A broken `.agents/skills` root is skipped without a warning, because the root probe gets NotFound ([host_roots.rs](https://github.com/openai/codex/blob/rust-v0.172.0/codex-rs/ext/skills/src/host_roots.rs)).
- The docs say "Codex supports symlinked skill folders and follows the symlink target when scanning these locations" ([Codex docs, Agent Skills](https://developers.openai.com/codex/skills.md)).

Relative links in a worktree:

- Git stores a symlink as its link text. With `core.symlinks` false, "symbolic links are checked out as small plain files that contain the link text" (tested 2026-11-28: `git help -m config`, git 2.52.0).
- `git help -m worktree` has no passage on symlinks (tested 2026-11-28, git 2.52.0, `grep -i symlink`).
- Inferred: `.agents/skills/<name>` → `../../skills/<name>` resolves from the link's own folder, so in a linked worktree it reaches that worktree's `skills/<name>`. No source tests this. It rests on the git finding and Codex's directory-link policy.
- Inferred: where `core.symlinks` is false, the link is a plain file, so neither harness finds a `SKILL.md` through it. This rests on the git config finding.
- Inferred: in a Claude Code CLI session using the main-checkout read-through, links resolve inside the main checkout, so the main checkout's versions load. This rests on the read-through finding under the Claude Code section.

## Reported problems in the issue trackers

Searched 2026-11-28 with `gh search issues --repo <repo> --sort created` and opened with `gh issue view`.

`anthropics/claude-code`, worktrees:

| Issue                                                                 | Problem                                                                              | State, version                                                       |
| --------------------------------------------------------------------- | ------------------------------------------------------------------------------------ | -------------------------------------------------------------------- |
| [#112412](https://github.com/anthropics/claude-code/issues/112412)    | After `EnterWorktree`, skills, commands and settings stay at the launch checkout     | Open, opened 2026-11-26, 2.1.332, no reply                           |
| [#102589](https://github.com/anthropics/claude-code/issues/102589)    | After `EnterWorktree`, a skill committed only in the worktree is "Unknown skill"     | Open, 2.1.296, re-tested on 2.1.302 "unchanged"                      |
| [#99275](https://github.com/anthropics/claude-code/issues/99275)      | After `EnterWorktree(path)`, the worktree's root `CLAUDE.md` never loads             | Open, 2.1.288; #112412 says it still reproduces on 2.1.332           |
| [#88931](https://github.com/anthropics/claude-code/issues/88931)      | Skill registry stays rooted at the launch checkout after `EnterWorktree`             | Closed by stale bot 2026-10-15, 2.1.241                              |
| [#47503](https://github.com/anthropics/claude-code/issues/47503)      | Only the main repository's `.claude/skills/` found; the worktree's is ignored        | Closed by stale bot 2026-06-19, from 2.1.104                         |
| [#27985](https://github.com/anthropics/claude-code/issues/27985)      | Skills always load from the main working tree                                        | Closed by stale bot 2026-04-01, 2.1.50                               |
| [#27069](https://github.com/anthropics/claude-code/issues/27069)      | Skills and commands duplicated in worktrees                                          | Closed completed; maintainer: fixed in 2.1.69                        |

`anthropics/claude-code`, symlinks and `.agents/skills/`:

- #109687: a symlinked `~/.claude/skills` loads every skill twice once a file under the target is touched. Open, 2.1.322, reproduced on 2.1.325 ([anthropics/claude-code#109687](https://github.com/anthropics/claude-code/issues/109687)).
- #72631: the VS Code palette does not index a newly added `.claude/skills/<name>` → `.agents/skills/<name>` link until a window reload. Closed by stale bot 2026-09-06 ([anthropics/claude-code#72631](https://github.com/anthropics/claude-code/issues/72631)).
- #31005 asks for `.agents/skills/` support; open, last comment 2026-11-27 ([anthropics/claude-code#31005](https://github.com/anthropics/claude-code/issues/31005)).
- #107421, a request to load `<project>/.agents/skills/` on 2.1.318, was closed as its duplicate on 2026-11-20 ([anthropics/claude-code#107421](https://github.com/anthropics/claude-code/issues/107421)).
- #16345 says "Claude Code silently ignores it, no warning" (comment 2026-10-20, [anthropics/claude-code#16345](https://github.com/anthropics/claude-code/issues/16345)).

`openai/codex`:

- Symlinked `SKILL.md` files are not supported. A maintainer (etraut-openai) said "We do support symlinks for the folder that contains the SKILL.md files" ([openai/codex#10470, 2026-02-03, 0.94.0](https://github.com/openai/codex/issues/10470)). On #15756 the same maintainer added "This is by design. The packaging boundary of a skill is its directory" ([openai/codex#15756, 2026-03-25, 0.116.0](https://github.com/openai/codex/issues/15756)).
- A user test on codex-cli 0.165.0 (2026-10-29, `codex --no-daemon debug prompt-input probe`) listed skills behind a symlinked `.agents`, `skills` or skill folder, and a hard-linked `SKILL.md`. It did not list a symlinked `SKILL.md` ("The omission was silent") ([openai/codex#10470](https://github.com/openai/codex/issues/10470)).
- A maintainer verified on 0.98 that a symlinked per-project `.agents/skills` works. The reporter's own link was invalid ([openai/codex#11314, closed 2026-02-14](https://github.com/openai/codex/issues/11314)).
- #60668: in a Codex-managed worktree chat, the `$` picker lists a skill tracked once under `.agents/skills/` twice. Open, Codex App 26.1103.60933, no comments ([openai/codex#60668, 2026-11-10](https://github.com/openai/codex/issues/60668)).
- #18981: a hand-off to a new worktree skips the local environment. Project skills that a setup script would link "can silently disappear". Open; comment on app 26.911.61220, 2026-09-18 ([openai/codex#18981](https://github.com/openai/codex/issues/18981)).
- #30795: the skill watcher follows directory symlinks into huge external trees. Open, 2026-07-01 ([openai/codex#30795](https://github.com/openai/codex/issues/30795)).
- On live updates the sources split. A maintainer said "Live updates won't work with a symlink" (#11314, 2026-02, 0.98). #30795 (2026-07) says the watcher "follows directory symlinks by default". The later report is newer.
- No Codex issue reports the CLI reading skills from the main checkout instead of the worktree (queries "worktree skill", "skills worktree", "skills not found worktree", "skills linked worktree", "handoff skills", rerun 2026-11-28). The query "worktree .agents" found three app reports:
  - #47736: a Codex app task that moved into a linked worktree kept following the `.agents/skills/` skill loaded from the original checkout, though the worktree held a newer copy. Closed as completed 2026-09-25 with no comment; app 26.915.31945, CLI 0.155.0-alpha.9.2 ([openai/codex#47736](https://github.com/openai/codex/issues/47736)).
  - #33789: a hand-off from a Codex-managed worktree to Local left non-ignored untracked files under `.agents/skills/` in the worktree, with no warning. Open, 2026-07-17, CLI 0.144.5 ([openai/codex#33789](https://github.com/openai/codex/issues/33789)).
  - #34352: after "Continue in worktree", the agent's shell working directory and writable root stay at the original checkout. Open, 2026-07-20, app 26.715.52143 ([openai/codex#34352](https://github.com/openai/codex/issues/34352)).

## Codex 0.172.0 internals: repository root, working directory, hand-off and link handling

The findings for this sub-question sit in the sections on Codex discovery and on symlinks above, so each fact appears once:

- Repository root in a linked worktree: under "Codex: where project-skill discovery looks in a worktree", code at `rust-v0.172.0`.
- Working directory per turn, `codex exec --worktree`, the app's Handoff and the IDE extension: same section, under "Which working directory feeds the loader" and "Worktree creation and hand-off".
- Broken links and link cycles: under "Symlinked skill folders and SKILL.md files".

## Claude Code 2.1.332 worktree configuration: settings, copied files, desktop root, ExitWorktree, IDEs

- The `worktree` settings object holds `baseRef`, `symlinkDirectories`, `sparsePaths` and `bgIsolation`; none names skills ([Claude Code docs, Settings reference, fetched 2026-11-28](https://code.claude.com/docs/en/settings-reference#worktree)).
- The docs advise including `.claude` in `worktree.sparsePaths` "so that each worktree also has the repository's `.claude/settings.json` and `.claude/rules/`" ([Settings reference](https://code.claude.com/docs/en/settings-reference#worktree-sparsepaths)).
- `.worktreeinclude` copies only "files that match a pattern and are also gitignored". Its example `**/.claude/skills/*.md` copies out of an ignored `.claude/` folder on v2.1.239 or later ([Worktrees docs, "Copy gitignored files into worktrees"](https://code.claude.com/docs/en/worktrees#copy-gitignored-files-into-worktrees)).
- `.worktreeinclude` entries that are symlinks are not copied by `claude -w`. A comment says this still happens on 2.1.330 with `.claude/skills/` listed ([anthropics/claude-code#99799, open, comment 2026-11-23](https://github.com/anthropics/claude-code/issues/99799)).
- Inferred: a gitignored `.claude/skills/` copied in by `.worktreeinclude` gives the worktree its own folder. That turns the read-through off, so the copy made at creation loads. This rests on the `.worktreeinclude` and read-through findings.
- Inferred: a `sparsePaths` list without `.claude` leaves no `.claude/skills` in the worktree, so on v2.1.277 or later the main checkout's skills load. This rests on the `sparsePaths` and read-through findings.
- `--project-config-root` and desktop sessions: see "Desktop app worktree sessions" under the Claude Code section.
- `ExitWorktree`: see "Moving during a session" under the Claude Code section. The changelog has fixes for skills after entering a worktree, none for exiting ([CHANGELOG.md](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)).
- VS Code: a reopened conversation that moved into a worktree "resumes in the worktree if Claude Code created the worktree under `.claude/worktrees/`" (v2.1.300 or later). The page states no worktree skill rule ([Claude Code docs, VS Code, fetched 2026-11-28](https://code.claude.com/docs/en/vs-code#reopen-a-conversation-that-moved-into-a-worktree)).
- JetBrains: the page does not mention worktrees (tested 2026-11-28: `curl -sL https://code.claude.com/docs/en/jetbrains.md | grep -i worktree`).

## Issues since 2026-01 that the first search missed

Searched by newest on 2026-11-28 with `gh search issues --repo <repo> --sort created --order desc --created ">=2026-01-01"`. The ones that bear on the Answer are already placed above: #47503, #88931, #99799 and #44567 for Claude Code. The others:

- [anthropics/claude-code#68118](https://github.com/anthropics/claude-code/issues/68118) (2026-06-13, closed as a duplicate): symlinked skill folders under `~/.claude/skills/` work, "Verified on CLI 2.1.53 and 2.1.177, and on the desktop-app harness 2.1.170".
- [anthropics/claude-code#51356](https://github.com/anthropics/claude-code/issues/51356) (2026-04-20, closed as a duplicate of #47503): "New skill files in the worktree are invisible to the skill catalog."
- [openai/codex#9365](https://github.com/openai/codex/issues/9365) (2026-01-16, 0.86.0): a maintainer (xl-openai) said "I removed support for symlinking directly to SKILL.md in my recent PR."
- Codex release notes from rust-v0.98.0 to rust-v0.172.0 have no line with both "skill" and "worktree". Symlinked-skill lines appear in 0.145.0, 0.147.0 (#37144, "Preserve discovery paths for symlinked skills") and 0.149.0 (tested 2026-11-28: `gh api --method GET "repos/openai/codex/releases?per_page=50&page=N"`, grepped).
- rust-v0.149.0 (2026-08-20) has "#39616 Validate linked worktrees before inheriting project trust" ([Codex releases](https://github.com/openai/codex/releases)).

## Open questions

- **Neither harness was run at the versions studied.** Every behavior claim rests on docs, code reading or user reports. The installed CLIs (Claude Code 2.1.247, Codex 0.159.2) are older.
- **No maintainer reply** was found on #112412, #102589, #99275, #99012 or #99145. So no source says whether Claude Code's desktop main-checkout reading or the `EnterWorktree` behavior is intended.
- **Claude Code desktop lists:** the docs say skills come from the main checkout's root; #100497 (desktop 2.26454.2) says both checkouts' skills are listed. Which holds on 2.1.332 is not settled.
- **Claude Code read-through edge cases:** no source says whether a symlinked or dangling `.claude/skills` at the worktree root counts as present. None covers worktrees outside `.claude/worktrees/` beyond "`git worktree add`".
- **Claude Code skill list after `ExitWorktree` or a Bash `cd`:** undocumented; the Skills page's "adds" leaves open whether old skills drop.
- **Codex app and IDE extension cwd:** the app is closed source, and the docs do not say whether Handoff changes a thread's cwd or starts a new thread. #34352 reports the cwd staying at the original checkout after "Continue in worktree", and #47736 reports an app task keeping the original checkout's skill. How the IDE extension picks its cwd was not found.
- **Codex project trust in linked worktrees:** whether repository skills need a trusted project, and what #39616 changed for worktrees, was not checked; the PR was not opened.
- **Search gaps:** the Codex query "symlinked skills directory" was dropped by the GitHub rate limit and not rerun. No separate IDE-extension query ran on either tracker.

## Method

- The user confirmed the brief. Sub-questions 5 to 7 were added after confirmation.
- First round, four researchers: Claude Code discovery (notes 1), Codex discovery from source at `rust-v0.172.0` (notes 2), symlink handling in both harnesses and git (notes 3), and both issue trackers plus changelog and release notes (notes 4).
- Second round, three researchers: Codex internals for root detection, per-turn cwd, worktree crate and link handling (notes 5); Claude Code worktree settings, `--project-config-root`, `ExitWorktree` and IDE pages (notes 6); a newest-first issue sweep since 2026-01 and Codex release notes from 0.98.0 (notes 7).
- Nothing ran in a local worktree. Codex source came from a shallow clone at tag `rust-v0.172.0`, deleted afterwards. Claude Code is closed source, so its loader was not read.
- GitHub search hit rate limits (HTTP 403) during the first round; notes 7 reran the dropped queries except one.
- Checker, 2026-11-28: opened the cited docs pages, changelog lines, issues and Codex code at `rust-v0.172.0`, and the npm and GitHub release pages (Claude Code 2.1.332 and Codex 0.172.0 are the latest; Codex has only 0.174.0 alpha prereleases since). Reran the Codex no-main-checkout searches plus "worktree .agents", which found #47736, #33789 and #34352; added them to the Answer, the issue findings and Open questions. Fixed one test citation to `host_roots_tests.rs`. Not reopened: the symlink-section Codex tests beyond their names, `turn_context.rs`, `turn.rs`, the `codex-worktree` crate, VS Code, JetBrains and settings-reference pages, and issues #44567, #68118, #51356, #9365, #109687, #72631, #107421 and #16345.
