---
name: setup-workflow
description: Install the agentic engineering workflow in a repository, give a workspace member its own work folder, glossary, or decision records, or change the integration target or worktree directory. Run once per repository, then again only to change a value or add a scope.
disable-model-invocation: true
---

# Setup workflow

Installs the workflow into the repository the session runs in, so `workflow-manager`,
`shape-bundle`, `backlog`, `glossary`, `record-decision`, `scan-codebase`, and every skill that
spawns a sub-agent find the files they read. Check,
explore, ask, confirm, write, report. Nothing is written before the human answers `Proceed?` with
a yes.

## Path conventions

- `templates/` paths are relative to this skill's directory, the folder holding this file; the
  glossary template is `../glossary/templates/glossary.md` from here. Requires the `glossary`
  skill: if that path is missing, load that skill by name only to find its directory, and keep
  following this skill's process; if that fails too, stop and tell the human to install it.
- Every other path is a **repository path**, relative to the repository root: `git rev-parse
--show-toplevel`. Resolve from the root, never from the current directory; a session started
  inside a member is common.

## Terms

- **Member** — a workspace member: a directory the repository's workspace declaration names, or
  that the human names as one here. Its path is whatever the layout uses: `apps/<name>/`,
  `packages/<name>/`, `services/<name>/`.
- **Scope** — where a piece of work or a durable doc belongs: a member, or the root. A single
  project has one scope, the root.
- **Scope name** — the title of the scope's `README.md`, or its directory name when there is no
  README; for the root, the root README's title or the repository directory's name. It heads a
  created `AGENTS.md` and titles a glossary.
- **Work folder** — a scope's `work/` directory, holding `backlog.md` and `bundles/`. A scope has
  one exactly when `work/bundles/` exists there, and then it owns that scope's work; setup creates
  it, nothing else does. The root always has one. Not a git worktree, which is a checkout under
  the worktree directory.
- **Durable docs** — the three things a scope may keep beside its work folder, each with a
  caretaker skill: `docs/GLOSSARY.md` (`glossary`), `docs/decisions/` (`record-decision`), and
  `docs/ARCHITECTURE.md` (`write-architecture-doc`). Setup can pre-create the first two empty;
  the caretakers also create them on first use, so an absent one is normal.
- **Integration target** — the branch a scope's bundles are cut from and land on. The root
  `AGENTS.md` names the default; a member's `AGENTS.md` names its own only when it differs.

## Guardrails

- **Write the worktree directory only into `docs/conventions/git.md` and each integration target
  only into an `AGENTS.md`**, in the exact list-line forms the templates carry. The
  `workflow-manager` script parses `` - **Worktree directory**: `<dir>` `` under `## Worktrees`.
  Agents read `` - **Integration target**: `<branch>` `` from the `## Agentic engineering workflow`
  section of the root `AGENTS.md`, or of a member's whose target differs, and pass it to the
  scripts. There is no settings file.
- **Change a scope's integration target only while that scope has no `active` bundle.** Land
  counts and merges against the target as it reads at Land, so a bundle cut from the old branch
  would land on the new one with that branch's commits named as foreign. A member without its own
  line inherits the root's, so a root change concerns those members too.
- **Replace, never duplicate, on a re-run.** The `## Agentic engineering workflow` section in
  `docs/conventions/git.md`, in the root `AGENTS.md`, and in a member's `AGENTS.md` is the unit a
  re-run replaces: from that heading up to the next heading of level 1 or 2, `# ` or `## `, or the
  end of the file. A `###` inside the section, such as the pointer's Scopes or an older
  `### Work folders`, is replaced with it. Everything outside the section stays as the repository
  wrote it. The `git.md` section holds no sub-heading, because the `workflow-manager` script stops
  reading at a heading of any level. A replace, of a section or of the workflow page, that changes
  no byte is reported as `skip; identical`, so the human is never told to commit an empty diff.
