# Extracting from code

How to turn an existing repository into cited claims for `docs/ARCHITECTURE.md`, candidate decisions and candidate terms.

## What to extract

Record what an agent cannot see by opening one file: how the parts fit, where data lives, what crosses a boundary, and which choices constrain later work. A restatement of what a single file says goes stale and adds nothing an agent could not read itself.

| Output              | Extract                                                                                                            |
| ------------------- | ------------------------------------------------------------------------------------------------------------------ |
| `ARCHITECTURE.md`   | The parts and what each owns, how they call each other, data stores, external systems, entry points                |
| Candidate terms     | Domain words that name types, tables or modules, and words used in two senses                                      |
| Candidate decisions | Choices visible in code that are hard to reverse and span features, such as a framework, a store or an auth scheme |

## Rules

**Cite `[path:symbol]` for every claim**, such as `[src/orders/repository.ts:OrderRepository]`. Drop a claim you cannot cite.

**Read the code before trusting a name.** A folder called `auth/` may hold no authentication. Never infer a route, a status value or a rule from a file or folder name alone.

**Read in this order:** build manifests and CI configuration, entry points, schemas and interfaces, then the rest. Skip tests, fixtures, generated files and vendored code.

**Check claims from existing docs against the code.** Cite both when the code agrees. When no code shows the claim, report it as unconfirmed instead of writing it.

## Splitting the work

**Split by subsystem: each directory directly under the main source root is one part**, such as each folder under `src/`. Split a part again when it holds more than about 50 source files.

**Give each part to its own fresh context window, at most five at a time.** Each returns its claims with cites; merge them yourself.

**When no fresh context window is available, read the parts one after another**, and write down each part's claims before reading the next.

## Candidate decision

Report each candidate in this shape:

```markdown
- Orders are stored in Postgres through one repository class — `[src/orders/repository.ts:OrderRepository]`, `[docker-compose.yml:db]`; rules out a document store
```
