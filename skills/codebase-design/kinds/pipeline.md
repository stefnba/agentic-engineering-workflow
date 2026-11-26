# Pipeline

Repositories whose job is to run work in steps, invoked by a scheduler, a CLI, or an external orchestrator: data engineering, analytics and reporting, order and billing runs, agentic workflows that call models inside steps.

## Rules

- **Pass the logical date or interval to scheduled, backfillable work.** Derive its input window from that parameter so a backfill can use a past interval; keep clock reads and stored watermarks at the edge.
- **Define replay behaviour for each side effect.** Make writes idempotent where possible, using partition replacement or a key derived from the logical date and item, never from the run id. When an external system cannot deduplicate a call, record how reruns avoid or reconcile duplicates.
- **A step is a function.** Typed inputs in, typed outcome out; a warehouse step returns a reference (table, partition), not rows. Inputs arrive as arguments, including references earlier steps wrote; a step never hard-codes another step's output location.
- **Write step order once.** Use explicit calls in a core function when the job runs as one unit; let the external DAG own order when it schedules steps separately. Use a shared step declaration only when multiple real entry points must run the same graph.
- **Make independently retried steps re-enterable.** Persist or reconstruct the inputs and output references they need; a step can run alone only while those inputs remain available.
- **Decide partial-failure behaviour per step.** Fail the run, or return the bad items and their errors when processing continues under an explicit threshold.
- **The ingest adapter parses source data** into a core type and rejects or sets aside rows that do not fit; steps trust the type.
- **Declarations hold rules; adapters run them.** SQL transforms, prompts, schemas, and templates that encode domain rules are core, whatever directory holds them; a step names the declaration it runs, and an adapter executes what it is given without choosing or ordering declarations. Extraction queries and source definitions are adapter mechanics and stay with the adapter.
- **Expose the outcome to the invoker.** A CLI maps failure to a non-zero exit code; an orchestrator reports failure through its task status. Logs do not substitute for either signal.

## The four layers

Use these roles as modules in a small package or as directories when separation helps navigation or dependency checks.

| Layer                | Contains                                                                                      | May import                                                           |
| -------------------- | --------------------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| **core**             | Domain models, ports, step functions, order when the job runs as one unit, rules, core errors | stdlib, pure libraries                                               |
| **adapters**         | Implementations of ports; one private module for mechanics shared by adapters                 | core, third-party SDKs                                               |
| **composition root** | `compose`                                                                                     | core, adapters                                                       |
| **entry points**     | CLI, worker loop, orchestrator DAGs; outcome presentation and orchestration status            | `compose`, core types and errors, and the step functions a DAG needs |