- **Leave an existing backlog, glossary, or decisions directory untouched, and create one only in
  a scope the human chose.** A member's `work/bundles/` is the signal that it owns its work, so
  creating one uninvited silently moves that member's work out of the root. A glossary or
  decisions directory carries no such signal; pre-creating one is a convenience the human opts
  into per scope. Empty is the expected steady state.
- **Every member's layout is the human's choice.** A monorepo may keep all work at the root or
  give some members their own folders; recommend, never assume. The one fixed point: the root
  always keeps a work folder, because cross-cutting work has nowhere else to go.
- **A repository that keeps decision records elsewhere gets no `docs/decisions/` anywhere**,
  because the `record-decision` skill files every record there. Elsewhere is a directory of
  numbered records such as `adr/`, `doc/adr/`, or `doc/architecture/decisions/`. Say so in the
  question rather than asking, and answer a request for one with that reason; a scope the human
  still names gets a `skip; records are kept in <dir>/` bullet.
- **Keep the `.gitignore` worktree entry equal to the worktree directory in `git.md`.** They are one
  decision written twice; a mismatch leaves worktrees staged for commit.
- **Print commands that fix a failed prerequisite; never run them.**

## What a run writes

Root-only paths come first. `<scope>/` paths land once per scope the human chose, where the root
scope's prefix is empty. Every report lists paths in this order: the root-only rows, then for each
scope in Explore's order its `<scope>/` rows, closing with that member's `AGENTS.md`. A row the
human did not choose gets no bullet; a row the human chose that a rule then skips gets a `skip`
bullet naming the rule. The verbs are `create`, `append`, `replace`, or `skip`.

| Path                                   | Absent                                                                         | Present                                                                                                                                       |
| -------------------------------------- | ------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `docs/conventions/git.md`              | create from `templates/git-conventions.md`                                     | append or replace the `## Agentic engineering workflow` section from the template's; append or replace the worktree line under `## Worktrees` |
| `docs/agentic-engineering-workflow.md` | create from `templates/agentic-engineering-workflow.md`                        | replace; the page is the workflow's, not the repository's                                                                                     |
| `docs/conventions/models.md`           | create from `templates/models.md`                                              | skip; the cells are the repository's, and a row the template has that the file lacks is named under Yours from here                                   |
| `AGENTS.md`                            | create from `templates/agents-pointer.md` under a `# <scope name>` heading     | append or replace the `## Agentic engineering workflow` section                                                                               |
| `CLAUDE.md`                            | skip; a harness that reads `CLAUDE.md` falls through to `AGENTS.md`            | append `@AGENTS.md` when it does not reference `AGENTS.md`, else skip; the pointer itself never goes there                                    |
| `.gitignore`                           | create with `<worktree dir>/` and `**/work/scans/`                             | append each of `<worktree dir>/` and `**/work/scans/` that no line already ignores, with or without a leading slash                           |
| `<scope>/work/backlog.md`              | create from `templates/backlog.md`                                             | skip                                                                                                                                          |
| `<scope>/work/bundles/`                | create, with an empty `.gitkeep`                                               | skip                                                                                                                                          |
| `<scope>/docs/GLOSSARY.md`             | create from the `glossary` skill's template, `<PROJECT_NAME>` the scope name   | skip; also skip when the scope keeps a glossary elsewhere, such as a root `GLOSSARY.md`                                                       |
| `<scope>/docs/decisions/`              | create, with an empty `.gitkeep`                                               | skip; also skip everywhere when the repository keeps records elsewhere                                                                        |
| `<member>/AGENTS.md`                   | create from `templates/member-agents-hint.md` under a `# <scope name>` heading | append or replace the `## Agentic engineering workflow` section, for each member that keeps anything of its own                               |

`docs/ARCHITECTURE.md` has no row: it needs real content, so it appears in the Scopes part of
Confirm and the report hands each scope that chose one to `/write-architecture-doc`.

