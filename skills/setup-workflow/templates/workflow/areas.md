<!-- Fill every slot; delete these comments as you fill. -->

# Areas

Each directory that is built or tested on its own, with its checks. Written by the `setup-workflow` skill; edit by hand or rerun that skill.

**Run every check of the work item's area before opening a pull request.** A failing check blocks the pull request.

**Run each check from its area's path, unless the check names another directory.**

<!-- One row per area. A repository with one app has one row with path `.`.
Checks: the exact commands as CI runs them. When CI runs one from another
directory, prefix it with that directory, such as `(root) pnpm --filter web
test`. Docs: the area's own docs folder, or `none`. Example row:
| client | `apps/client` | `area:client` | `npm test`, `npm run lint` | none | -->

| Area     | Path       | Label           | Checks     | Docs     |
| -------- | ---------- | --------------- | ---------- | -------- |
| {{AREA}} | `{{PATH}}` | `area:{{AREA}}` | {{CHECKS}} | {{DOCS}} |
