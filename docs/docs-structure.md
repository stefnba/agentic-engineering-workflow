## 3. Workflow

The process — stages, gates, loops, approval points — is defined in [agentic-workflow.md](agentic-workflow.md), which is authoritative for anything about sequence or approval. This doc owns the artifact side: which stage reads and writes which document.

### Claiming, with parallel agents

Set `status: doing` and push _before_ starting work. A rejected push on a stale ref means someone else claimed it — re-read and pick another. Not a real lock, but sufficient for two or three concurrent agents. Beyond that, use issues, where assignment is atomic.

A claim only prevents two agents taking the _same ticket_. Two agents on different tickets can still conflict in code — nothing in this protocol prevents that. Small tickets and a rebase before opening the PR are the mitigation, not the claim.
