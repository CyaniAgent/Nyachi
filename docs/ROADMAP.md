# Nyachi pages expansion roadmap

This document is the single formal planning document for Nyachi's pages
expansion: the set of Misskey surfaces the client does not cover yet. It
supersedes the per-domain planning files previously kept under `docs/plans/`
(deleted); the git history of those files remains the record of the decisions
behind already-shipped work. New implementation work starts from this file.

Last updated: 2026-11-04.

## Confirmed decisions

- Channels ship first; antennas + lists follow as one merged batch (they
  share the "custom timeline source" architecture).
- Navigation A+B: new sources do NOT enter the bottom bar by default — they
  are selected inside the timeline tab; the navigation settings gain a
  pinned-sources mechanism that can promote a source into the bottom bar.
- Low-cost shells (user page extensions, favorites, follow requests) form
  their own batch after the source batch.
- Long tail (instance info, clips, gallery, pages, flash, reversi) is all
  scheduled, ordered by effort as listed below.
- Bookmarks are dropped from the program: the SDK has no endpoint (verified
  against the generated `api_manifest.dart`); revisit if the SDK adds
  `notes/bookmarks`.
- Every new feed uses the existing reading infrastructure: `NoteList`,
  `ScrollEdgeLoader` pagination, streaming where a channel exists, cache via
  `CacheManager` kinds.

## Shared architecture (channels, antennas, lists)

- `NoteFeedSource` (`lib/features/notes/domain/note_feed_source.dart`) gains
  three variants: `channel(String channelId)`, `antenna(String antennaId)`
  and `list(String listId)`, with `cacheKey` values `channel:<id>` /
  `antenna:<id>` / `list:<id>`.
- Each source renders through the existing `NoteList(source: …)`; no new
  list widget.
- Source switcher (decision A): the timeline tab's kind bar
  (`home_page.dart` `_kinds` / `CompactTabBar`) extends with the followed
  channels, antennas and lists as selectable entries plus a trailing
  "manage" entry that opens the respective management page. The bar stays
  horizontally scrollable (the existing `CompactTabBar` already scrolls).
- Pinned sources (decision B): settings/navigation gains a "Pinned sources"
  section fed by the management pages. Pinning a source appends it to the
  bottom bar as an extra entry that opens a source-timeline route preloaded
  with that source. Implementation notes: the typed `StatefulShellRoute`
  declares 5 static branches; the target design rebuilds the shell from
  `NavConfig` as `StatefulShellRoute.indexedStack` with the 5 core branches
  plus one branch per pinned source (each branch hosting a generic
  `SourceTimelineRoute(path: '/source/:id')`). If that rebuild proves too
  invasive for one pass, the fallback is: a pinned source preloads the Home
  branch with that source selected and the bottom bar entry reuses the Home
  branch — the pinned entry is then a shortcut, not a new navigator. Ship
  whichever lands first; both satisfy A+B.

## Phase 1 — Channels

SDK surface (`channels_api.dart`): `featured()`, `followedPage()`,
`myFavorites()`, `searchPage()`, `showValue(id)`, `timelinePage(id)`,
`follow`/`unfollow`, `favorite`/`unfavorite`.

Pages:

- `ChannelsListPage` (`/channels`) with tabs Featured / Following / Favorites
  plus a search field (`channels/searchPage`). Channel rows show banner,
  name, description, `notesCount` and `followersCount`.
- `ChannelDetailPage` (`/channels/:channelId`): banner + stats + description
  header, follow / favorite buttons reflecting `isFollowing` / `isFavored`
  on `Channel`, and the channel timeline as a `NoteList`.

Feed: `NoteFeedSource.channel(id)` renders `channels/timelinePage`.

Acceptance:

- Follow a channel from the detail page → it appears under Following and in
  the timeline tab's switcher; selecting it renders its notes with infinite
  scroll; unfollow removes it from Following.
- The channel page renders for a signed-out visitor read-only (no crash).

