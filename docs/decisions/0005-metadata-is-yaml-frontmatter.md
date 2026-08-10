---
status: accepted
date: 2026-08-10
areas: [docs, skills]
---

# 0005 Document metadata is YAML frontmatter, present only where something reads it

## Context

Metadata syntax had drifted three ways: tickets used YAML frontmatter, decision records used a prose byline (`Date: … · Status: … · Areas: …`) introduced by the decision skill, and research files used ad-hoc bylines — while docs-structure's own decisions template had specified frontmatter all along. Every query tool, skill, or consistency sweep would have needed a parser per syntax, forever.

## Decision

Where a document carries metadata, the syntax is YAML frontmatter — one syntax, one parser, repo-wide. And a document carries metadata **only if something reads it**: tickets (`status`, `depends_on`), decisions (`status`, `date`, `areas`, `supersedes`/`superseded_by` when overturning), research (`date`, `source`). Briefs and specs carry none: nothing machine-reads them, the directory owns bundle status (decision 0004), and an unused metadata block invites a second status owner. Superseding a record edits only its frontmatter `status` lines. Existing records and research files were mechanically reformatted once — immutability protects the reasoning, not the byline syntax, and that carve-out is stated here rather than assumed.

## Rejected

- **The prose byline**: human-pretty, machine-hostile — its only advantage was rendered aesthetics, and frontmatter renders acceptably on GitHub anyway.
- **Per-type syntax freedom (status quo)**: N parsers for N doc types, and the drift was accidental, not chosen.
- **Frontmatter everywhere, including briefs/specs**: empty metadata is noise, and a `status:` field on a spec would compete with the directory as status owner — the exact two-places failure.

## Costs

- Frontmatter above the H1 pushes the title one screen-line down in every metadata-carrying file.
- The immutability carve-out (mechanical reformat allowed once) slightly softens "never edited" and could be cited as precedent; the boundary is syntax-only changes with reasoning untouched.
- The tooling-parseable subset of YAML must stay simple — flow arrays and scalars, nothing the query script's documented subset excludes.

## Revisit if

- A consuming ecosystem (static site generator, issue sync) demands a different metadata carrier.
- The "only where read" rule leaves a doc type unqueryable right when a real query need appears — add the fields then, not preemptively.
