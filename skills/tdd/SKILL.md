---
name: tdd
description: The red–green discipline for building behavior test-first — cycle rules, what makes a test worth keeping, and the anti-patterns that fake coverage. Binding for the implement-ticket skill wherever a ticket adds or changes behavior. Invoke or read it when implementing a feature or bug fix, choosing the next test to write, judging whether a test could ever fail, or noticing tests that break under refactor while behavior holds.
---

# Test-driven development

Build behavior in red–green cycles: one failing test, the minimal change that passes it, repeat.
Take the seam and the first red from the contract that precedes the work — a ticket's
`Pre-change evidence` where one is in play; with no ticket, agree the seam with the user before
writing the first test.

## The loop

- **Red before green.** Write one failing test at the agreed seam and run it before writing any
  implementation. Observe it fail for the expected reason — a test that never failed proves nothing
  about the code that follows.
- **Green minimally.** Write only enough implementation to pass the test in front of you. Structure
  built for tests not yet written is speculation the next cycle usually contradicts.
- **One slice per cycle.** One test, one minimal implementation. Pick the next test from what this
  cycle taught — a tracer bullet through the next unproven behavior — not from a list drawn up
  before the first cycle ran.
- **Refactor between cycles, under passing tests** — never mid-cycle with a red test on the board.

## What makes a test worth keeping

- **It reads like a specification.** The name states the capability, and the body exercises it
  through the seam's interface. Read the `code-design` skill's "Designing for testability" section
  before attaching a test anywhere other than that interface.
- **Its expected values come from an independent source.** A known-good literal, a worked example,
  the spec — an assertion that recomputes the expectation the way the code does
  (`expect(add(a, b)).toBe(a + b)`) passes by construction and can never disagree with the code.

## Anti-pattern: horizontal slicing

Writing all tests first and all implementation after verifies imagined behavior and commits to test
structure before the implementation teaches anything. Work in vertical slices, one cycle at a time.
A separately authored acceptance suite run unchanged is not this anti-pattern — it supplies red
evidence; the slicing rule governs the tests written inside the loop.
