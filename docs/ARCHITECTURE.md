# Architecture

Nyachi uses a feature-first Flutter structure with lightweight layers. Features
own their domain, data, application, and presentation code; shared infrastructure
lives in `lib/core` and application composition lives in `lib/app`.

## Dependency direction

```text
presentation -> application -> domain
                    |             ^
                    v             |
                  data -----------+
shared: core (auth, storage, network, ui, l10n), app (router, theme, detail panel)
```

- `domain` contains immutable models and repository contracts.
- `data` implements Misskey-backed repositories and owns wire-format mapping.
- `application` contains Riverpod controllers and provider definitions.
- `presentation` contains widgets and navigation calls.
- Features must not import another feature's `data` or `presentation` internals.
  Cross-feature reuse goes through a public domain/application provider.

### Shared note rendering (documented exception)

`NoteCard`, `NoteContent`, and `NoteMedia` are the feed rendering layer shared
by the timeline, explore, profile, chat, and tag features. They stay in
`features/notes/presentation/` because they open detail views through
`openDetail`/`DetailLocation`, which is part of the app-level composition layer
(`lib/app/detail_panel/`). Sinking them into `core/` would make `core` depend on
`app`, inverting the dependency direction. Cross-feature imports of these
widgets are therefore allowed; contracts (repository interfaces) still live in
each feature's `domain/`.

## Authentication and session

- `SessionController` is process-wide and holds the account list, the active
  account, and initialization state.
- Accounts are rows in Drift keyed by `(host, userId)`. Tokens live only in
  `flutter_secure_storage` under `nyachi.token.<accountId>`.
- The Misskey client is created from the active account and resolves its token
  lazily. Switching accounts invalidates the client provider, which closes the
  old HTTP client and streaming connection.
- The router refreshes on session changes and enforces the auth gate. The root
  widget does not construct the router until bootstrap has completed.
- MiAuth and manual token login both validate the token with `account.me()`
  before saving an account.

## Storage and cache

Drift owns three tables:

| Table | Purpose |
|---|---|
| `Accounts` | Local account metadata, unique by host and user id |
| `CacheEntries` | Account-scoped JSON payloads with timestamps |
| `Drafts` | One composer draft per account |

Cache keys are explicit and account-scoped by the DAO composite key. Note and
notification feeds keep at most 50 cached notes/notifications. Reads fall back to
cache on network failure; write operations are never queued while offline.

## Streaming

`HomeStreamService` owns one Misskey streaming client and subscribes to the home
timeline only. It reconnects with bounded exponential backoff, pauses while the
app is backgrounded, and is disposed with its provider. Timeline controllers
insert live notes idempotently; other timelines do not stream.

## Routing

Routes are declared with `go_router_builder` in `lib/app/router/routes.dart`.
The shell has five fixed branch indices (`home`, `notifications`, `explore`,
`chat`, `profile`) while display order and visibility come from settings.

On wide screens, shell detail pages open in a resizable right-hand panel while
the current tab stays visible. The panel stack is mirrored in a `detail` query
parameter on the tab-root URL (top location only); panel navigation uses
`router.replace`, so it does not add browser-history entries. The breakpoint is
stored as `layout.detailBreakpoint` and the panel width as
`layout.detailPanelWidth`. Direct detail paths remain full-page, and dropping
below the breakpoint converts the current panel top into a full-page route.
Feature widgets open detail pages through `openDetail` with a `DetailLocation`,
never by calling `context.push` for shell detail routes.

Settings is a main page inside the shell: the sidebar entry pushes
`/settings` (shell navigator), the settings list keeps the rail visible, and
`/settings` is treated as a tab root by the detail-panel machinery so each
sub-page opens beside the list (double column on wide screens).

## Failure handling

`mapFailure` converts SDK, HTTP, and timeout failures into `AppFailure` kinds.
Widgets render localized messages and never print request URLs or tokens.
