# Streams & scrolling plan

## Goal

Realtime everywhere it matters — the home timeline already streams; notifications
and chat must too — and scroll-position-stable pagination on every stream surface:
a chat thread opens at the newest message, reading back through history never moves
the viewport under the user, and every feed loads more at the scroll edge without
a button.

## Current state (verified, with file:line references)

Chat transcript (`ChatThreadPage`, `lib/features/chat/presentation/chat_pages.dart`):

- Forward (non-reversed) `ListView.builder(controller: _scroll,
  itemCount: state.items.length + 1)` (:331-334). Items are chronological
  ascending (`chat_controllers.dart:198-199` sorts `a.createdAt` before
  `b.createdAt`), so index 0 is the oldest message and scroll offset 0 is the
  visual top; the `index == 0` slot (:336) is the load-older spinner.
- Wrong initial position: `initState` (:249-253) only attaches the scroll
  listener; nothing positions the view on open. The only auto-scroll,
  `_scrollToBottomIfNear` (:276-288), is gated on being within 240 px of the
  bottom (:280) and no-ops at offset 0 with a page of history — first paint
  parks on the oldest messages.
- Position jump on prepend: `_onScroll` (:265-272) fires `loadOlder()` whenever
  `pixels <= 200` (:267). `loadOlder`
  (`lib/features/chat/application/chat_controllers.dart:180-208`, page size 20 at
  `chat_repository.dart:111-112` and :131-132) prepends older items into the
  chronological list (:194-204). In a forward list with a plain
  `ScrollController`, inserting at index 0 leaves `pixels` unchanged while every
  visible bubble shifts down by the inserted height — the reading position is
  lost and the list appears to grow upward. Because `pixels` is still <= 200,
  `_autoLoading` re-arms (:306) and the next scroll tick loads the next page
  immediately: holding the top chains page after page (the reported
  "infinite upward").
- Incoming messages only arrive through `refresh()` after the user sends
  (`chat_controllers.dart:158-175`, awaited from `send` :212+); the thread page
  has no push channel and no pull-to-refresh.

Feed load-more wiring (scroll-edge triggers exist nowhere outside the chat page —
the only `ScrollController`/`addListener` use in `lib/features` is
chat_pages.dart:241/:252):

| Surface | Trigger | Evidence |
| --- | --- | --- |
| Home timeline | Button | `home_page.dart:234-237` renders the shared `NoteList`; footer button `note_list.dart:137-141`; `loadMore` `note_list_controller.dart:115` |
| Notifications | Button | `notifications_page.dart:100-103`; `loadMore` `notification_list_controller.dart:161` |
| Explore — note search | Button | `explore_page.dart:86-89` renders the shared `NoteList` (search source) |
| Explore — user search | Button | `explore_page.dart:170-173`; `loadMore` `explore_controllers.dart:104` |
| Profile notes tab | Button | `profile_pages.dart:107-111` renders the shared `NoteList` (user source) |
| Tag timeline | Button | `tag_timeline_page.dart:17` renders the shared `NoteList` (tag source) |
| Chat history | Scroll edge (broken, see above) | `chat_pages.dart:265-272` |
| Note detail replies | Button | `note_detail_page.dart:151-154`; `loadMoreReplies` `note_detail_controller.dart:97` |

`NoteList` pages 20 notes per request (`note_feed_repository.dart:40`).

Streaming:

- One realtime surface: the home timeline. `HomeStreamService`
  (`lib/features/timeline/application/home_stream_service.dart`) subscribes
  `TimelineChannel(TimelineKind.home)` (:92-94), exposes a broadcast `notes`
  stream (:57) and a `status` notifier with reconnect backoff 1/2/4/8/16/30 s
  (:55). Consumed only by the home tab — live notes inserted via
  `insertLiveNote` (`home_page.dart:222-232`,
  `note_list_controller.dart:142-145`) — plus the live/reconnecting header
  (`home_page.dart:240`).
- Chat and notifications are request-only: loaded on open, on pull-to-refresh,
  or after sending.
- SDK (`misskey_dart_api` 0.1.0, `lib/src/streaming/channels.dart`): typed
  `TimelineChannel` (home/local/hybrid/global) plus `MainChannel` (`main`,
  untyped JSON — the channel personal events arrive on) and
  `RawChannel(name, {params})` for any other Misskey channel. `notification`,
  `chatUser` and `chatRoom` (params: `roomId`) are reachable today via
  `MainChannel`/`RawChannel`; dedicated typed channel classes do not exist in
  the SDK yet.

## Decisions (maintainer-confirmed)