**Each member's `AGENTS.md` states where that member's work, terms, and decisions go**, one line
per item, either its own file, the root's, or the repository's elsewhere directory. The `glossary`
and `record-decision` skills read that declaration before placing a term or a record, so this line
is what makes the Scopes decision stick; a "read `docs/GLOSSARY.md` before" line the member already
has counts as the declaration for that path. The root pointer's Scopes list is the map of what
every scope keeps; it orients, and a re-run refreshes it.

## Report format

Every step reports the same way, so the human reads one shape from start to finish: a bold
heading, then one bullet per item as `` `check or path` — value ``, followed by `; reason` when
the value alone does not explain itself. Prerequisites carry ✅ or ❌; writes carry one of the
four verbs above. Never a table in a report. Name what was found, not only the verdict; `absent`
is a normal value, not a failure. The fenced blocks under each step are the format; when a case has
no example, keep the nearest example's shape.

## Process

### 1. Check prerequisites

Three checks:

1. `git remote -v` shows a remote named `origin`; the workflow's script queries that name.
2. `git remote show origin` prints a `HEAD branch:` that names a branch. `(unknown)` is a ❌: the
   remote itself has no default branch set, and a local `git remote set-head` does not change it.
3. `gh auth status` reports the host `origin` points at as logged in. When `origin` is a local
   path or names no forge host, report the login `gh` has and ✅; bundle status will read
   `unknown` there anyway.

Bundle and ticket status is derived from remote branches and pull requests, so without a remote or
an authenticated forge CLI every status reads `unknown`. Report all three lines every run; a check
that could not run because an earlier one failed is ❌ with that reason.

```markdown
**Prerequisites**

- ✅ Remote — `origin` → `git@github.com:acme/billing.git`
- ✅ Default branch — `main` on `origin`
- ✅ Forge CLI — `gh` authenticated as `dana-k`
```

**Stop and report if any check fails.** Say which check failed, why it blocks the workflow, and
give the commands that fix it in dependency order, since authenticating precedes creating a
repository and creating one precedes pushing to it. Each failure has its own remedy:

- No remote at all — the example below.
- A remote under another name — `git remote rename <name> origin`, then run the skill again.
- `HEAD branch: (unknown)` — when `git ls-remote --heads origin` is empty, the remote has no
  branches yet: `git push -u origin <branch>`. Otherwise set the remote's default branch:
  `gh repo edit --default-branch <branch>` on GitHub, or `git symbolic-ref HEAD refs/heads/<branch>`
  inside a bare remote; then run the skill again.
- `gh` not authenticated — `gh auth login`, then run the skill again.

Every stop has the example's shape: the three check lines, the bold `Stopped` sentence with the
reason, each remedy in its own `bash` block, and `Then run this skill again.`

````markdown
**Prerequisites**

- ❌ Remote — none configured; `git remote -v` is empty
- ❌ Default branch — can't check; no `origin` to check against
- ✅ Forge CLI — `gh` authenticated as `dana-k`

**Stopped — nothing written.** Bundle and ticket status is read from remote branches and pull
requests, so a repository with no remote reports `unknown` for everything the workflow asks.

If the repository doesn't exist on the forge yet, commit any uncommitted work, then create it and
push:

```bash
gh repo create <name> --private --source=. --remote=origin --push
```

If it already exists, wire up the remote instead:

```bash
git remote add origin <url> && git push -u origin <branch>
```

Then run this skill again.
````

Done when all three are ✅, or the stop is reported.

### 2. Explore

Read what exists; don't assume. Report under a **Repository** heading, one bullet per item in the
order below, each naming what was found:

