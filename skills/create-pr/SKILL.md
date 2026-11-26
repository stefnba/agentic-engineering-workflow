---
name: create-pr
description: Use when users ask to create, open, submit, or publish a pull request for this repository, including requests for a PR title or description. Do not use for review-only or validation-only work that does not need PR content.
---

# Create a pull request

Leave a focused change with an accurate PR description, or publish it when the user has authorized the remote actions.

## Guardrails

- Read `docs/conventions/git.md` before writing a title or creating a branch, commit, or pull request; its Pull Requests section defines an initiative pull request and owns the title, template, and label rules.
- Preserve unrelated working-tree changes; do not stage, commit, or publish them.
- Treat a request for a title or description as drafting authority only. Push or open a pull request only after an explicit request to create, open, submit, or publish it.

## Process

### 1. Establish the PR scope

Inspect the branch, working tree, commit history, and diff against the intended base branch. Define the PR from its reviewable change, not from every commit already on the branch.

**Separate mixed history.** When the branch contains independent changes, ask the user to choose a combined PR or separate PRs unless the requested scope already makes that choice clear. For discrete selected commits, create the PR branch from the intended base with only those commits. When a commit interleaves selected and unselected work, ask before rewriting history or reconstructing the change.

**Classify the pull request** by the initiative pull request definition in `git.md`, Pull Requests.

**Done when** the base branch is named, the kind of pull request is decided, and every commit and working-tree change is either inside the PR scope or explicitly excluded.

### 2. Make the change reviewable

Review the scoped diff and run the smallest validation that covers it.

**Done when** every validation command is recorded with its result, or listed as not run with the reason.

### 3. Prepare the PR content

Title the pull request and fill the template for its kind as `git.md`, Pull Requests specifies, deleting each slot comment as you fill it.

**Done when** the title follows the convention, every template section holds concrete content or is omitted where its comment permits, and no comment remains.

### 4. Commit and publish when authorized

**Draft only.** When the user requested only PR content, return the title, body, validation, and limitations without staging, committing, pushing, or opening a PR.

**Publish.** When the user explicitly requested a PR, commit only the scoped change, push the branch, and create the pull request with the authenticated GitHub CLI. Pass `--label initiative` for an initiative pull request. Report an unavailable or unauthenticated CLI as a blocker; do not substitute another publishing route.

**Done when** the user has the title, body, validation, and limitations for a draft-only request, or GitHub has returned the pull request URL for a publish request.

## Checklist

- [ ] The PR has one explicit scope and excludes unrelated work.
- [ ] The title and template body describe the change, validation, and limitations.
- [ ] An initiative PR uses the initiative template and carries the `initiative` label.
- [ ] A published PR has a returned URL.
