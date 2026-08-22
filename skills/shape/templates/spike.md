<!--
The intent artifact for the "investigation or spike" route: what question is open, what evidence
would settle it, and what decision the answer feeds. Copy it into the bundle as spike.md. The other
routes use spec.md, or the ticket itself on the direct ticket route.

The deliverable is evidence and a decision, never production code disguised as exploration. "Do not
proceed" is a successful result. Nothing here authorizes the implementation the answer might
recommend: the human picks that separately, and it is shaped as its own bundle.

Fill every retained section and delete these guidance comments as you go. This file is the brief the
investigation runs against — the answer it produces is reported to the human and lands in the
artifact that owns it, never appended here: this bundle is deleted at Land. The Routing section
below decides where each result goes.
-->

# <bundle-id> — Investigation: <the question in a few words>

## Question

<!-- One decision-forcing question, stated so that an answer is possible and so that both a yes and a
no would change what happens next. "Investigate the slow endpoint" is not a question; "which of the
three calls in the checkout path accounts for the p95 regression" is.

Split a compound question into a primary question and the sub-questions below it, or into two
investigations. -->

<question>

## Why it is open

<!-- What is unknown and why the repository, its docs, and its history do not already answer it —
including what was already checked. This is what keeps an investigation from re-deriving a fact
someone can look up, and it is the section a critic attacks first. -->

<what was already checked, and what it left unresolved>

## Candidate answers

<!-- Optional. The hypotheses or options being weighed, each with what would confirm or kill it.
Writing them down keeps the investigation from stopping at the first plausible story.

Example:
- H1: the regression is the N+1 in the pricing loop — killed if p95 holds with the loop stubbed
- H2: it is connection-pool starvation under concurrency — confirmed if latency tracks pool wait time -->

- <hypothesis or option> — <what would confirm it; what would kill it>

## Evidence that settles it

<!-- Numbered, so that whatever runs this investigation can report against them one by one. Where the
section above says what each hypothesis predicts, this one sets the bar the whole investigation is
measured against: what counts as conclusive, over what sample, against which baseline — and what
result means "we still do not know" rather than "no".

Do not restate the kill conditions above. If a hypothesis's kill condition is the bar, reference it
by ID and add only the threshold.

Example:
E-2: p99 over 10k checkout requests at production concurrency, with and without the H1 loop stubbed —
conclusive if the two differ by more than 50 ms, inconclusive if the run cannot reach that
concurrency. -->

- E-1: <the bar for a conclusive answer> — <sample, baseline, threshold>

## Method and budget

<!-- What will be read, run, measured, or prototyped, and the time box. The box is a stop condition,
not an estimate: at the limit the investigation reports what it has, including "inconclusive", rather
than continuing until it finds something.

Name the environment where a measurement is trustworthy — a benchmark on the wrong hardware or a
reproduction on the wrong data answers a different question.

An investigation can itself be a production change: sampling, replayed traffic, a feature flag, a
load generator. Say so under blast radius, because the human approving this spike is approving that
too. -->

- Method: <what will be read, run, or built>
- Environment: <where a measurement here is trustworthy, and what makes it so>
- Budget: <sessions, hours, or attempts — and what happens at the limit>
- Blast radius: <what running this touches in a live system, and whose approval that needs — or none>

## Non-goals

<!-- The prohibitions that keep a spike a spike. Keep the first two unless a deliberate exception is
approved. -->

- No production code and no refactor: prototype code proves the answer and is thrown away, never
  merged as a side effect of investigating.
- Do not fix what the investigation uncovers — a finding becomes a backlog line, not an in-flight
  change.
- <scope this investigation deliberately leaves out>

## Decision this feeds

<!-- The choices the human will face once the evidence exists, so the report answers the actual
decision instead of narrating what was tried. Include the option of not proceeding. -->

- <proceed with option A> — <what the evidence would have to show>
- <proceed with option B> — <what the evidence would have to show>
- Do not proceed — <what the evidence would have to show>

## References

<!-- Optional. Dashboards, incident timestamps, log or trace queries, prior research, the durable doc
that is suspected of being stale. Links and identifiers, so the investigation starts where the last
one stopped — "Why it is open" is the argument, not the link list. -->

- <link or identifier> — <what it shows>

## Where the answer lands

<!-- Decided here, at Shape, so the result is not stranded in a file Land deletes. Name the owner for
each kind of result this investigation can produce — durable reference material, a durable choice,
follow-up work, or a recommendation the human picks next. Which artifact takes which is defined in
${CLAUDE_PLUGIN_ROOT}/workflow/artifacts.md; name them here, do not restate the rule. -->

- <kind of result> → <the artifact that will own it>
