# Cache management plan

## Goal

One canonical owner for locally persisted cache keys plus a settings page
that shows and clears the managed caches, so caches stop being invisible
and bulk clears can never drift from the keys repositories write.

## Current state (verified, with file:line references)

- Storage: `CacheEntries` table keyed by `(accountId, cacheKey)` with
  `payload`/`updatedAt`
  (`lib/core/storage/app_database.dart:43-52`). `CacheDao` offers
  per-account `read`/`write`/`deleteKey`/`deleteAccount`
  (`lib/core/storage/app_database.dart:169-242`); no stats, no bulk
  per-key delete, no clear-all.
- Callers each own a private key literal:
  - Instance metadata + drafts probe: `'meta'` and `'meta.scheduledNotes'`
    (`lib/core/network/instance_repository.dart:72-73`).
  - Emoji catalogue: `'emoji'`
    (`lib/features/notes/application/emoji_catalog.dart:32`).
  - Notifications (latest 50): `'notifications'`
    (`lib/features/notifications/application/notification_list_controller.dart:33`).
  - Feed snapshots use `NoteFeedSource.cacheKey` (e.g. `timeline:home`).
- Settings (`lib/features/settings/presentation/settings_page.dart`) has no
  cache surface: nothing shows what is stored or lets a user clear it.

## Decisions

- One `CacheManager` owns the canonical key constants and all bulk
  operations; repositories keep per-account reads/writes on `CacheDao` but
  take their key constants from `CacheManager`.
- Managed kinds: `instanceMeta`, `emojiCatalog`, `notifications`. Feed
  snapshots are not a managed kind — they are not shown per kind but are
  wiped by "clear all".
- A settings page lists per-kind entry count and byte size with per-kind
  clear and a clear-all; clearing also invalidates the in-memory providers
  so the next access refetches.
- Byte size is measured in the database (`LENGTH(CAST(payload AS BLOB))`),
  not by loading payloads into Dart.

## Design

- `lib/core/cache/cache_manager.dart`:
  `enum CacheKind { instanceMeta, emojiCatalog, notifications }`,
  `CacheKindStats` (`entries`, `bytes`), `CacheManager` with the key
  constants, `statsAll()`, `entryCount(kind)`, `byteSize(kind)`,
  `clear(kind)`, `clearAll()`, and the keepAlive `cacheManagerProvider`.
- `CacheDao` gains `statsByKey()` (SQL aggregation grouped by `cache_key`),
  `deleteKeys(...)`, and `deleteAllEntries()`.
- `lib/features/settings/presentation/cache_page.dart`: one row per kind
  (label, entry count · formatted size, delete button) plus a destructive
  clear-all row; confirm dialogs follow the app-wide AlertDialog +
  TextButton pattern.
- Provider invalidation mapping lives in the page: instance meta →
  `instanceInfoProvider`, emoji → `emojiCatalogProvider`, notifications →
  `notificationListControllerProvider`.

## Phases

- Done in one phase (W0.1 manager + settings page, W0.2 this document).

## Acceptance criteria

- Settings → Cache management lists the three kinds with real entry counts
  and byte sizes across all accounts.
- Clearing the emoji cache empties it; reopening the timeline refetches the
  catalogue instead of serving the deleted payload.
- Clear-all also wipes unmanaged entries (feed snapshots).
- Repositories write under the shared key constants only; no second source
  of key literals exists.

## Open questions

- None.
