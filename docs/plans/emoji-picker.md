# Emoji picker plan

## Goal

Group custom emoji by the server-defined `category` metadata in both emoji
surfaces — the note reaction picker and the composer emoji insert sheet —
with sticky group titles.

## Current state (verified, with file:line references)

- Catalog: `emojiCatalog` is a keepAlive Riverpod provider that fetches
  `POST /emojis` (`client.emoji.list()`) and caches the whole
  `EmojiListResponse` JSON per account
  (`lib/features/notes/application/emoji_catalog.dart:33-34`; on failure it
  falls back to the cache with a 30 s retry, :21-24 and :36-53).
- SDK: `EmojiListResponse{emojis: List<EmojiSimple>}`
  (generated `emoji_models.dart:24-26`; endpoint
  `emoji_api.dart:46-60`). `EmojiSimple` carries
  `required String? category` (`components.dart:1959-1968`, category at
  :1963) — the grouping key is already inside the cached payload. Role
  restriction metadata (`roleIdsThatCanBeUsedThisEmojiAsReaction`, :1967)
  also exists but is not a grouping concern.
- Reaction picker
  (`lib/features/notes/presentation/reaction_picker.dart`): modal bottom
  sheet (:15-18) containing the note's existing reaction chips (:55-66), a
  fixed unicode default row (`defaultReactions`, :12, rendered :68-77), a
  search field (:79-85), and all custom emoji in one flat 6-column grid
  (:109+). `category` is used only as a search-match field (:98-100); there
  is no grouping. Picking a custom emoji returns `':name:'` (:122).
- Composer insert sheet
  (`lib/features/composer/presentation/emoji_insert_sheet.dart`): modal
  bottom sheet (:11-17); search matches name and aliases only — not
  category (:40-43); one flat grid (:69-72); returns `':name:'` (:83).

## Decisions (maintainer-confirmed)

- Emoji grouping: group titles with sticky headers, by the emoji `category`
  metadata, in both the reaction picker and the emoji insert sheet.

## Design

- Group the catalog's `EmojiSimple` list by `category`; null or empty
  category falls into an "Other" group placed last; group order is stable.
- Both grids render grouped sections with sticky group headers while
  scrolling; one shared grouping/rendering helper serves the two surfaces.
- Search keeps matching globally across groups; after filtering, only groups
  with visible matches show their headers.
- The unicode default reactions row in the reaction picker stays above the
  grouped grid, unchanged; the existing-reactions chips row also stays.
- Out of scope: filtering or hiding emoji by role restriction
  (`roleIdsThatCanBeUsedThisEmojiAsReaction`) — grouping only.

## Phases

- Single phase: both grids switch to grouped rendering in one change.

## Acceptance criteria

- Every rendered custom emoji sits under a header matching its category;
  uncategorized emoji sit under "Other", last.
- Headers stick while scrolling in both the reaction picker and the insert
  sheet.
- Searching filters across groups and re-groups the results; empty groups
  are not rendered.
- The default unicode reactions row behaves exactly as before.

## Open questions

- None.