- Layout — single project, or monorepo. Take the first signal that hits: a workspace declaration
  (`[tool.uv.workspace]`, `pnpm-workspace.yaml`, `workspaces` in `package.json`, `[workspace]` in
  `Cargo.toml`, `go.work`); a monorepo orchestrator (`turbo.json`, `nx.json`, `lerna.json`,
  `moon.yml`); or more than one package manifest below the root. A declaration names members
  outright; the other two only suggest them, so list what was found for the human to correct. Name
  each member by its directory and by the name its code is imported or invoked by, in the order
  the declaration's globs expand, alphabetical within a glob, or alphabetical by directory when
  no declaration names them; those become the scope rows of a fresh `git.md`.
  In a single project name the code directory, `src/` when the layout uses one, and its import
  or invocation name the same way; that becomes the one scope row.
- `docs/conventions/git.md` — absent or present. Present with an `## Agentic engineering workflow`
  section means a re-run: report its worktree line, which the questions then offer, and an
  `Integration target` line from an older install, which this run moves to the root `AGENTS.md`.
  Also name any branch or merge rule that contradicts the workflow, such as a naming rule for
  every branch or a rebase-only merge policy, so the human sees it before approving.
- `AGENTS.md` — absent, present, or present with the pointer section and its integration target;
  name any sub-heading the section holds, such as an older `### Work folders`, since the replace
  takes it along. Also
  whether `CLAUDE.md` exists and references `AGENTS.md`; one that does not will never load the
  pointer.
- `docs/agentic-engineering-workflow.md` — absent or present.
- `docs/conventions/models.md` — absent, present, or present without a row the template has.
- `.gitignore` — every line that names a worktree directory, such as `/.claude/worktrees/` or
  `.worktrees/`, or `no worktree line`, marking a harness's own directory as `harness, not a
candidate`: the workflow creates worktrees with plain git and must not share a root with
  harness-managed ones. Also whether a line already ignores `**/work/scans/`.
- Decision records kept elsewhere — a directory of numbered records anywhere, such as `adr/`,
  `doc/adr/`, or `doc/architecture/decisions/`, or none.
- Each scope, root first, then each member — its scope name, then four values: work folder
  (`work/bundles/` present, so already opted in; `work/` without `bundles/`, a hand-made backlog
  and the likeliest candidate; or none), glossary (present with its entry count, not counting the
  template's commented entry form; kept elsewhere such as a root `GLOSSARY.md`; or absent),
  decisions (present with its record count, `kept in adr/`, or absent), architecture doc (present
  or absent). For a member, also whether it has an `AGENTS.md`, whether that file already holds
  the workflow section, which makes the member write a replace, and whether it already points at
  its glossary or architecture doc outside that section.

```markdown
**Repository**

