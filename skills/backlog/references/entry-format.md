# Entry format and tag discipline

The shape of a backlog line, with worked examples, and the judgment calls around tags.

## The line

One line, imperative, under about twelve words:

```text
- [tag] short imperative phrase
```

**Write the problem, not your proposed solution.** The solution is what the planning
conversation is for, and a solution written now will be stale or wrong by the time it's read.

Sub-bullets are allowed only when the line is meaningless without them, and never more than
two. They capture constraints or evidence, not implementation plans.

**Good:**

```text
- [server] no transaction support — repository ops can't run atomically
- [api] bulk-op contract makes the client send server-owned scope fields
- [core][client] list endpoints each hand-split searchParams into filters/pagination
- [ui] date-range filters can't map to contract keys like startDate/endDate
```

**Too much:**

```text
- [auth] Implement refresh token rotation
  - Add a `token_families` table with columns id, user_id, created_at
  - On refresh, issue a new token and mark the old one used
  - If a used token is presented again, invalidate the whole family
  - Consider a 10s grace window for in-flight requests
```

That's a plan. Say so, and offer to run `shape` on it instead.

**Too vague:**

```text
- [ui] improve components
- [server] performance
```

An entry that won't mean anything in three weeks is worse than no entry, because it occupies a
line and creates a small obligation to work out what it meant. Ask for one concrete detail
rather than writing a placeholder.

## Tag discipline

Usage is a subset of what's valid — if nobody has filed a `duckdb` item yet, looking at prior
use finds nothing and invites a plausible-sounding substitute like `[db]` or `[sql]`. Synonyms
are the specific failure the computed vocabulary prevents: once `[db]`, `[database]` and
`[duckdb]` coexist, every grep silently misses most of the matching items, and nothing about
the file looks wrong.

If an item genuinely fits no tag and isn't infra or workflow, ask rather than coining one. In
practice that combination usually means the item is scoped wrong — it's really two items, or a
work item — not that the vocabulary has a gap.

Multiple tags are fine when an item genuinely spans areas: `- [core][client] ...`. Two is
usually the honest maximum; if you're reaching for three, the item is probably a work item,
not a backlog line.
