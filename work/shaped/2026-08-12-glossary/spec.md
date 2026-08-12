# 2026-08-12-glossary — Shared domain language: glossary artifact and caretaker skill

## 1. Problem Statement

Agents and humans drift on domain vocabulary — the same concept surfaces as different words
across specs, tickets, tests, and code, and terms resolved in conversation are lost when the
session ends. The workflow has no owned home for a project's language. The workflow skills
being built now (shape exists; critique and review follow) have no vocabulary artifact to
reference.

## 2. Solution

A repo carries its canonical domain vocabulary in one glossary artifact: each term with a
tight definition and the synonyms to avoid. Any session captures a term the moment it
resolves in conversation, after the user confirms. Every session — workflow or ad hoc — uses
the glossary's vocabulary in its output and flags conflicts instead of silently drifting. In
a monorepo, domains carry their own glossaries, discoverable from the root one.

## 3. Behavioral Requirements

**The artifact**

BR-1: A repo's canonical vocabulary lives in `GLOSSARY.md` at the repo root. Each entry is
the term, a one-to-two-sentence definition of what it *is* (not what it does), and an
_Avoid_ list of rejected synonyms. The file holds vocabulary only — no implementation
details, no spec content, no scratch notes.

BR-2: Only terms specific to the project's domain qualify. General programming concepts
(timeouts, error types, utility patterns) are excluded even when heavily used.

BR-3: In a monorepo, each domain may carry its own `GLOSSARY.md` at the domain root. The
root file then holds cross-cutting terms plus a Domains section linking each sub-glossary
and stating the relationships between domains. There is no separate map file; the Domains
section exists only when sub-glossaries do.

BR-4: The glossary is mutable — edited in place, history is git's. A rename edits the entry
and moves the old term to _Avoid_. (Contrast: decision records are immutable-supersede.)

**Passive consumption**

BR-5: Agent output — prose artifacts (specs, tickets, test names, findings) and code
identifiers alike — uses glossary terms and never an avoided synonym. Code-identifier
adherence is judged at review; there is no mechanical gate.

BR-6: A repo without a glossary is handled silently — agents never nag to create one. A
*term* missing from a glossary that has entries is a signal: either the agent is inventing
language (reconsider) or there is a real gap (offer to capture it). An entry-less glossary
(a fresh scaffold) behaves like an absent one for this signal — capture works, the signal
stays quiet.

BR-7: A conflict between output and a glossary definition is flagged explicitly — named,
with both readings — never silently resolved in either direction.

BR-8: Glossary freshness is part of the per-ticket reconcile obligation: a change that
renames or redefines a term updates the affected glossary in the same PR. Spec approval at
the Plan gate is the confirmation for these mechanical updates; no fresh user confirmation
is required.

**Active capture**

BR-9: The `glossary` skill is the artifact's caretaker. It is model-invocable and triggers
when a conversation defines, disambiguates, or renames a domain term, or picks one word over
another — even when nobody says "glossary". It proposes the exact entry, writes only after
the user confirms, creates the file lazily from its template when absent, and reports only
the changed lines.

BR-10: The boundary with `decision` is stated on both sides: a naming or term choice is a
glossary entry, not a decision record; a term choice that encodes a contested architectural
trade-off routes to `decision`.

BR-11: The dialogue skills (`interview-me`, `shape`, `critique`) challenge language: a term
conflicting with the glossary is called out with both readings, and fuzzy or overloaded
terms get a proposed canonical term. These are pointers to the owned rule, not restatements.

**Installation**

BR-12: `setup` scaffolds a skeleton `GLOSSARY.md` from the same template the caretaker
uses, and the block it installs into the consuming repo's agent instructions carries a
one-line glossary pointer. Scaffolding is idempotent — an existing `GLOSSARY.md` is never
overwritten.

**Dogfooding**

BR-13: This repo carries its own root `GLOSSARY.md`, near-empty at birth: only terms no
other doc owns. Artifact terms (bundle, spec, ticket, backlog) stay owned by the workflow
doc. The repo's self-applied-conventions notes name it alongside the backlog.

## 4. Implementation Decisions

ID-1: One owner, three tiers. The full consumption rule (BR-5–BR-8) lives in the workflow
doc's artifacts section. The agents-reference block gets a single pointer line. Dialogue
skills get challenge pointers. Nothing restates the rule — the `docs-rules` drift precedent
holds.