- Layout — monorepo; `[tool.uv.workspace]` declares `apps/*` and `packages/*` → `apps/billing` (`billing`), `apps/portal` (`portal`), `packages/db` (`db`)
- `docs/conventions/git.md` — present, no workflow section; its branch rule names every branch `<kind>/<name>`, which the section will exempt bundle and ticket branches from
- `AGENTS.md` — present, no pointer section; `CLAUDE.md` present and includes `@AGENTS.md`
- `docs/agentic-engineering-workflow.md` — absent
- `docs/conventions/models.md` — absent
- `.gitignore` — ignores `/.claude/worktrees/` (harness, not a candidate); no `**/work/scans/` line
- Decision records elsewhere — none
- root (`Acme Billing`) — work folder: `work/bundles/` present, 1 bundle folder, no backlog; glossary: absent; decisions: absent; architecture: absent
- `apps/billing` (`Billing`) — work folder: `work/` with a 3-line backlog, no `bundles/`; glossary: 12 entries; decisions: absent; architecture: present; `AGENTS.md` present, no workflow section, already points at `docs/GLOSSARY.md` and `docs/ARCHITECTURE.md`
- `apps/portal` (`Portal`) — work folder: none; glossary: absent; decisions: absent; architecture: absent; `AGENTS.md` present, no workflow section
- `packages/db` (no README, `db`) — work folder: none; glossary: absent; decisions: absent; architecture: absent; no `AGENTS.md`
```

On a re-run the `git.md` line reads `` present, with the workflow section: worktree `.worktrees` ``,
the `AGENTS.md` line `` present with the pointer section, target `main` ``, a member line adds
`` target `app/billing` `` when its section names one,
and a single project's Layout line reads ``single project; `invoicer/` (`invoicer`)``.
Done when every line above has a value.

### 3. Ask

Ask everything in one round, each question with its recommended answer. On a re-run the
recommendation is the value the file holds, worded `currently X; keep?`, and the protection
question is asked only when the human names a different target.

- **Integration target** — recommend the default branch and ask whether it is protected: required
  reviews, no direct push, or required linear history make it unusable, because landing a bundle
  is a PR merged into it. A protected default branch needs a separate branch such as `dev`, which
  the repository's own release process promotes. Protection is the human's answer to give, not a
  check to run.
- **Member integration targets** — for each member that has or gets a work folder, recommend the
  root's target. A member whose work integrates on a long-lived branch of its own, such as an app
  built on `app/<name>` before it reaches the default branch, names that branch; it lands in that
  member's `AGENTS.md`. Ask it as part of the member's Scopes line.
- **Worktree directory** — recommend `.worktrees`. A directory `.gitignore` already ignores only
  decides whether the `.gitignore` write is a skip.
- **Scopes** — for each scope, which of the four it keeps: work folder, glossary, decisions,
  architecture doc. One line per scope, each item with a recommendation. What exists is already
  chosen; mark it `already there` rather than asking again. The root keeps a work folder without
  asking; in a single project it is the only scope. When records are kept elsewhere, every
  decisions item reads `kept in adr/, not asked`. Recommend:
    - Work folder — no member by default: one backlog with area tags serves one team. A member
      that is a product of its own, with its own owners, or one piloting the workflow, gets one; a
      shared library never does, since its work is cross-cutting by definition. Name a member with
      a hand-made `work/` as the likeliest candidate.
    - Glossary — the root in a single project; in a monorepo, each member with vocabulary of its own
      plus the root, since the `glossary` skill promotes a term to the root once a second member
      uses it. Empty is normal.
    - Decisions — the root always, for tooling and process; each member that gets a work folder,
      since a decision that binds one member lives with it.
    - Architecture doc — the root of a single project; each member that is a running system; the
      root of a monorepo only when the human wants how members relate written down. Setup never
      writes it; the report hands each chosen scope to `/write-architecture-doc`.

```markdown
**Questions**

1. Integration target — recommend `main`, the default branch. Is `main` protected (required reviews, no direct push, linear history)? If so, name the branch bundles should land on instead.
2. Worktree directory — recommend `.worktrees`, the default; `.gitignore` gets a line for it.
3. Scopes — confirm or change each line:
    - root — work folder: always; glossary: yes, for terms shared across members; decisions: yes, for tooling and process; architecture: no, unless you want how the members relate written down
    - `apps/billing` — work folder: yes, its hand-made `work/` says it already runs its own; target: the root's; glossary: already there, 12 entries; decisions: yes, it is getting a work folder; architecture: already there
    - `apps/portal` — work folder: no, stays on the root unless it is a product of its own; glossary: no; decisions: no; architecture: yes, it is a running system
    - `packages/db` — work folder: no, shared library; glossary: no; decisions: no; architecture: no
