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
shared: core (auth, storage, network, ui), app (router, theme, l10n)
```

- `domain` contains immutable models and repository contracts.
- `data` implements Misskey-backed repositories and owns wire-format mapping.
- `application` contains Riverpod controllers and provider definitions.
- `presentation` contains widgets and navigation calls.
- Features must not import another feature's `data` or `presentation` internals.
  Cross-feature reuse goes through a public domain/application provider.

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

## Failure handling

`mapFailure` converts SDK, HTTP, and timeout failures into `AppFailure` kinds.
Widgets render localized messages and never print request URLs or tokens.
