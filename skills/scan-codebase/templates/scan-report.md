<!-- Scan report, delivered as the final message — never written to a file. Fill every slot;
delete these comments as you fill. Findings in rank order. A finding that needs more than its
four lines is two findings, or its evidence isn't distilled yet. -->

## Scan: <scope> — <n> findings (<n> high, <n> medium, <n> low)

Covered: <!-- paths and dimensions swept, ≤2 lines -->
Skipped: <!-- what and why, one line; drop the line if nothing was skipped -->

<!-- One block per finding. Tiers: HIGH — can already misfire (a gate that passes wrongly,
callers that disagree) or sits where upcoming work lands; MEDIUM — every change through this
code pays for it, but nothing misfires today; LOW — real but cheap to defer. -->

### <rank>. <TIER> — <claim: what is wrong, not what to do> — `path:line`

- Evidence: <!-- ≤2 lines; the verified observation, plus the other `path:line` when it spans files -->
- Cost: <!-- one line: what it breaks, slows, or risks -->
- Fix shape: <!-- one line: a direction, never a design -->

Nothing was recorded — each finding awaits your accept-or-reject.
