<!-- Append everything below this comment to the root AGENTS.md, creating the file under a
`# <scope name>` heading when absent and replacing an existing `## Agentic engineering workflow`
section on a re-run. Fill the Scopes list: the root line naming what the root keeps, then one line
per member that keeps anything of its own, in Explore's order. Each line names its items out of
`work/`, `docs/GLOSSARY.md`, `docs/decisions/`, and `docs/ARCHITECTURE.md`, the last for any scope
only when the file exists. A glossary or record directory the repository keeps elsewhere, such as
`adr/`, is named by its real path on the root line only; member lines list only what sits inside
the member. Members that keep nothing of their own are not listed. Fill `<INTEGRATION_TARGET>` with
the root's answered target. In a single-project repository
keep only the root line and delete the two sentences that mention members, leaving `What each
scope keeps of its own.` Delete every comment when copying. Nothing below may use a `${...}`
placeholder: agent-instructions files expand none. -->

## Agentic engineering workflow

This repository uses the agentic engineering workflow, installed as skills.
[docs/agentic-engineering-workflow.md](docs/agentic-engineering-workflow.md) is the one-page
reference: its stages and gates, its terms, and where its files live. Read it before touching a
backlog, a bundle, or a bundle branch for the first time.

- **Integration target**: `<INTEGRATION_TARGET>`

Bundles are cut from this branch and land on it, unless the member they belong to names its own in
its `AGENTS.md`; the `workflow-manager` skill resolves which applies.

`docs/conventions/git.md` holds the worktree directory, under
[Worktrees](docs/conventions/git.md#worktrees), and the rule bundle and ticket branches follow, in
its [Agentic engineering workflow section](docs/conventions/git.md#agentic-engineering-workflow);
read both before any branch, worktree, or PR.

Before spawning a sub-agent for a workflow role, or starting a session for one, read
[docs/conventions/models.md](docs/conventions/models.md); it fixes which model each role runs on,
per harness.

Invoke the `workflow-manager` skill for bundle and ticket state, for which work folder a piece of
work belongs to, and for any bundle or ticket branch; it owns the workflow's terms. Invoke the
`backlog` skill to add, complete, or look up a backlog line, the `glossary` skill for a term, and
the `record-decision` skill for a decision; never edit those files directly.

### Scopes

What each scope keeps of its own. Root `work/` holds work that belongs to no single member. A
member's `AGENTS.md` says where its work, terms, and decisions go.

- Root — `work/`, `docs/GLOSSARY.md`, `docs/decisions/`
- `<member>/` — `work/`, `docs/GLOSSARY.md`, `docs/decisions/`, `docs/ARCHITECTURE.md`
