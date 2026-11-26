# Test-driven development

The red–green loop for building behavior test-first, and what makes a test worth keeping. The
ticket's `Pre-change evidence` line names the seam and the first red.

## The loop

- **Red before green.** Write one failing test at the seam and run it before writing any
  implementation. Watch it fail for the expected reason — a test that never failed proves nothing
  about the code that follows.
- **Green minimally.** Write only enough implementation to pass the test in front of you. Structure
  built for tests not yet written is speculation the next cycle usually contradicts.
- **One slice per cycle.** One test, one minimal implementation. Pick the next test from what this
  cycle taught — the next unproven behavior — not from a list drawn up before the first cycle ran.
- **Refactor between cycles, under passing tests**, never with a red test on the board.

## What makes a test worth keeping

- **It reads like a specification.** Its name states the capability, and its body exercises it
  through the seam's public interface, not through internals a refactor would move.
- **Its expected values come from an independent source** — a known-good literal, a worked example,
  the spec. An assertion that recomputes the expectation the way the code does
  (`assert add(a, b) == a + b`) passes by construction and can never disagree with the code.

## Slice vertically

Writing all tests first and all implementation after verifies imagined behavior and fixes the test
structure before the implementation has taught anything. Work one cycle at a time. A locked
acceptance test run unchanged is not this anti-pattern: it supplies red evidence, and the loop
governs the tests you write inside it.
