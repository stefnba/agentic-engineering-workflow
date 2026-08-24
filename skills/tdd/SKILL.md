---
name: tdd
description: The red–green discipline for building behavior test-first — cycle rules, what makes a test worth keeping, and the anti-patterns that fake coverage. Binding for the implement-ticket skill wherever a ticket adds or changes behavior. Invoke or read it when implementing a feature or bug fix, choosing the next test to write, judging whether a test could ever fail, or noticing tests that break under refactor while behavior holds.
---

# Test-driven development

Build behavior in red–green cycles: one failing test, the minimal change that passes it, repeat.
Take the seam and the first failing test from the ticket's `Pre-change evidence` — the Plan gate
decided both, and the loop starts after that first observed red, never by choosing its own.

## The loop

- **Red before green.** Write one failing test at the approved seam and run it before writing any
  implementation. Observe it fail for the expected reason — a test that never failed proves nothing
  about the code that follows.
- **Green minimally.** Write only enough implementation to pass the test in front of you. Structure
  built for tests not yet written is speculation the next cycle usually contradicts.
- **One slice per cycle.** One test, one minimal implementation. Pick the next test from what this
  cycle taught — a tracer bullet through the next unproven behavior — not from a list drawn up
  before the first cycle ran.
- **Refactor between cycles, while green.** Reshape only under passing tests, and only within the
  ticket's scope. When the reshaping touches a module seam, read the `code-design` skill first.

## What makes a test worth keeping

- **It exercises behavior through the seam's public interface.** It reads like a specification —
  the name states the capability — and it survives a refactor of everything behind the interface.
- **Its expected values come from an independent source**: a known-good literal, a worked example,
  the spec. An assertion that recomputes the expectation the way the code does passes by
  construction and can never disagree with the code.

## Anti-patterns

- **Implementation-coupled**: mocks internal collaborators, asserts private state, or verifies
  through a side channel instead of the interface. The tell: the test breaks under refactor while
  behavior holds.
- **Tautological**: the expected value is derived by the same computation as the actual —
  `expect(add(a, b)).toBe(a + b)`, a hand-derived snapshot, a constant asserted against itself.
- **Horizontal slicing**: all tests written first, then all implementation. Bulk tests verify
  imagined behavior and commit to test structure before the implementation teaches anything —
  work in vertical slices instead, one cycle at a time.
