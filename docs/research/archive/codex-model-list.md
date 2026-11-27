# Model lists in the Codex CLI

For a reader who wants facts only: in the latest stable Codex CLI release, does `codex debug models` list the same models an account can pick in `/model`? This note records what the sources show and proposes nothing.

Sources and method: Codex CLI 0.172.0 (tag `rust-v0.172.0`), released 2026-11-24, the latest release that is not a pre-release in `gh release list -R openai/codex`. One research subagent read the source of github.com/openai/codex at commit `3d86e43` (2026-11-23) on 2026-11-27 and reopened the sources its answer depends on. It ran no command and did not read the changelog or the Codex docs. This was a quick-level run, so no separate checker ran. Paths are relative to that repository.

Tags:

- `[read]`: seen in a file, page or issue.
- `[tested]`: a command was run and its result observed.
- `[reported]`: a source's claim about something else, not observed here.
- `[inferred]`: a conclusion drawn from the claims it names.
- `[unverified]`: a claim whose source could not be reopened in the check.

## Summary

- **Both commands start from the same catalog**: the cached or fetched server list, merged with or replacing the bundled one `[read]`.
- **`/model` filters that catalog; `debug models` does not** `[read]`. So `debug models` can list hidden models, and for API-key accounts models not marked API-supported, that `/model` leaves out `[inferred]`.
- **`debug models --bundled` shows only the catalog shipped in the binary**, which can lack models the server offers `[inferred]`.

## `codex debug models`

- It prints one JSON `ModelsResponse` to stdout `[read]` `codex-rs/cli/src/main.rs:2287`.
- With `--bundled`, it prints the catalog bundled with the binary and does not refresh it `[read]` `main.rs:315-317, 2252-2253`.
- Without `--bundled`, it calls `raw_model_catalog(RefreshStrategy::OnlineIfUncached)` `[read]` `main.rs:2254-2284`.
- `OnlineIfUncached` uses `models_cache.json` when it is present and fresh, and otherwise fetches the `/models` endpoint `[read]` `codex-rs/models-manager/src/manager.rs:41, 121-122, 817-821`.
- When the server list holds a picker-visible model and the account is ChatGPT, or API-key discovery is on, the server list replaces the bundled one. Otherwise the server models are merged over the bundled ones by slug `[read]` `manager.rs:978-998`.
- `raw_model_catalog` returns every entry, with no visibility or auth filter `[read]` `manager.rs:217-233`.

## The `/model` picker

- The TUI sends `model/list` to the app server with `include_hidden: Some(true)` `[read]` `codex-rs/tui/src/app_server_session/models.rs:47-55`.
- The server handler uses the same `OnlineIfUncached` strategy `[read]` `codex-rs/app-server/src/request_processors/catalog_processor.rs:302-323`.
- `list_models` sorts the raw catalog by priority, then applies `filter_by_auth`. Without ChatGPT auth, that filter drops models not marked `supported_in_api` `[read]` `manager.rs:197-208, 264-276`; `codex-rs/protocol/src/openai_models.rs:1158-1167`.
- A model gets `show_in_picker` only when its visibility is `List` `[read]` `openai_models.rs:1118`.
- The popup shows only `show_in_picker` models, and one view also drops "auto" models `[read]` `codex-rs/tui/src/chatwidget/model_popups.rs:115, 254`.
- The picker can show models the bundled catalog lacks, because its source is the server catalog `[inferred]` from the merge logic and the picker path above.

## Differences between the two lists

- `debug models` lists the raw catalog, and `/model` lists it after the auth and visibility filters `[inferred]` from `raw_model_catalog`, `filter_by_auth` and `show_in_picker` above.
- The two run as separate processes. A cache refresh or expiry between them can change either list `[inferred]` from `OnlineIfUncached`.

## Not settled

- Issues whose titles look related were found but not opened, so none is a source here: openai/codex#56528, #54571, #51308, #53219 and #43705.
- The 0.172.0 changelog and the Codex docs were not read.
- Nothing was run, so no claim is `[tested]`.
