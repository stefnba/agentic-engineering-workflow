# Workflow

```text
discover ⇄ shape                      gate: human picks the candidate
    ↓
  shape                               gate: Open questions resolved
    ↓                                       + human approves the decomposition
implement ⇄ verify        per ticket  gate: done-when commands pass (agent)
    ↓                                       + reconcile diff in the same PR
review → fix → re-verify ↺            gate: human approves
    ↓
  ship                                gate: durable docs absorbed,
                                            bundle deleted, main green
```

```text
User Request
      │
      ▼
┌────────────────────┐
│ Planning Agent     │
│ - Requirements     │
│ - Architecture     │
│ - Task breakdown   │
│ - Acceptance tests │
└────────────────────┘
          │
          ▼
┌────────────────────┐
│ Implementation     │
│ - One task only    │
│ - Code + tests     │
│ - Minimal changes  │
└────────────────────┘
          │
          ▼
┌────────────────────┐
│ Staff Reviewer     │
│ - Correctness      │
│ - Architecture     │
│ - Security         │
│ - Performance      │
│ - Testing          │
└────────────────────┘
          │
          ▼
 Merge / Iterate

```

1. Spec → 2. Plan → 3. Tickets → 4. Implementation