```

In a single project the Scopes question is one line: `root — work folder: always; glossary: yes;
decisions: yes; architecture: yes, it is a running system`. On a re-run the worktree question adds
`a change leaves the old ignore line in place; the report names it`.

Branch names and how a bundle lands are not questions; the `workflow-manager` skill fixes them.
The `@AGENTS.md` line for a `CLAUDE.md` that lacks it is not a question either; Confirm shows it.
Done when every question has an answer.

### 4. Confirm

For every answered target that differs from the default branch, the root's or a member's, check
it exists on the remote with `git ls-remote --heads origin <target>`. A missing branch is a stop in
the prerequisites' shape:

````markdown
**Integration target**

- ❌ `dev` — not on `origin`; `git ls-remote --heads origin dev` is empty

**Stopped — nothing written.** Bundles land on the integration target, so it has to exist on the
remote before the first bundle branch is cut from it.

```bash
git push origin main:dev
```

Then say so, and this check runs again; or name another branch.
````

**When a re-run changes a scope's target, run the `workflow-manager` skill's `scripts/bundles.sh`.**
An `active` bundle in that scope, or, for a root change, in a member without its own line, is a stop
in the same shape: name the bundle, say nothing was written, and offer to keep the target until
that bundle lands or is abandoned.

When every row in the table would be a skip, report `**Nothing to write.** Every path is present
and identical; nothing to commit.` under the Values and Scopes parts and stop without asking
`Proceed?`. Otherwise report four parts and wait for a yes. The human approves the decisions and every line
that is filled by hand or lands in a file the repository already owns; a template copied unchanged
is text they can read in this skill.

1. **Values** — the worktree directory and every integration target, the root's and each member's
   own, with their reasons; on a re-run, the value each replaces, or `unchanged`.
2. **Scopes** — one line per scope naming what it keeps after this run, new items marked as such,
   an item a rule refused marked with the rule, then the members that keep nothing of their own.
3. **Writes** — one bullet per path in the table above, in its order, skips included; a path the
   human does not see is one they assume untouched.
4. **Sections, verbatim** — one fenced block per written section or line, each under a lead-in
   carrying the verb, `Appended to` or `Replaced in`: the `git.md` section and, in its own block,
   the worktree line; the `AGENTS.md` pointer with its Scopes list; the
   member section for each member that keeps anything of its own; the `.gitignore` lines; and the
   `@AGENTS.md` line when it applies. A created `AGENTS.md` is shown whole, heading included,
   under `Created as`; a created `git.md` shows only its filled scope rows and example under
   `Created as`, since Values already shows the two values. No block for a section identical to
   what the file holds.

````markdown
**Values**

- Integration target — `dev`; you reported `main` protected by required reviews. `dev` exists on `origin`
- Worktree directory — `.worktrees`; the default

**Scopes**

- root — work folder; glossary (new); decisions (new)
- `apps/billing` — work folder (new; its hand-made backlog stays and gets a `bundles/` next to it); glossary; decisions (new); architecture
- `apps/portal` — architecture (new, via `/write-architecture-doc` after this run); work stays on the root
- `packages/db` — nothing of its own; work stays on the root

**Writes**

- `docs/conventions/git.md` — append the section below and the worktree line under `## Worktrees`; the rest untouched
- `docs/agentic-engineering-workflow.md` — create
- `docs/conventions/models.md` — create
- `AGENTS.md` — append the section below
- `CLAUDE.md` — skip; already includes `@AGENTS.md`
- `.gitignore` — append `.worktrees/` and `**/work/scans/`
- `work/backlog.md` — create, empty
- `work/bundles/` — skip; present
- `docs/GLOSSARY.md` — create from the template, no entries, as `# Acme Billing — Glossary`
- `docs/decisions/` — create, empty
- `apps/billing/work/backlog.md` — skip; yours, 3 lines
- `apps/billing/work/bundles/` — create
- `apps/billing/docs/GLOSSARY.md` — skip; yours, 12 entries
- `apps/billing/docs/decisions/` — create, empty
- `apps/billing/AGENTS.md` — append the member section below; its Glossary and Architecture lines are dropped because the file already points at both

Appended to `docs/conventions/git.md`:

```markdown
## Agentic engineering workflow

…
```

Appended to `docs/conventions/git.md`, under `## Worktrees`:

```markdown
- **Worktree directory**: `.worktrees`
```

Appended to `AGENTS.md`:

```markdown
## Agentic engineering workflow

…
```

Appended to `apps/billing/AGENTS.md`:

```markdown
## Agentic engineering workflow

…
```

Appended to `.gitignore`:

```text
.worktrees/
**/work/scans/
```

Proceed?
````