- Streaming is important and is elevated beyond the home timeline: notifications
  and chat get realtime delivery, not just the home timeline.
- The chat messages view must open at the bottom (newest message); scrolling up
  loads older messages while preserving the current viewport position.
- Every stream surface gets scroll-triggered load-more — no "load more" buttons.

## Design

Chat — reversed transcript (the reverse-slack pattern):

- Render the transcript with `ListView.builder(reverse: true)` over the same
  chronological `ChatThreadState.items`, mapping index 0 to the newest item. In
  a reversed viewport, offset 0 is the visual bottom, so a fresh page opens on
  the newest message with no manual positioning.
- Position preservation on prepend is then free: chronologically prepending
  older items appends them at the high end of the reversed index order, so the
  bottom-anchored layout of every existing bubble is untouched and
  `maxScrollExtent` grows above the user instead of the list sliding underneath.
  Load-older triggers near the visual top (large offset); after a prepend the
  user is no longer at the edge, which also stops the runaway chain-loading.
- The controller state stays chronological (the id-keyed merge in `loadOlder`
  is unchanged); only the itemBuilder mapping and the spinner slot (now the
  last index) change. New outgoing/incoming messages land at index 0 (bottom)
  and stay in view; the pin-to-bottom logic collapses to an "at offset 0" check.
- Rejected: jump-to-bottom on open plus manual scroll-offset compensation on
  prepend. It needs measured inserted extents and post-frame `jumpTo`
  corrections — fragile with variable-height bubbles and late-loading images —
  and hand-maintains both behaviors that sliver anchoring provides.

Feeds — shared scroll-edge load-more:

- One small helper (a `NotificationListener<ScrollNotification>`-based widget)
  invokes a callback when the list comes within a threshold (~400 px) of the far
  edge, re-arming only after the in-flight callback completes. Surfaces pass
  `hasMore`/`loadingMore` plus `loadMore`.
- Apply it to the `NoteList` footer (`note_list.dart:133-141`), the
  notifications footer (`notifications_page.dart:95-105`) and the user-search
  footer (`explore_page.dart:163-175`); keep the in-flight spinner, remove the
  buttons. Home timeline, profile notes, tag timeline and note search inherit
  it through `NoteList`; note detail replies can adopt the same helper.
- `RefreshIndicator` and the banner/empty/header slots stay as they are.

Realtime — subscribe beyond the home timeline:

- Generalize the per-account stream session so one connection carries
  `homeTimeline` (existing), `main` (notification-class personal events) and
  the chat channels — `chatUser`, and `chatRoom` with `roomId` while a room
  thread is open — via `RawChannel`. The existing reconnect/backoff/lifecycle
  handling in `HomeStreamService` is reused, not duplicated.
- Notification events feed `notification_list_controller` (live prepend, unread
  affordance); chat events feed the open `ChatThreadController` (append incoming
  messages, refresh lists) and the chat list page.
- Typed `NotificationChannel`/`ChatChannel` classes belong in the SDK
  repository; the app starts on `MainChannel`/`RawChannel` so nothing is
  blocked on an SDK release.

## Phases

1. P1 — Chat scroll fix: reversed transcript, open at bottom, stable prepend,
   edge-triggered load-older at the visual top; widget tests.
2. P2 — Feed auto-load: shared scroll-edge helper; remove the load-more buttons
   on every surface listed above.
3. P3 — Notification + chat streams: subscriptions, controller wiring, live/unread
   affordances.

## Acceptance criteria

- Opening a chat thread with 50+ messages lands on the newest message without
  user scrolling.
- With a thread scrolled into history, loading the next older page keeps the
  message that was visible at the top on screen afterwards (no jump), and
  holding the edge no longer chain-loads page after page.
- Every feed surface — home timeline, notifications, explore note search,
  explore user search, profile notes tab, tag timeline, chat history — loads
  more when scrolled near the end, with no "load more" button rendered.
- While a chat thread is open, an incoming message appears without manual
  refresh; new notifications appear without pull-to-refresh.
- Widget tests cover chat open-at-bottom, viewport stability across prepend,
  and the shared edge helper; existing tests stay green.

## Open questions

- Chat history page size: keep 20 (`chat_repository.dart:111-112`/:131-132) or
  raise toward the Misskey cap of 100 to reduce edge round-trips?
- Fixed edge threshold (px) or proportional to viewport height for the shared
  helper?
- Typed `NotificationChannel`/`ChatChannel` in the SDK repository — same round
  as P3, or later with `RawChannel` in the app meanwhile?
- Should the local/hybrid/global tabs also stream, or home kind only (today only
  `HomeFeedKind.home` subscribes, `home_page.dart:222-232`)?
