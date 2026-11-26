# Scripts and deterministic logic in seven reference repositories

For the designer of the version 2 skills: where do the reference projects put code, where prose, and what does the code cost them?

Sources and method: shallow clones of the seven repositories at HEAD, read on 2026-11-26 by a research sub-agent with `git ls-files`, `wc -l`, `grep` and file reads. Issues and pull requests were read through `gh`. Nothing from the clones was executed. Paths are relative to each repository. `[read]` marks a claim seen in a file or issue. `[inferred]` marks a conclusion drawn from what was read. Issue-search counts are full-text hits and overstate the number of bugs.

## Summary

Every repository writes its judgment steps as prose: shaping, implementing and reviewing. Code appears for four jobs only: computing a path or ID, reading state into JSON, guarding a transition, and packaging `[inferred]`.

The seven fall into three groups `[inferred]`:

- **Almost no workflow-time code**: mattpocock/skills and Elephant Goldfish Model (EGM). The agent runs `git` and `gh` from prose and edits state files itself.
- **A few small helpers**: obra/superpowers, about 420 lines of Bash for path, extract, diff and ledger steps, plus one hook and an optional web server.
- **State and validation behind a CLI or a large script set**: spec-kit, OpenSpec, gsd-core and BMAD-METHOD.

The cost of code is consistent across the groups. Tests run one to six times the size of the scripts they cover. Most script fixes are platform bugs, not logic bugs. Hooks are the piece most often removed.

## Comparison

All seven repositories exist at the URLs given in the task. The table counts code that runs inside the agent loop separately from code that only maintainers run.

| Repository | Workflow-time code | Lines at workflow time | Maintainer-only code | State written by | Script tests | Maintenance evidence |
| --- | --- | --- | --- | --- | --- | --- |
| mattpocock/skills | Two Bash templates the agent copies | 267 | 156 lines of scripts, 4 small CI workflows | Agent, through tracker commands or a `Status:` line | None | 22 issues titled "wizard" for one 223-line template |
| google/elephant-goldfish-model | None | 0 | About 2,200 lines of Python, 9 CI workflows | Agent, in a checklist file | 5,816 lines, all for packaging and CI | Its one hook was added and removed within three pull requests |
| obra/superpowers | 6 Bash helpers, a session-start hook with a Windows shim, a brainstorm server | About 1,890 | About 1,380 lines of Bash for packaging | Ledger file; the agent appends, or a script appends after tests pass | 11,208 lines | Platform fixes in nearly every release |
| github/spec-kit | 6 scripts in each of 3 languages, plus git extension scripts | 5,515, plus 3,045 for the git extension | 85,292-line CLI, 29 workflow files | Agent ticks checkboxes; numbering in prose | Parity tests inside a 210,102-line suite | 37 `fix(scripts)` changelog entries; a numbering race |
| Fission-AI/OpenSpec | The `openspec` CLI, called from every skill | 57,787 (TypeScript) | Generation and parity-hash scripts | Agent edits checkboxes; the CLI reads them back | 101,341 lines | Needs Node 22 and a global install |
| open-gsd/gsd-core | The `gsd-tools` CLI and about 31 hooks | 45,327 plus 16,387 for hooks | 81,408 lines of checks and release tooling | Code, through state verbs | 805,031 lines | 7 releases in 5 weeks; open state bugs |
| bmad-code-org/BMAD-METHOD | 43 Python scripts run with `uv` | 19,027 | Validators, CI on two operating systems | A ticket script; status lives in plan files | 19,929 lines | `uv` became mandatory; a cluster of Windows issues |

All counts are `[read]` from `wc -l`, except the superpowers total, which is a sum of counted files that leaves out an HTML template and an authoring aid.

## Per-repository notes

### mattpocock/skills

Commit `6f7f783` (2026-11-25).