ID-2: The caretaker mirrors the `backlog` skill's pattern: detecting description written to
the skill-mechanics rules, template under `assets/`, read-before-edit, confirmation before
write, changed-lines-only reporting.

ID-3: One template asset, owned by the `glossary` skill; `setup` copies it via
`${CLAUDE_PLUGIN_ROOT}`. The template is a bare scaffold — header, entry-format hint in
comment syntax, no preamble.

ID-4: No unified "should-record" meta-skill. Detection lives in the `glossary` and
`decision` descriptions. (Rejected: a meta-skill re-implements the platform's skill
selection one level up, must restate both artifacts' bars, and invites bypassing
`decision`'s interview protocol.)

ID-5: Root placement is a deliberate exception to decision 0009 (colocation), recorded as a
new decision record; the freshness argument colocation carried is replaced by the reconcile
obligation (BR-8).

ID-6: The unbuilt `review` skill inherits the rule by reading the workflow doc — the same
channel `critic` uses; its build-plan row gets a note. Nothing of review is built here.

ID-7: `setup`'s copy step still references the backlog template's pre-restructure location;
corrected in passing (one path).

## 5. Testing Decisions

Seam: none — confirmed with the human during shaping. This is a docs-and-skills repo; every
done-when is a deterministic file-state check (`test`/`grep`), and every acceptance
criterion is phrased against document state — the instruction that produces a behavior is
present and correct — never against runtime behavior. Behavioral verification — does the
caretaker trigger, do sessions actually adopt glossary vocabulary — needs reruns across
fresh sessions and is deferred to backlog lines per the writing-for-agents testing
protocol, matching the repo's existing precedent for skill-trigger verification.

## 6. Acceptance Criteria

AC-1 (BR-1, BR-9): Given the caretaker's body and template, when read, then the body
instructs lazy creation of root `GLOSSARY.md` from the template on the first confirmed
capture, and the template's entry format carries term, definition, and _Avoid_ list.

AC-2 (BR-5–BR-8): Given the workflow doc's artifacts section, when read, then it defines the
glossary artifact and the full consumption rule: vocabulary binds prose and code
identifiers, review judges identifiers, missing-glossary silence, missing-term signal,
conflict flagging, and reconcile ownership of freshness.

AC-3 (BR-9): Given the `glossary` skill, when its frontmatter is read, then the description
names concrete trigger symptoms (a term defined, disambiguated, renamed, or one word picked
over another, "even when they don't say glossary") and the skill is model-invocable; the
body requires user confirmation before any write.

AC-4 (BR-10): Given the `glossary` and `decision` skills, when either body is read, then it
states its side of the term-choice boundary.

AC-5 (BR-11): Given `interview-me`, `shape`, and the critic's instructions, when read, then
each carries a glossary challenge pointer and none restates the consumption rule.

AC-6 (BR-12): Given `setup`'s write step, when read, then it instructs copying the
caretaker's template to root `GLOSSARY.md`, skipping when one exists, and the
agents-reference block it installs contains the glossary pointer line.

AC-7 (BR-3): Given the template and the caretaker's instructions, when read, then the
monorepo form is documented: per-domain glossaries, root Domains section with
relationships, no separate map file.

AC-8 (BR-13, ID-5): Given this repo's root, when inspected, then `GLOSSARY.md` exists
holding only terms no other doc owns, a decision record for the root-placement exception
exists, and the self-applied-conventions notes name the glossary as dogfooded.

AC-9 (BR-2, BR-4): Given the caretaker's body and template, when read, then the domain-only
bar (general programming concepts excluded) and the rename rule (edit in place, the old
term moves to _Avoid_) are both stated.

## 7. Out of Scope

- Building the `review` skill or `reviewer` agent — its build-plan row gets one note, nothing more.
- A unified "should-record" meta-skill (ID-4).
- Migrating the workflow doc's artifact definitions into the dogfooded glossary — artifact terms stay owned by the workflow doc.
- Behavioral trigger testing — recorded as backlog lines, not performed in this bundle.
- Per-package `work/` trees and any packaging or distribution changes beyond the files named by the tickets.
- Moving `decision`/`shape` fill-in templates to `assets/` — an existing backlog line owns that; only `setup`'s stale backlog-template path is fixed here (ID-7).
- Any separate glossary map file.
- Mechanical (CI/hook) enforcement of vocabulary use.
