---
name: update-glossary
description: Use when the user defines a domain term, says "add this to the glossary" or "what do we call this", when one word is used in two senses or two words for one thing, or when another skill hands over terms to record. Also use when a term in `docs/GLOSSARY.md` no longer matches how the code or the user uses it.
---

# Update the glossary

`docs/GLOSSARY.md` gives each domain term one meaning, as the user confirmed it.

## Guardrails

**Write only `docs/GLOSSARY.md`.**

**Write a meaning only as the user confirmed it.** A name in the code shows that a term exists, not what it means.

**Leave every change uncommitted.** The user reviews the diff first.

## Process

### 1. Compare each term with the glossary

**Read `docs/GLOSSARY.md`, and sort each term you were given:**

- **New:** not in the glossary.
- **Same:** in the glossary with the same meaning. Skip it.
- **Conflict:** in the glossary with another meaning, or a second word for a term already there.

**Ask the user to settle each conflict and each new term without a confirmed meaning**, one numbered question per term, with the meaning you would write. A caller that ran an interview has already confirmed its terms.

Done when every new or conflicting term has a confirmed meaning, or the user dropped it.

### 2. Write the entries

**When `docs/GLOSSARY.md` is missing, start it from `templates/GLOSSARY.md` in this skill's folder, and delete its comments.**

**Write each entry in this shape, keeping the list in alphabetical order:**

```markdown
**Invoice** — the monthly bill for one customer. Not a receipt, which confirms a single payment.
```

**Name the term it is confused with, when there is one.** That line stops the next reader from mixing them up.

**Edit a conflicting entry in place.** Git keeps its history.

Done when each confirmed term has exactly one entry.

### 3. Report

**List each term as added, changed or skipped, with the reason for a skip.**

Done when the caller or the user has the list.
