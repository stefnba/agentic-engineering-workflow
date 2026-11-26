---
name: codebase-design
description: Design or restructure code for simplicity, maintainability and scalability in any language. Use when creating or splitting modules, drawing module boundaries, deciding where a type, helper, or error lives, choosing whether to add an interface, port, wrapper, or layer, reviewing a design or PR for structure, refactoring, or auditing a repo's architecture — even if the user only says "clean this up" or "where should this go". Do not use for formatting or lint rules, fixing a single test, writing a query, or editing inside a file whose location is already settled.
---

# Codebase design

Rules for where a module's interface sits, what goes behind it, when an abstraction has earned its place, and what to call things. They optimize for safe change: an engineer can find where a change belongs, make it in one place, and know from the tests that nothing else broke. When two rules conflict, the one that serves that goal wins.

**Deviate when a rule would make change harder, and say why** in a comment or the PR description. An undocumented deviation is a design bug.

## Path conventions

- `kinds/` and `languages/` paths are relative to this skill's directory, the folder holding this
  file.

## Read first

1. The repository's `CLAUDE.md` or `AGENTS.md`, and `docs/ARCHITECTURE.md` if present. Recorded decisions and existing names override every default here; where they conflict with this file, follow the repository and note the conflict in the review.
2. The kind profile: `kinds/pipeline.md` when the work runs in steps under a scheduler, CLI, or orchestrator; `kinds/http-backend.md` for REST backends. A library is neither: its consumer composes it, and its interface is what the package exports.
3. `languages/<lang>.md` for the repository's language: how to express ports, adapters, types, and import checks. If no profile exists, follow the repository's language conventions.

## Vocabulary

Use these terms exactly in findings and design discussion; the guards below are only precise in this vocabulary. Do not substitute _component_, _service_, _API_, _boundary_, _contract_, or _unit_ for them. Domain and framework names stay as they are.

- **Module**: anything with an interface and an implementation. Scale-agnostic: a function, class, package, or tier-spanning slice.
- **Interface**: everything a caller must know to use the module correctly — type signature plus invariants, ordering, error modes, required configuration, performance characteristics. Wider than _signature_.
- **Implementation**: the code inside a module.
- **Seam**: the place where behaviour can be changed without editing at that place; where a module's interface lives. _Where_ the seam goes is a separate decision from _what_ goes behind it.
- **Core**: the modules that say what must happen — step order, rules, calculations, state transitions. Declares the ports; imports nothing but the language and pure libraries. Anything that talks to the outside is an adapter.
- **Port**: an interface declared at a seam by the side that _needs_ something, normally the core. Every port is an interface; not every interface is a port.
- **Adapter**: a concrete thing that satisfies a port. Names a role, not substance — a Postgres adapter and an in-memory fake fill the same slot.
- **Composition root**: the one place where dependencies are constructed, bound to ports, and released. In a script this is the top of `main`; in a package it is a `compose` function. Nothing else constructs an adapter.
- **Entry point**: where the process is invoked — a CLI `main`, a route, a worker loop, a DAG. It parses input, loads configuration, calls the composition root, invokes, and formats output. Nothing more.
- **Depth**: behaviour a caller or test can exercise per unit of interface learned. Deep = small interface, large implementation. Shallow = interface nearly as large as the implementation.

## The model: deep modules at clean seams

Design deep modules: a lot of behaviour behind a small interface, placed at a seam, tested through that interface. Write the interface first, including invariants and error modes, not just the signature. When shaping it ask: can I reduce the methods, simplify the parameters, hide more inside?