Tests: widget test for the list tabs and the follow toggle state; feed
source `cacheKey` test.

## Phase 2 — Antennas + Lists (one batch)

Antennas:

- `AntennasPage` (`/antennas`) listing the account's antennas
  (`antennas/list`) with create / edit / delete (`antennas/create`,
  `antennas/update`, `antennas/delete`). Form fields: name, keywords CSV,
  excludeKeywords CSV, users CSV, caseSensitive, withReplies, notify.
- Antenna timeline = `antennas/notesPage` via `NoteFeedSource.antenna(id)`.

Lists:

- `ListsPage` (`/lists`) with create / delete / rename (`users/lists/create`,
  `users/lists/delete`, `users/lists/update`) and a members editor
  (`users/lists/get-memberships` + users search + `users/lists/pull` /
  `users/lists/push`, all under `users_api.dart`); public lists importable
  via `users/lists/create-from-public`.
- List timeline = `notes/user-list-timeline` (`userListTimelinePage`) via
  `NoteFeedSource.list(id)`.

Both management pages are reachable from the timeline switcher's "manage"
entries (decision A) and from pinned sources (decision B).

Acceptance:

- Create an antenna with one keyword → its timeline shows matching notes.
- Create a list, add one user → the list timeline shows that user's notes.
- Delete removes the source from the switcher.

## Phase 3 — Low-cost shells

- User page extensions (`profile_pages.dart`): a tab row
  (Notes / Followers / Following) where the follower and following tabs page
  through `users/followers` and `users/following` (cursor-paged wrappers in
  `users_api.dart`); a follow / unfollow button (`following/create` +
  `following/delete`) reflecting the relationship state from `users/show`;
  the user memo displayed from the `UserDetailed` memo field.
- Favorites page (`/favorites`): `i/favorites` (`NoteFavorite`, which carries
  the favorited `Note`) rendered as a `NoteList`-style page with the standard
  pagination.
- Follow-request management (`/follow-requests`, linked from the privacy
  settings page and the user page): incoming list (`following/requests/list`)
  with accept / reject (`following/requests/accept`,
  `following/requests/reject`).

Acceptance:

- Follow and unfollow a user from their page.
- The favorites page lists exactly the notes previously favorited in-app.
- Accepting a request moves the requester to the following list.

## Phase 4 — Long tail (ordered by effort)

- Instance info page (`/about-instance`): instance meta stats, the emoji
  catalogue browsed by category (reuses `emoji_catalog.dart`), federation
  peers (`federation/instances`). Linked from settings and from the instance
  summary on the login screen.
- Clips: `ClipsPage` (`/clips`) listing own clips (`clips/list`) with
  create / rename / delete; a clip page (`/clips/:id`) rendering
  `clips/show` and its notes; "add to clip" via the note overflow menu
  (`notes/clips`, `clips/add-note`).
- Gallery: featured / my posts / liked posts tabs (`gallery/featured`,
  `i/gallery/posts`, the `gallery/posts/liked` family), post detail
  (`gallery/posts/show`), create / edit (`gallery/posts/create`,
  `gallery/posts/update`).
- Pages: list + detail renderer for `pages/show` page blocks (the SDK's
  `Page` / `PageBlock` models); read-only rendering first.
- Flash: featured / my likes (`flash/featured`, `flash/my-likes`) and a Play
  viewer (`flash/show`); ships read-only.
- Reversi: lobby + game board (`reversi/*`, websocket-backed); ships last and
  may ship behind the developer-mode flag if it destabilizes — decide at
  implementation, not before.

Acceptance: each domain renders real instance data read-only at minimum;
the write paths listed above are exercised in tests against the mock client.

## Program-level acceptance

- `flutter analyze` zero issues; the full suite green; each phase adds
  widget tests per repo conventions.
- Navigation A+B verified on narrow (bottom bar) and wide (sidebar + detail
  panel) layouts.
- No phase ships a dead-end page: every list has an empty state and an
  error/retry state reusing `FailureAction`.