The `…` stands for the full section; a real report shows every line. A created member file's
Writes bullet reads `` `apps/admin/AGENTS.md` — create under `# admin` with the member section
below ``. On a re-run the same report reads `replace` where a section exists, `skip; identical`
where nothing would change, `` `docs/conventions/git.md` — skip the section; identical; replace the
worktree line `` when only the directory changed, `` `docs/conventions/models.md` — skip; present ``
or `` skip; present, lacks the Scan row `` naming each missing row, `` `.gitignore` — skip; both
lines present ``, and the Values lines carry `unchanged` or the value replaced. Done when the human says yes; any other
answer returns to the question it concerns.

### 5. Write

Work down the table in What a run writes, in its order. Fill every slot a template's comments
name and drop every comment, except one the template itself says to keep, such as the glossary's
entry form. In a markdown file, separate anything appended from the text above it by one blank
line; `.gitignore` and `CLAUDE.md` lines are appended directly.

1. `docs/conventions/git.md` — when absent, copy `templates/git-conventions.md`, filling the
   worktree directory and the scope table: in a monorepo one row per member; in a single project one row for
   the code itself, both named as Explore recorded them. Set the example's `<component>` to one of
   those rows. When present, take the template's last section, from its
   `## Agentic engineering workflow` heading to the end of the file; replacing the section drops an
   `Integration target` line an older install wrote there, now in the root `AGENTS.md`. Write
   the worktree line as the first line under `## Worktrees` first, creating that heading with only
   that line at the end of the file when absent; then append the section after it, or replace the
   section already there. Touch nothing else in the file.
2. `docs/agentic-engineering-workflow.md` — copy the template, replacing a copy from an earlier
   run.
3. `docs/conventions/models.md` — copy `templates/models.md` when absent; when present, leave it
   and name under Yours from here each row the template has that the file lacks, since the skills
   that spawn sub-agents read their row there.
4. Root `AGENTS.md` — append `templates/agents-pointer.md`, creating the file under a
   `# <scope name>` heading when absent, and replacing the section already there. Fill its
   integration target with the root's answer, and its Scopes list as the template's comment says,
   from what each scope keeps after this run.
5. `CLAUDE.md` — when it exists without referencing `AGENTS.md`, append the `@AGENTS.md` line
   Confirm showed.
6. `.gitignore` — append `<worktree dir>/` unless a line already ignores that directory, with or
   without a leading slash, and `**/work/scans/` unless a line already ignores it: scan reports
   from `scan-codebase` are snapshots that go stale as tickets merge, kept on disk and out of
   history. On a re-run that changed the directory, leave the old line and any
   worktrees `git worktree list` still shows under it; name both in the report, since removing
   them is the human's call.
7. Work folders — for each scope that keeps one, copy `templates/backlog.md` to
   `<scope>/work/backlog.md` and create `<scope>/work/bundles/.gitkeep`, skipping either that
   exists. `work/bundles/` is what makes a work folder one: git cannot track an empty directory,
   and on the target it stays empty by design because bundles live on their branches.
8. Glossaries — for each scope that keeps one, copy the `glossary` skill's template to
   `<scope>/docs/GLOSSARY.md`, replacing `<PROJECT_NAME>` with the scope name; create `docs/` when
   absent. Skip a scope that already keeps a glossary, at that path or elsewhere.
9. Decisions — for each scope that keeps them, create `<scope>/docs/decisions/.gitkeep`, skipping
   a directory that exists.
10. Member `AGENTS.md` — append `templates/member-agents-hint.md` to each member that keeps
   anything of its own, creating the file under a `# <scope name>` heading when absent, and
   replacing the section already there. Fill it as the template's comment says: a Work and a
   Decisions line always, a Glossary line unless dropped, each the own, root, or elsewhere
   variant the Scopes decision picked, with `<path>` filled for elsewhere; keep the Architecture
   line only when the member's `docs/ARCHITECTURE.md` exists, and the Integration target line only
   when the member's answered target differs from the root's; drop the Glossary or Architecture
   line when the file already points at that path outside the section, as Explore reported. A
   member that keeps nothing of its own gets no section; the root serves it for everything.