- **No skill calls a script to do a workflow step.** A `grep` for `scripts/` under `skills/` finds three files: two templates and one optional hook `[read]`.
- **The two templates exist where a human must act at a terminal.** `skills/engineering/wizard/template.sh` (223 lines) and `skills/engineering/diagnosing-bugs/scripts/hitl-loop.template.sh` (44 lines) are copied and extended by the agent `[read]`.
- **The one hook stays out of the plugin.** `skills/misc/git-guardrails-claude-code/scripts/block-dangerous-git.sh` (25 lines) sits in a frozen bucket `[read: AGENTS.md bucket rules]`.
- **Workflow steps are prose.** `skills/engineering/implement/SKILL.md` is 13 lines. `skills/engineering/implement-spec/SKILL.md` runs worktrees, merges and a draft pull request with no command literals `[read]`.
- **Tracker commands live in one reference file per tracker.** `skills/engineering/setup-matt-pocock-skills/issue-tracker-github.md:7-15` lists the `gh` commands. The setup skill copies that file into the consuming repository `[read]`.
- **The claim is the tracker assignee.** `gh issue edit <n> --add-assignee @me` is described as the session's first write `[read: issue-tracker-github.md:49]`.
- **With local files, the agent edits a `Status:` line and picks the next number.** `[read: issue-tracker-local.md:9-10,26-30]`
- **The small template still attracts bugs.** 22 issues carry "wizard" in the title, for example #1483 (macOS `tput`), #1260 (Bash 3.2 quoting) and #963 (Windows Git Bash) `[read]`.
- **Determinism belongs in the consuming repository's own tooling.** `skills/engineering/retro/SKILL.md:19` sends a mechanical violation to the repository's linter or pre-commit, not to a prompt rule `[read]`.
- **A request for a deterministic lint step was closed** because it came from reading, not from an observed failure (#1372) `[read]`.
- **A separate verify mode for setup was rejected** because a second code path would drift `[read: .out-of-scope/setup-skill-verify-mode.md]`.

Not found: plugin hooks, a CLI, state files, script tests. Not read: three of the four workflow bodies, most of `docs/`, `skills/in-progress/software-factory`.

### google/elephant-goldfish-model

Commit `4693375` (2026-11-25). Its scope is design documents plus a lite mode that also implements.

- **No workflow-time code exists.** The files under `skills/` are Markdown, YAML, SVG and one JSON schema, and none contains a fenced shell block `[read]`.
- **All Python is packaging, release, CI or a pull-request bot.** `scripts/pack_plugin.py` (143 lines), `scripts/prepare_release.py` (99), `.github/scripts/review_pr.py` (1,806) `[read]`.
- **The state machine is prose.** `skills/egm-lite/SKILL.md:27-72` lists allowed and banned transitions `[read]`.
- **Status lives in a checklist file the agent edits.** `egm_lite_checklist.md` holds checkboxes and a `Spec Review Status:` line `[read: skills/egm-lite/SKILL.md:157,378]`.
- **The only commands named in skills are three `git` reads.** `git config user.name`, `git diff <starting-commit>` and `git ls-files --others --exclude-standard` `[read: skills/egm-draft/SKILL.md:165, skills/egm-lite/SKILL.md:304-305]`.
- **Tests target the prose.** Eight `test_scenarios.yaml` files (1,523 lines) assert on model output with regular expressions `[read: skills/egm-review/test_scenarios.yaml:15-40]`.
- **Its one hook did not last.** A Claude `PreToolUse` hook arrived in pull request #113, needed a Windows path fix (#173), and left in #136 `[read]`.
- **A pre-commit hook for release output was rejected** because CI must catch the same thing `[read: docs/designs/claude_release_branch_distribution.md:282-288]`.

Not found: IDs, numbering, claims, a changelog file. Not read: the bot's body, most design documents. Not found: the runner for the scenario files; an external one is `[inferred]`.

### obra/superpowers

Commit `22f0b46` (2026-11-03).

- **Six Bash helpers do path, extract, diff and ledger work.** They total 423 lines under `skills/subagent-driven-development/scripts/` and `skills/executing-plans/scripts/` `[read]`.
- **The stated reason is token cost and compaction loss, not correctness.** Pasted diffs and task text sit in the most expensive context, so they move as files `[read: RELEASE-NOTES.md:362]`.
- **One helper is a gate.** `skills/executing-plans/scripts/task-done` runs the test command and appends a ledger line only on exit 0 `[read]`.
- **Skills call helpers through the interpreter.** `bash scripts/sdd-workspace PLAN_FILE` `[read: skills/subagent-driven-development/SKILL.md:113-115]`. The reason given is that some packagers strip executable bits `[read: skills/writing-skills/SKILL.md:161]`.
- **No skill names `CLAUDE_PLUGIN_ROOT`.** The variable appears only in hooks, documents and tests `[read: git grep]`.
- **Finishing a branch is prose with commands.** `git merge`, `git push -u` and `git worktree remove` are written out in `skills/finishing-a-development-branch/SKILL.md:94-116` `[read]`.
- **State is a git-ignored ledger.** `.superpowers/sdd/<plan>/progress.md` exists because controllers re-dispatched finished tasks after compaction `[read: skills/subagent-driven-development/SKILL.md:108-126]`.
- **Tests are six times the workflow code.** 11,208 lines against about 1,890. One 110-line script has an 838-line test file `[read: tests/claude-code/test-sdd-workspace.sh]`.
- **Script fixes recur release after release.** `RELEASE-NOTES.md` lists fixes for ID parsing, a `.gitignore` overwrite, Windows path forms, and the Windows hook shim `[read: lines 22, 41, 47-48, 114-121, 192, 259, 319]`.
- **The Codex session-start hook was deleted** once Codex found skills natively `[read: RELEASE-NOTES.md:291]`.

Not found: Bash and PowerShell twins. Not read: the server body, packaging script bodies, test bodies, the external eval repository named in `AGENTS.md:110`.

### github/spec-kit

Commit `f201054` (2026-11-25).

- **The same six scripts exist three times.** Bash 1,965 lines, PowerShell 1,647, Python 1,903 `[read]`. Each command template names all three and says to run `{SCRIPT}` `[read: templates/commands/plan.md:12-14,62]`.
- **Scripts return paths and templates; the rest is prose.** `check-prerequisites` resolves the feature directory as JSON, and `setup-plan` copies the plan template `[read: templates/commands/analyze.md:66]`.
- **Feature numbering moved into prose.** The agent scans `specs/`, computes the next prefix and runs `mkdir -p` `[read: templates/commands/specify.md:68-100]`.
- **A 505-line script still ships uncalled.** No file under `templates/` names `create-new-feature` `[read: git grep]`. An installed integration may still call it; that was not checked.
- **The implement loop is prose, including ticking tasks.** `[read: templates/commands/implement.md:150-169]`
- **Concurrent numbering is an open bug.** Two runs can pick the same number and overwrite a spec (#4270) `[read]`.
- **Twin drift is a named problem.** Issue #3277 proposes one Python script per pair and cites dual maintenance of about 4,500 lines `[read]`.
- **Parity fixes are a changelog category.** 8 of 37 `fix(scripts)` entries say "parity with" the other twin `[read: CHANGELOG.md:750,1610-1662]`.

Not found: Claude or Codex hooks in the core. Not read: the CLI bodies, the workflow engine, test bodies. Not verified: whether the Bash and PowerShell sets are scheduled for removal.

### Fission-AI/OpenSpec

Commit `f1cd852` (2026-11-24), version 2.2.0.

- **Every skill calls the CLI.** `openspec status --change` appears 38 times across skills, `list --json` 26 and `new change` 25 `[read: git grep]`.
- **The CLI reads and the agent writes.** The agent ticks the checkbox at the path and line the CLI returned, then re-runs the CLI to confirm `[read: skills/openspec-apply-change/SKILL.md:110-112]`.
- **State is derived from files, not stored.** The CLI reports `blocked`, `all_done` and `missingArtifacts` from what exists on disk `[read: skills/openspec-apply-change/SKILL.md:64-69]`.
- **Archiving is done by hand.** The skill has the agent merge specs and run `mv`, although an `openspec archive` command exists `[read: skills/openspec-archive-change/SKILL.md:178,188]`. The reason was not found.
- **The CLI's guidance is a contract, not a check.** `docs/cli.md:930-931` says the guidance fields are not enforceable `[read]`.
- **Skill text lives in TypeScript and is generated.** `src/core/templates` holds 5,299 lines, and parity-hash scripts guard the generated output `[read: listing; purpose inferred from names]`.
- **The skills cannot run without Node 22.20 and a global install.** `[read: package.json engines]`

Not found: hooks, scripts inside skills. Not read: `src/` bodies.

### open-gsd/gsd-core

Commit `a30fe54` (2026-11-26).

- **Code owns state.** `STATE.md` is written through verbs such as `state.advance-plan` and `state.add-blocker` `[read: gsd-core/workflows/execute-plan.md:447-487]`.
- **Code owns numbering and even the docs commit.** `phase add`, `phase insert` and `gsd_run query commit` `[read: gsd-core/bin/gsd-tools.cjs:55-60, execute-plan.md:513-551]`.
- **141 of 191 workflow files call the runtime CLI**, 1,115 matches in total `[read: git grep -c]`.
- **Prose is the minority.** 47,570 lines of workflow Markdown sit on 189,301 lines of source and 805,031 lines of tests `[read]`.
- **State code has its own bug class.** #6509 moves `current_phase` off a running phase, and #4629 is an epic to verify `STATE.md` writes `[read]`.
- **The CLI exists to replace repeated inline Bash** across about 50 files `[read: gsd-core/bin/gsd-tools.cjs:4-7]`.
- **`CLAUDE_PLUGIN_ROOT` appears 40 times in 13 files**, including every hook command `[read: git grep -c]`.

Not read: `src/` bodies, hook bodies, the 111 decision records, tests, the installer. Not verified: whether `gsd-core/bin` is built from `src/`. The predecessor repository was not compared.

### bmad-code-org/BMAD-METHOD

Commit `e435a22` (2026-11-12). This branch is the version 7 preview; 6.12 is the stable line `[read: README.md:18]`.

- **It is the only repository with a written rule for the boundary.** "A script does work with one right answer per input" `[read: skills/toolsmith/bmad-toolsmith/lenses/lens-determinism.md:3]`.
- **The rule names signals for a script.** Parsing, counting, path resolution, template rendering, structure validation and diffing. The strongest signal is a helper re-derived on every run `[read: lens-determinism.md:5,11]`.
- **The rule names script defects too.** A script that swallows an error and exits 0, and a script that classifies meaning by regular expression `[read: lens-determinism.md:8-9]`.
- **Build and review stay prose.** `skills/method/bmad-build` and `skills/method/bmad-code-review` ship Markdown steps and TOML only `[read: git ls-files]`.
- **A ticket script mediates state.** `skills/method/bmad-agent-po/scripts/tickets.py` (1,891 lines) has `mark` and `move`; status lives in plan files `[read: tools/ticket-tree-rules.md:27-39]`.
- **Scripts print one JSON object and use three exit codes.** `[read: tickets.py:38-40]`
- **The runtime became a hard requirement.** 25 call sites used bare `python3` and failed silently into a fallback before `uv` became mandatory (#2704) `[read: CHANGELOG.md:85,127-128]`.
- **Tests match script size.** 19,929 lines against 19,027 `[read]`.

Not found: hooks, language twins. Not read: script bodies beyond one docstring, the version 6 installer, the changelog below line 210.

## Patterns across the seven

- **Tests cost one to six times the script.** superpowers 6, spec-kit about 2.5, OpenSpec 1.75, BMAD 1 `[inferred from counts]`. Version 1 of this repository had 944 script lines and 913 test lines, the cheap end of that range.
- **Platform bugs dominate script fixes.** macOS Bash 3.2, Git Bash path forms, `dash` as `sh`, Windows code pages and stripped executable bits recur in four repositories `[read]`.
- **Language twins drift.** spec-kit is the only repository with twins and the only one with parity as a changelog category `[read]`.
- **Hooks are the most fragile piece.** EGM removed its hook, superpowers removed its Codex hook, and mattpocock keeps its hook out of the plugin `[read]`.
- **Nobody implements multi-person claims in code.** mattpocock delegates the claim to the tracker assignee. spec-kit has an open numbering race `[read]`.
- **State is always plain files or the tracker.** The repositories differ only in who writes it `[read]`.
- **Read-side code looks cheaper than write-side code.** OpenSpec and spec-kit return state as JSON and let the agent edit. gsd-core's code-owned transitions carry open state bugs `[inferred]`.

## What this suggests for our design

The two favourites, mattpocock/skills and EGM, run a full workflow with no workflow-time code. That supports the owner's position: prose plus `git` and `gh` is the default, and a script needs a reason `[inferred]`.

Candidate test for giving a step code, all `[inferred]` from the practices above. A step earns a script when every line holds:

1. It has one right answer per input, and a unit test can check it (BMAD's rule).
2. An agent was observed getting it wrong or re-deriving it on every run (mattpocock's bar for #1372).
3. It reads state or guards a gate. The agent still makes the edit (OpenSpec's split, superpowers' `task-done`).
4. It fits one file in one language, called through the interpreter, with no harness variable (superpowers' helpers).
5. Its tests and platforms are budgeted first: macOS Bash 3.2, Linux `dash` and Git Bash.

Steps that stay prose under this test:

- Anything `git` or `gh` does in one command, including the claim. An issue assignee or a committed status line needs no script.
- Status and ID changes in files the agent already edits.
- Anything that classifies meaning.
- Anything that would need a hook or a second-language twin to work.

Version 1's claim, publish and land scripts fail lines 3 and 4: they mutated state and depended on a Claude-only variable. None of the seven repositories ships an equivalent.
