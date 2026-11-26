<!-- Template for docs/agentic-engineering-workflow.md, the page the AGENTS.md pointer block links. The setup skill copies it verbatim, dropping this comment, and replaces it on a re-run so a consuming repository always carries the current page. -->

# Agentic engineering workflow

How work moves through this repository: from a picked idea to a landed change, with a human at
every gate. This page orients; the skills hold the rules and the commands.

## Stages and gates

```text
Discover ──Pick──▶ Shape ──Plan──▶ Implement ──▶ Review ──Accept──▶ Land
```

| Stage       | What happens                                                                 | Gate after  |
| ----------- | ---------------------------------------------------------------------------- | ----------- |
| `Discover`  | Pick a backlog line or scan theme, or bring an idea; talk until settled      | **Pick**    |
| `Shape`     | Draft a bundle, have a fresh-context critic attack it, revise                | **Plan**    |
| `Implement` | A fresh session per ticket builds it to one PR; one sweep ticket may follow  | checks pass |
| `Review`    | An independent reader judges the PR; the human merges it                     | **Accept**  |
| `Land`      | Fold durable knowledge into docs, delete the bundle, merge the bundle branch | landed      |

Only the human passes a gate. Agents run everything between gates and never infer, self-grant, or
skip one. The human dispatches each stage; a stage's own inner loop, such as critique after a
draft, or the next wave of tickets once the human has accepted the last, runs by itself.

## Terms

- **Bundle**, or work bundle — one approved outcome and its artifacts: a spec, a plan, a spike, or
  tickets, as the work requires. Its `brief.md` is the one page the human judges it from at the
  Plan gate. Lives in `work/bundles/<bundle-id>/` on the bundle's own branch, never on the
  integration target.
- **Ticket** — one approved slice of a bundle: one fresh agent session, one PR into the bundle
  branch.
- **Sweep ticket** — the one ticket a bundle may gain after its last planned ticket merges, for
  low-risk defects its reviews found in what it shipped; admitted in chat, then run as any ticket.
- **Backlog** — `work/backlog.md`, one line per candidate work nobody has picked.
- **Member** — a workspace member: a directory the repository's workspace declaration names, or
  that the human names as one at setup.
- **Scope** — where a piece of work or a durable doc belongs: a member, or the root. A single
  project has one scope, the root.
- **Work folder** — a scope's `work/` directory, holding `backlog.md` and `bundles/`. A scope has
  one exactly when `work/bundles/` exists there, and then it owns that scope's work; setup creates
  it, nothing else does. The root always has one. Not a git worktree, which is a checkout under
  the worktree directory.
- **Integration target** — the branch a scope's bundles are cut from and land on. The root
  `AGENTS.md` names it; a member's `AGENTS.md` names its own only when it differs.

## Where things live

Paths are relative to a scope, root or member.

| Path                         | Holds                                                                                    | Ask                      |
| ---------------------------- | ---------------------------------------------------------------------------------------- | ------------------------ |
| `work/backlog.md`            | Unpicked candidate work                                                                  | `backlog`                |
| `work/bundles/<id>/`         | One in-flight bundle                                                                     | `shape-bundle`           |
| `work/scans/`                | Full reports of `scan-codebase` runs; gitignored, a snapshot goes stale as tickets merge | `scan-codebase`          |
| `docs/decisions/`            | Contested, consequential choices and why; immutable                                      | `record-decision`        |
| `docs/ARCHITECTURE.md`       | How the system works now                                                                 | `write-architecture-doc` |
| `docs/GLOSSARY.md`           | Canonical domain terms and avoided synonyms                                              | `glossary`               |
| `docs/research/`             | Research reports that informed a bundle; kept after it lands                             | read it                  |
| `docs/conventions/git.md`    | Branches, commits, PRs, worktrees; root only                                             | read it                  |
| `docs/conventions/models.md` | Which model each workflow role runs on, per harness; root only                           | read it                  |

Authority is by axis: the spec owns outcome and behavior, the plan owns approach and
decomposition, a ticket owns its one slice, durable docs own how the system works today. When two
disagree, surface both rather than picking one.

## Which skill

- `scan-codebase` — survey a member or directory through the design, simplification, conformance,
  and consistency lenses; the top themes come to chat, the full report to `work/scans/`, and
  what the human picks becomes a bundle prompt or a backlog line.
- `workflow-manager` — bundle and ticket status, which work folder a piece of work belongs to, and
  every bundle or ticket branch: cut, claim, complete, abandon. It owns the workflow's terms.
- `shape-bundle` — turn settled intent into an approved bundle; it runs `critique-bundle` itself.
- `implement-ticket` — build one ticket to a reviewed PR into its bundle branch; it runs
  `review-pr` itself, round by round, up to the Accept gate.
- `implement-bundle` — run every ticket of a bundle through fresh `implement-ticket` sub-agents, in
  the waves the plan allows, stopping at each ticket's Accept gate for the human.
- `write-pr` — open a PR, or refresh its body after the head moves, for a ticket branch or any
  other; `implement-ticket` runs it itself.
- `review-pr`, `review-changes` — an independent design and correctness review of a PR, posted on
  it, or of local changes no PR carries, reported in chat.
- `sweep-bundle` — once every ticket has merged, admit the low-risk review findings into one
  sweep ticket and send the rest to the backlog.
- `land-bundle` — once every ticket has merged, fold the bundle into the durable docs, delete it,
  and open the PR that takes its branch into the integration target.
- `backlog`, `glossary`, `record-decision`, `write-architecture-doc` — the caretakers of the files
  above; never edit those files directly.
- `setup-workflow` — install the workflow, or give a scope its own work folder, glossary, or
  decision records.
