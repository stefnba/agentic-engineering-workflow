---
name: code-design
description: Shared vocabulary for designing and judging module interfaces — deep vs shallow modules, seams, adapters, testability. Binding for the implement skill wherever a ticket introduces or reshapes a module seam. Invoke or read it when designing a new module's interface, deciding where a seam goes, judging whether an abstraction earns its keep, or making code more testable.
---

# Code Design

Design **deep modules**: a lot of behavior behind a small interface, placed at a clean seam,
testable through that interface. Use this language wherever code is being designed, extended, or
restructured. The aim is leverage for callers, locality for maintainers, and testability for
everyone.

## Glossary

Use these terms exactly; don't substitute "component," "service," "API," or "boundary."

**Module**: anything with an interface and an implementation. Scale-agnostic: a function, class,
package, or tier-spanning slice. _Avoid_: unit, component, service.

**Interface**: everything a caller must know to use the module correctly — the type signature, plus
invariants, ordering constraints, error modes, required configuration, and performance
characteristics. _Avoid_: API, signature (too narrow — covers only the type-level surface).

**Implementation**: what's inside a module. Distinct from **Adapter**: a thing can be a small
adapter with a large implementation (a Postgres repository) or a large adapter with a small
implementation (an in-memory fake). Reach for "adapter" when the seam is the topic, "implementation"
otherwise.

**Depth**: leverage at the interface — how much behavior a caller or test can exercise per unit of
interface they have to learn. A module is **deep** when a large amount of behavior sits behind a
small interface, **shallow** when the interface is nearly as complex as the implementation.

**Seam** _(Michael Feathers)_: a place where behavior can be altered without editing there — the
*location* a module's interface lives. Where the seam goes is its own design decision, separate from
what sits behind it. _Avoid_: boundary (overloaded with DDD's bounded context).

**Adapter**: a concrete thing that satisfies an interface at a seam. Names a *role* (what slot it
fills), not a substance (what's inside).

**Leverage**: what callers get from depth — more capability per unit of interface learned. One
implementation pays back across N call sites and M tests.

**Locality**: what maintainers get from depth — change, bugs, and verification concentrate in one
place instead of spreading across callers. Fix once, fixed everywhere.

## Deep vs shallow

Deep module — small interface, lots of implementation behind it. Shallow module — large interface,
thin implementation that mostly passes calls through. When shaping an interface, ask:

- Can the number of methods shrink?
- Can the parameters simplify?
- Can more complexity move inside, out of the caller's view?

## Principles

- **Depth is a property of the interface, not the implementation.** A deep module can be internally
  composed of small, mockable, swappable parts — they just aren't part of the interface. A module
  can carry **internal seams** (private to its implementation, used by its own tests) as well as the
  **external seam** at its interface.
- **The deletion test.** Imagine deleting the module. If complexity vanishes, it was a pass-through.
  If complexity reappears across N callers, it was earning its keep.
- **The interface is the test surface.** Callers and tests cross the same seam. Needing to test
  *past* the interface is a sign the module is the wrong shape.
- **One adapter means a hypothetical seam. Two adapters means a real one.** Don't introduce a seam
  unless something actually varies across it.

## Designing for testability

- **Accept dependencies, don't create them.** A function that takes its collaborators as parameters
  is testable; one that constructs them internally (`new StripeGateway()` inside the function body)
  is not.
- **Return results, don't produce side effects.** A function that computes and returns a value is
  testable through its return; one that mutates shared state as its only output forces a test to
  inspect that state instead of the call.
- **Keep the surface small.** Fewer methods means fewer tests to write; fewer parameters means
  simpler test setup.
- **Test behavior at the seam, not structure.** Attach behavior tests at the module's interface, and
  add coverage at another level — unit, integration, contract, snapshot, end-to-end — only where
  that level protects a real requirement or regression. A test that mirrors implementation
  structure breaks on refactors that change no behavior.

## Rejected framings

- **Depth as a ratio of implementation-lines to interface-lines** (Ousterhout): rewards padding the
  implementation. Depth-as-leverage avoids that incentive.
- **"Interface" as a language's `interface` keyword or a class's public methods**: too narrow —
  interface here includes every fact a caller must know, not only the type-level surface.
- **"Boundary"**: overloaded with DDD's bounded context. Say **seam** or **interface**.
