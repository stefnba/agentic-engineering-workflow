# Where workflow material lives

Date: 2026-08-18
Status: accepted

## Decision

Two different things get written into a consuming repo:

- **Workflow machinery** — config, backlog, in-flight bundles. Meaningless once you uninstall the
  workflow; bundles are explicitly deleted at Ship.
- **Repo knowledge the workflow happens to produce** — ADRs, research. These are the repo's own
  documentation. Uninstall the workflow and you keep every one of them.

So the test is: **does this survive uninstalling the workflow?** Survives → `docs/`. Doesn't →
`work/`.

That's why `docs/decisions/` and `docs/research/` belong exactly where they are, and why
`docs/agents/git.md` felt wrong sitting next to them — not because it's in `docs/`, but because
"agents" describes neither its content nor its audience.

The same reasoning applies one level up, to the plugin itself. Its normative contract and its
published prose were both sitting in `docs/`, which made the boundary invisible and let a derived
guide accumulate rules other documents then linked to. The contract moves to `workflow/`; `docs/`
keeps only what a human reads.

## Consequences

Plugin — three directories, three audiences:

```text
workflow/          the contract: lifecycle, artifacts, bundle, shaping-routes, git-mechanics
docs/              prose for humans: walkthrough, tool-setup, decisions/
docs/conventions/  git values and rules this repo owns (dogfooded instance of what setup installs)
agents/  skills/   plugin components
```

Consuming repo — two paths, one disposable:

```text
AGENTS.md                  pointer + conventions index
docs/conventions/git.md    this repo's git values     (was docs/agents/git.md)
docs/decisions/            ADRs
docs/research/             audit and external research
work/backlog.md
work/bundles/<id>/
```

- `docs/agents/` is renamed to `docs/conventions/` — self-describing, extensible to other convention
  files, and colliding with nothing in the plugin's own `agents/`.
- The test sorts individual rules, not only whole files. "Never create a worktree with a
  WorktreeCreate hook" applies to any worktree in the repository and stays true after uninstalling the
  workflow, so it lives in `docs/conventions/git.md` even though the workflow is what surfaced it. A
  convention file therefore holds rules, not only fill-in values.
- `workflow.md` becomes `workflow/lifecycle.md`; the folder carries the name the file used to.
- A `SKILL.md` reaches the contract as `${CLAUDE_PLUGIN_ROOT}/workflow/<file>.md` and the consuming
  repo's values as `${CLAUDE_PROJECT_DIR}/docs/conventions/git.md`. The two are no longer both
  `docs/…`, so a call site cannot silently read the wrong tree.
- Decision records stay out of `work/`. That tree's premise is disposability; records are immutable.
- Research splits by the same test: durable reference in `docs/research/`, evidence for one bundle in
  `work/bundles/<id>/`, which dies with the bundle.
