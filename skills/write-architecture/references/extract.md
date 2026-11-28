# Extracting from code

How to turn an existing repository into cited claims for `docs/ARCHITECTURE.md`, candidate decisions and candidate terms.

## What to extract

Record what an agent cannot see by opening one file: how the parts fit, where data lives, what crosses a boundary, and which choices constrain later work. A restatement of what a single file says goes stale and adds nothing an agent could not read itself.

| Output              | Extract                                                                                                                      |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `ARCHITECTURE.md`   | The parts and what each owns, how they call each other, data stores, external systems, entry points, shared code, invariants |
| Candidate terms     | Domain words that name types, tables or modules, and words used in two senses                                                |
| Candidate decisions | Choices visible in code that could pass the bar `record-decision` applies, such as a framework, a store or an auth scheme    |

## Rules

**Read `docs/decisions/` and `docs/GLOSSARY.md` first, when they exist.** Leave out candidate decisions a record already holds, and name parts and data with the glossary's terms.

**Name the decision record that settles each part, or "no record".** A record settles a part when its decision names the part's store, framework, boundary or owner.

**Record an invariant only with the code that enforces it**: a test that fails, a lint or import rule, or a check at a boundary. A rule that only holds by habit is a candidate decision.

**Record what several parts share**: error handling, logging, configuration, auth and helpers other parts import, each with the part that owns it.

**Cite `[path:symbol]` for every claim**, such as `[src/orders/repository.ts:OrderRepository]`. Drop a claim you cannot cite.

**Read the code before trusting a name.** A folder called `auth/` may hold no authentication. Never infer a route, a status value or a rule from a file or folder name alone.

**Read in this order:** build manifests and CI configuration, entry points, schemas and interfaces, then the rest. Skip tests, fixtures, generated files and vendored code.

**Check imports and manifests before naming a dependency.** A client class in the code may wrap a package rather than a service the system calls.

**Note that a secrets file exists, and never copy a value from it**, such as from `.env` or a credentials file. `docs/ARCHITECTURE.md` is committed and read by every agent.

**Check claims from existing docs against the code.** Cite both when the code agrees. When no code shows the claim, report it as unconfirmed instead of writing it.

## Splitting the work

**Split by subsystem: each directory directly under the main source root is one part**, such as each folder under `src/`. Split a part again when it holds more than about 50 source files.

**Give each part to its own fresh context window, at most five at a time.** Merge their returns yourself.

**Write each window's brief so it stands alone:**

- the part's paths, and that it reads them and writes nothing
- the rules and the reading order above
- the return shape below

**Leave out what the caller plans to build.** A window that knows the plan reads it into the code.

**Expect each window to return, in this order:**

- the part, as its path
- each claim with its cite
- the decision record that backs the part, or "no record"
- invariants and shared code, each with its cite
- candidate decisions, in the shape below
- candidate terms, each with the cite where it names code
- unconfirmed claims
- the paths it did not read, and why

**When no fresh context window is available, read the parts one after another**, and write down each part's return before reading the next.

**Report a part whose window failed or stopped early as not read.** A part with no return looks the same as a part with nothing to say.

## Candidate decision

Report each candidate in this shape:

```markdown
- Orders are stored in Postgres through one repository class — `[src/orders/repository.ts:OrderRepository]`, `[docker-compose.yml:db]`; rules out a document store
```
