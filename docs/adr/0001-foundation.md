# ADR 0001: Foundation Choices

## Status

Accepted for the rewrite foundation.

## Decisions

- **Riverpod 3 with generation.** Providers are described by annotations and the
  generated files are committed. This keeps dependency wiring testable and lets
  account-scoped providers rebuild when the active client changes.
- **Typed go_router routes.** `go_router_builder` generates route data. The
  shell keeps five fixed branch indices so settings can reorder/hide destinations
  without changing router state.
- **Drift for cache and drafts.** A single SQLite database stores account
  metadata, account-scoped JSON cache entries, and one composer draft per
  account. Web uses the committed WASM worker.
- **Platform secure storage for tokens.** Tokens never enter Drift or shared
  preferences. Web secure storage is browser storage, not an OS keychain.
- **`misskey_dart_api` as the API surface.** Typed SDK models are reused rather
  than duplicated into app DTOs.
- **media_kit for video.** It is the single video backend for notes and chat.
- **Plain-text notes in this slice.** `NoteContent` renders text with URL and
  hashtag links. It is the replacement point for a future MFM renderer.

## Consequences

- Generated code increases diff size but keeps the public API deterministic.
- Drift schema changes require explicit migrations; version 1 uses `createAll`
  only.
- Account switching invalidates auto-dispose providers and closes the previous
  streaming client.
- Offline behavior is read-only for cached content and drafts; mutations fail
  visibly rather than entering an outbox.