- **Depth is a property of the interface.** A deep module may be composed internally of small, swappable parts; they are not part of the interface. Internal seams (private, used by the module's own tests) are fine alongside the external one.
- **Depth needs cohesion.** What sits behind one interface changes for related reasons (see _Draw modules around reasons to change_). Depth without that is a god object.
- **Deletion test.** Remove a module that only forwards calls without protecting a seam, translating data, or owning a rule. Keep it when deletion would spread those responsibilities to callers.
- **The interface is the main test surface.** Test observable behaviour there; test private parts directly when that gives useful fault isolation for complex logic.
- **Add a port for an external capability the core invokes** when the concrete dependency would expose infrastructure details or prevent fast, deterministic tests: I/O, network, a clock, randomness, a model. Shape it as the smallest capability the core needs, not what the vendor offers; a function type can suffice. Pure in-process collaborators stay concrete; a hypothetical second implementation is not a reason for a port.

## Principles

- **Draw modules around reasons to change**, not around technical layers by default. _Why_: a change should touch one module. _Not when_: a framework fixes the layering — follow it and keep the domain deep inside it.
- **Dependencies point inward**: core ← adapters ← composition root ← entry points. The core never imports I/O, frameworks, or infrastructure; adapters import the core, never each other — mechanics shared by adapters live in one private module that imports no specific adapter. _Why_: this one rule makes the core testable without mocks. _Not when_: throwaway scripts.
- **Pure core, impure shell.** Push side effects to the edges. Accept dependencies, don't construct them; return results, don't mutate arguments.
- **Make the interface explicit.** State types and invariants at each seam; validate untrusted data at entry points and adapters, then trust typed internal values. Avoid hidden global state or required call ordering the interface does not show. Errors are part of the interface: absence is a value, an expected failure has a named outcome or error, and a bug propagates to the outermost shell. Never use a sentinel or `None` to mean "failed".
- **Abstract shared rules, not repeated syntax.** Extract when multiple sites must change together to preserve one rule; leave coincidental similarity duplicated. Apply the deletion test to the result.
- **Immutable and small by default.** "Small" is measured in concepts, not lines; a deep module can be long. Make illegal states unrepresentable: sum types over flag combinations, required fields over nullable ones that "should" be set, value types for quantities with rules.

## Placement of types and helpers

- **A type or helper lives with the module that owns it**, as private as the language allows.
- **A type in a module's interface** (input, return, error) belongs with that module even with one caller; putting it in the caller's file inverts the dependency. The side that declares a port owns the types and errors that cross it.
- **A caller-internal type or helper stays in the caller's file** (or nearest scope: same package in Java, same module in Go/Rust) until a second file needs it.
- **When a second file needs it**, apply _Abstract shared rules, not repeated syntax_. An extracted type or helper goes with its owner, at the lowest level both users can import without a cycle.
- **Split files along seams.** File length alone is never a reason to split.

## Guards against over-engineering

- **No rule object for simple one-caller behaviour.** Keep it with its caller unless it forms a cohesive module with its own reason to change.
- **No spec-driven behaviour when a function would do.** Generic runners, registries, and plugin systems earn their place only for many cases differing solely by parameters. Cases that differ by behaviour get their own function.
- **No grab-bag modules.** Give shared code an owner and a cohesive purpose; a generic filename is a warning to inspect its contents, not proof of a bad boundary. Name private mechanics shared by adapters for what they do (`retrying`, `http_session`).
- **No in-repo framework.** No step runner, DAG engine, DI container, or event bus for one application. Explicit function calls.
- **No wrapping a library** unless direct use would expose its types across a seam, prevent fast, deterministic core tests, or meet a concrete replacement need. Pure CRUD with no domain rules needs no mapping layer either; one that only copies fields fails the deletion test.
- **No layer directories without a navigation or dependency benefit.** A small job can keep the roles in one package; separate directories when they make ownership easier to find or import rules easier to enforce, typically at a second entry point or when import direction is checked in CI.
- **Retry only an idempotent call.** Put retry mechanics in the adapter; use an idempotency key when the external system supports one, and let the caller set the attempt budget. Otherwise surface the failure for explicit reconciliation.

## Three tests before accepting a design

- **Trace test.** Follow one request end to end and apply the deletion test to every file it crosses.
- **Grep test.** From any call site the adapter behind a port is findable by search. Structural typing hides this, so an adapter states which port it satisfies — by subclassing, an `implements` clause, or one docstring line.
- **Explain test.** Every port, extracted rule, layer, and registry carries a one-sentence "why this exists" in its docstring or `docs/ARCHITECTURE.md`. If the sentence can't be written, delete the thing.

## When designing

1. Name the role of each piece before writing it: core, adapter, composition root, or entry point.
2. Write the interface first, then apply each guard and the three tests.
3. Move existing code only as far toward these rules as the change at hand requires; record the rest as findings.

## When reviewing

**List every port, extracted rule object, layer, registry, and wrapper in scope**, then apply each guard and each of the three tests to every item on the list. The review is complete when every listed item has either passed or produced a finding.

**Write each finding in this shape**, ordered by the cost of leaving it: boundary and data problems before naming.

```text
<file:line> — <problem> — <guard or test it fails> — <concrete fix>
```

A finding with no concrete fix is an opinion: keep it, but label it `opinion`.

## Naming

- Name by role in the domain, not by pattern: `StripePayments`, not `StripePaymentAdapterImpl`.
- No `Manager`, `Helper`, `Processor`, `Handler`, `Service`, `Util` suffix as a substitute for deciding what a thing is. Exception: where the repo's framework convention requires the suffix (Spring `@Service`, HTTP handlers); then use it and nothing more.
- Functions are verbs, types are nouns, booleans read as questions.
- One vocabulary from the domain, used in code, tests, docs, and conversation.
- Follow the language's conventions. Consistency inside the repository beats any preference in this file.

## Cross-cutting rules

- **Errors**: convert vendor failures at the adapter seam; catch where recovery is possible and report a failure once, without secrets or personal data.
- **Configuration**: read environment, files, or CLI options at the entry point and pass the resulting values through the composition root.
- **Tests**: exercise behaviour through module interfaces, keep core tests fast and deterministic by faking ports rather than mocking libraries, and test real adapters against their dependencies. A fake lives with the port's owner; a layer's tests obey the layer's import rule.
- **Observability**: configure logging, tracing, and metrics at the composition root; core and adapters only emit.
