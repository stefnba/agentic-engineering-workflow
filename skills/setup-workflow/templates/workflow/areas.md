<!-- Fill every slot; delete these comments as you fill. -->

# Areas

Each directory that is built or tested on its own, with its checks. Written by the `setup-workflow` skill; edit by hand or rerun that skill.

**Run every check of the work item's area, from the directory in its Run from cell, before opening a pull request.** A failing check blocks the pull request.

<!-- One row per area. A repository with one app has one row with path `.`.
Checks: the exact commands as CI runs them, or `none`. Run from: the
directory the checks run from, `.` for the root, or `none` without checks. Docs: the area's own docs
folder, or `none`. Example row:
| web | `apps/web` | `area:web` | `pnpm --filter web test`, `pnpm --filter web lint` | `.` | none | -->

| Area     | Path       | Label           | Checks     | Run from       | Docs     |
| -------- | ---------- | --------------- | ---------- | -------------- | -------- |
| {{AREA}} | `{{PATH}}` | `area:{{AREA}}` | {{CHECKS}} | `{{RUN_FROM}}` | {{DOCS}} |
