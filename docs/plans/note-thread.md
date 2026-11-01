# Note thread & note actions plan

## Goal

Make the note detail page a complete conversation surface (ancestor chain →
focused note → replies) and align the note card's action area with the
maintainer decisions: a four-button action row (reply / renote / react /
detail) with a real overflow menu (favorite, user memo, delete, report, copy
link, clip, thread mute).

## Current state (verified, with file:line references)

Detail page
- `lib/features/notes/presentation/note_detail_page.dart:82-95` renders the
  focused note (`NoteCard(note: note, detailMode: true)`, :86), a divider
  (:87), and the replies section (:88-94). The AppBar has a title only, no
  actions (:37-38).
- No parent chain is rendered or fetched: the controller loads the note via
  `notes/show` and replies via `notes/children` only
  (`lib/features/notes/application/note_detail_controller.dart:66-74`,
  :77-103). The SDK model carries the parent (`Note? reply`,
  misskey_dart_api `components.dart:1442`) but nothing in `lib/` reads it,
  and the SDK's `notes/conversation`
  (high_level `notes_api.dart:143-147`) is never called.
- Replies render chronologically (controller :120-124) with load-older
  pagination (note_detail_page.dart:147-155); each reply tile opens its own
  detail on tap (:169-170).

Detail entries today
- Timestamp `InkWell` on every card
  (`lib/features/notes/presentation/note_card.dart:106-110`).
- A one-item overflow menu whose only entry is "detail" (note_card.dart:198-210;
  label `l10n.noteDetail` = "Note" / "帖子" / "投稿", `app_en.arb:221`,
  `app_zh.arb:213`, `app_ja.arb:213`).
- NoteCard renders on the home timeline (`home_page.dart:234`), explore
  search (`explore_page.dart:86`), profile notes tab
  (`profile_pages.dart:108`), tag timeline (`tag_timeline_page.dart:17`),
  and the detail page itself (note_detail_page.dart:86). Notifications open
  the detail via their own tile tap (`notifications_page.dart:158-160`).

Action row
- Reply / renote / react buttons only (note_card.dart:178-196). Renote is a
  pure renote behind a confirm dialog (:253-283) calling
  `notes.create(renoteId: …, text: null)`
  (`lib/features/notes/data/note_repository.dart:70-73`). There is no quote
  path: the composer accepts only `replyId`
  (`lib/features/composer/application/composer_controller.dart:29`).

Reactions
- Only the first four reaction entries render (`take(4)`,
  note_card.dart:162). The own reaction shows as a selected chip
  (`selected: note.myReaction == entry.key`, :167) styled with
  `secondaryContainer` (`reaction_chip.dart:39-55`); tapping it again
  removes it (note_card.dart:230-245; same logic in the detail controller,
  note_detail_controller.dart:126-141).
- The react button itself does not reflect `myReaction`, and an own reaction
  outside the first four chips has no visible cancel affordance on the card.
- No long-press exists on note cards (`onLongPress` in `lib/` appears only in
  `drive_page.dart:536,594` and `settings_page.dart:107`).

Missing actions (no calls anywhere in `lib/`; SDK surface verified)
- Favorite: `notes/favorites/create` + `notes/favorites/delete`
  (high_level `notes_api.dart:378-390`, :393-405).
- Delete: `notes/delete` (high_level `notes_api.dart:208-211`).
- Report: only `users/report-abuse` (high_level `users_api.dart:936-944`);
  the request model is `{userId, comment}`
  (generated `users_models.dart:918-921`) with no `noteIds`, and the SDK
  manifest has no `notes/reports/create`.
- Clip: `clips/addNote` (high_level `clips_api.dart:25-33`), chooser via
  `clips/list` (:92-95).
- Thread mute: `notes/thread-muting/create` + `/delete`
  (high_level `notes_api.dart:1120-1122`, :1135-1137).
- User memo: `users/update-memo` `{userId, memo}`
  (high_level `users_api.dart:1058-1067`;
  generated `users_models.dart:1064-1068`). `Note.user` is a `UserLite`
  without `memo`; only `UserDetailed`/`MeDetailed` carry it
  (`components.dart:743`, :1017, :1237), so reading an existing memo costs a
  `users/show` call.
- Favorite / thread-mute state: `Note` has no `isFavorited` field
  (`components.dart:1432-1469`); state comes from `notes/state` →
  `NotesStateResponse{isFavorited, isMutedThread}`
  (generated `notes_api.dart:499-512`, `notes_models.dart:812-817`).

## Decisions (maintainer-confirmed)

- Action row: reply / renote / react / detail buttons side by side; the
  overflow menu becomes a real menu (favorite, user memo, delete, report,
  copy link, ...).
- Thread view: linear with reference lines (no indentation tree).
- Own reaction: once the user has reacted, the add-reaction button turns
  into "cancel reaction" (tap removes the own reaction).

## Design

1. Action row becomes four buttons: reply, renote, react, detail. The detail
   button reuses the existing `openDetail(NoteDetailLocation)` path
   (note_card.dart:222-224). The react button is stateful: with
   `note.myReaction != null` it renders the cancel-reaction state and a tap
   runs the existing unreact flow (note_card.dart:230-245). The reaction
   chips row remains the way to add or change a reaction.
2. Overflow menu becomes a real menu: Copy link (from `note.url`/`note.uri`,
   falling back to `<instance origin>/notes/<id>`), Favorite/Unfavorite
   (favoritesCreate/favoritesDelete; current state via `notes/state`), User
   memo (users/update-memo), Thread mute/unmute (threadMutingCreate/Delete),
   Delete (own notes only, confirm dialog; "delete & edit" is future work —
   the SDK has no note-update endpoint), Report (users/report-abuse behind a
   comment dialog), Add to clip (clips/addNote with a chooser backed by
   clips/list).
3. Detail page thread view: linear with reference lines. Above the focused
   note, the ancestor chain loads via `notes/conversation` and renders
   oldest → newest, connected into the focused note by a vertical reference
   line. Below, the existing replies section (notes/children) continues the
   same line. No indentation tree.
4. Navigation: tapping any ancestor or reply pushes its own detail page, so
   a chain is traversed step by step.

## Phases

- P1 — Action row (four buttons, cancel-reaction state) and the real
  overflow menu (favorite, delete, report, copy link).
- P2 — Conversation ancestors and reference lines on the detail page.
- P3 — User memo, add to clip, thread mute.

## Acceptance criteria

- Opening a reply's detail shows the full ancestor chain ending at the
  focused note, with replies below.
- The react button reflects the own reaction and cancels it on tap; the
  picker still adds or changes reactions.
- Favorite toggles and its state survives reload via `notes/state`.
- Delete appears only on own notes and asks for confirmation.
- Report requires a comment and posts `users/report-abuse`.
- Menu and row behave identically on every surface that renders NoteCard
  (home, explore, profile, tag timeline, detail).

## Open questions

- Report: attaching a note to an abuse report is impossible with the current
  SDK request model (`{userId, comment}` only) — an SDK-side change is
  required (SDK repo, outside this application).
- Memo read-back: whether to fetch `users/show` per author to display the
  existing memo, or ship write-only memo in P3.
