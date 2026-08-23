# Field-test prompts

Prompts for exercising this workflow in a minimal consuming repo — a Hono TypeScript app with a
single GET endpoint returning ok. Run them in that repo (with the plugin installed), not here.
Grouped by what part of the workflow each one stresses; start at the top and escalate.

Suggested order: health endpoint first (smoke test), the todos bundle second (the real test), then
the ambiguity prompts — those show whether the workflow's gates fire when they should.

## Single-ticket, end-to-end smoke test

- **"Add a `/health` endpoint returning `{ status, uptime }` as JSON, with a test."**
  Smallest possible shape → implement → review → land pass. If this takes more than one session,
  the workflow has overhead problems.
- **"Add request logging middleware that logs method, path, status, and duration."**
  Tests whether trivial work gets over-bundled.

## Multi-ticket bundle and slicing

- **"Add a todos API: POST /todos, GET /todos, GET /todos/:id, in-memory store, zod validation."**
  Forces real slicing decisions (storage seam vs routes vs validation), ticket dependencies, and
  gives the critic something to attack.
- **"Add API-key auth middleware; protected routes return 401 without a valid key."**
  Introduces a seam plus a config question (where keys live) — tests `code-design` and whether a
  decision record gets proposed.

## Ambiguity and stop-and-ask

- **"Make the API production ready."**
  Deliberately vague. Good outcome: the agent asks what that means or shapes a bundle with explicit
  open questions, instead of inventing scope.
- **"Add rate limiting."**
  Underspecified (per-IP? per-key? library vs hand-rolled?) — should trigger the judge skill or a
  clarifying question, not a silent pick.

## Individual skills in isolation

- **Judge:** "What's the best way to structure error handling in this Hono app — throw + onError,
  Result types, or per-route try/catch? Give me your independent take."
- **Record-decision:** after the judge picks, "document that decision."
- **Backlog:** mid-task, "I noticed we have no CI — note that for later." Tests that it becomes a
  backlog line, not a detour.
- **Review, adversarially:** implement the todos API yourself with a planted bug (e.g.
  GET /todos/:id returns 200 for missing ids), then ask for a review round — checks the reviewer
  catches it rather than rubber-stamping.
- **Recap/handoff:** after the todos bundle, "catch me up" in the same session, then "write a
  handoff" and start a fresh session from it — tests whether a cold agent can resume.