Done when every non-skip row in the confirmed Writes list exists on disk as described.

### 6. Report

Report **Installed** with the same bullets as Writes, verbs in the past tense, then **Yours from
here** with what the human owns from this point. The first two bullets are always there; the rest
appear when they apply:

- Commit and push the files, so the section is on the remote for every checkout; nothing is
  committed for them. When every Installed bullet is a skip, this bullet reads `nothing to commit`.
- `docs/conventions/git.md` is theirs to edit; a re-run replaces only its workflow section.
- Each scope chosen for an architecture doc that has none: invoke `/write-architecture-doc` in
  that scope, one line per scope.
- Root bundle folders or backlog lines that concern only a member that just got a work folder,
  each named; moving them is a decision and a commit of their own.
- A stale ignore line or leftover worktrees from a changed directory: `.gitignore` still ignores
  `<old>/`, and each worktree `git worktree list` shows under it, named.
- A present `docs/conventions/models.md` that lacks a template row: `` `docs/conventions/models.md`
  lacks the <Role> row; add it `` for each.
- A branch rule in `git.md` that Explore flagged, with the sentence in the section that exempts
  bundle and ticket branches from it.

```markdown
**Installed**

- `docs/conventions/git.md` — appended the workflow section and the worktree line, `.worktrees`
- `docs/agentic-engineering-workflow.md` — created
- `docs/conventions/models.md` — created
- `AGENTS.md` — appended the pointer section, target `dev`
- `CLAUDE.md` — skipped; already includes `@AGENTS.md`
- `.gitignore` — appended `.worktrees/` and `**/work/scans/`
- `work/backlog.md` — created, empty
- `work/bundles/` — skipped; present
- `docs/GLOSSARY.md` — created from the template, no entries, as `# Acme Billing — Glossary`
- `docs/decisions/` — created, empty
- `apps/billing/work/backlog.md` — skipped; yours
- `apps/billing/work/bundles/` — created
- `apps/billing/docs/GLOSSARY.md` — skipped; yours
- `apps/billing/docs/decisions/` — created, empty
- `apps/billing/AGENTS.md` — appended the member section

**Yours from here**

- Commit and push these files under your commit conventions; nothing is committed for you.
- `docs/conventions/git.md` is yours to edit; a re-run replaces only its workflow section.
- `apps/portal` has no architecture doc yet; invoke `/write-architecture-doc` there when ready.
- `work/bundles/2026-09-24-invoicing/` concerns only `apps/billing` and belongs in `apps/billing/work/bundles/` now; move it in its own commit when nothing is in flight on it.
```

On a re-run that changed the worktree directory, the Installed bullet reads `` `.gitignore` —
appended `.wt/` `` and Yours from here adds `` `.gitignore` still ignores `.worktrees/`; no worktree
is left under it ``.

## Checklist

- [ ] All three prerequisites reported, every run.
- [ ] Every written file matches its template verbatim, with every comment dropped except one the template says to keep, and every slot the comments name filled: the pointer's Scopes list, each member section's placement lines, the glossary titles, the scope rows, the worktree directory, and each integration target.
- [ ] `docs/conventions/git.md`, the root `AGENTS.md`, and every member `AGENTS.md` touched hold exactly one `## Agentic engineering workflow` section; `git.md` holds one worktree line and no integration target; the root `AGENTS.md` holds one `Integration target` line, and a member's holds one only when its target differs.
- [ ] `.gitignore` ignores the worktree directory written in `git.md` and `**/work/scans/`.
- [ ] `docs/conventions/models.md` exists; each template row it lacks is named under Yours from here.
- [ ] The root keeps a work folder.
- [ ] No existing backlog, glossary, or decisions directory changed; nothing created in a scope the human did not choose.
