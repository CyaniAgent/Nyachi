# Composer plan

## Goal

Turn the composer into the app's primary writing surface: drafts that are real,
multi-entry records with attachments; a header whose action group is honestly
right-aligned; a header avatar that opens a panel (drafts, scheduled posts,
same-instance account switching); working autocomplete for mentions, hashtags
and custom emoji; a single attachment entry with a drive picker; live preview
on the toolbar instead of a menu switch; and polls that coexist with
attachments.

## Current state (verified, with file:line references)

All line numbers verified on `develop` at time of writing.

**Entry points.** The composer opens as a modal bottom sheet
(`showComposeSheet`, `lib/features/composer/presentation/compose_sheet.dart:25-36`)
or a full-page `Scaffold` wrapper (`ComposePage`,
`lib/features/composer/presentation/compose_page.dart:9-27`). Fresh compose is
launched via FAB through `openDetail(context, const ComposeDetailLocation(null))`
(`lib/features/timeline/presentation/home_page.dart:112`,
`lib/features/profile/presentation/profile_pages.dart:43`); reply via the note
card action row (`lib/features/notes/presentation/note_card.dart:183`). The
wide-screen coordinator forces the sheet form even on wide layouts
(`lib/app/detail_panel/open_detail.dart:30-33`); the panel hosts the full page
(`lib/app/detail_panel/detail_location.dart:121`). A `/compose` route exists
(`lib/app/router/routes.dart:125-141`).

**Drafts.** Stored in Drift, table `Drafts`
(`lib/core/storage/app_database.dart:39-60`), with `accountId` as the only
primary key — one draft slot per account:
`Set<Column<Object>> get primaryKey => {accountId};`
(`app_database.dart:59`). `DraftDao` offers `read`/`save`/`deleteDraft`
(`app_database.dart:214-260`, save uses `insertOnConflictUpdate`).
On open the controller schedules restore (`unawaited(Future<void>.microtask(_restoreDraft));`,
`composer_controller.dart:197`); restore is refused when the stored
`replyId` does not match (`if (draft.replyId != _replyId) return;`,
`composer_controller.dart:226`) — but since there is a single row per account,
the next edit silently overwrites the foreign-context draft. Any setter marks
the draft dirty and persists after a 500 ms debounce
(`_debounce = Timer(const Duration(milliseconds: 500), …)`,
`composer_controller.dart:397`); on dispose the controller persists whenever
dirty, even with empty text (`composer_controller.dart:178-195`, `_persist`
writes `text: state.text` unconditionally, `composer_controller.dart:402-424`)
— blank drafts are possible. `fileIds` is absent from `_persist` and from
`_restoreDraft` (`composer_controller.dart:402-424`, `221-247`): attachments do
not survive a draft round-trip. `showPreview` is in-memory only
(`composer_controller.dart:149`). Draft deletion happens on successful post
(`composer_controller.dart:469`), via the reset menu action, and via the
restore banner's delete button (`compose_sheet.dart:135-150`).

**Header.** Row layout close/avatar/visibility/localOnly/more/publish. The
avatar is inert display-only: `NyachiAvatar(url: account?.avatarUrl, size: 32)`
(`compose_sheet.dart:344`); `NyachiAvatar` has no tap parameter at all
(`lib/core/ui/avatar.dart:13-28`). localOnly is a rocket icon button
(`Icons.rocket_launch_outlined`, `compose_sheet.dart:366-376`). The publish
button is a `FilledButton.icon` in the header flow
(`compose_sheet.dart:387-401`), gated by `canPost()`
(`composer_controller.dart:204-211`: non-empty text, length limit, ≥2 poll
choices, not posting) — it is not right-aligned as a group with visibility and
localOnly. Visibility is a popup menu with the four Misskey options
(`_VisibilityMenu`, `compose_sheet.dart:929-1000`); choosing `specified` opens
the recipient picker (`compose_sheet.dart:349-364`) whose chips show raw user
ids (`compose_sheet.dart:914-917`).

**More menu** (`_MoreMenu`, `compose_sheet.dart:410-597`): character budget
gauge, expand-to-full-page (sheet mode only, `compose_sheet.dart:450-457`),
save draft, preview toggle with an inline `Switch`
(`compose_sheet.dart:530-541`), schedule (gated on the
`draftsSupported` instance probe, renamed from `scheduledNotesSupported` in W2.1,
`compose_sheet.dart:542-551`, `lib/core/network/instance_repository.dart:121-130`),
then the reaction acceptance options flat in the menu
(`_acceptanceOptions` map `compose_sheet.dart:429-434`, group rendered at
`compose_sheet.dart:555-574`), then reset (`compose_sheet.dart:575-586`,
confirm handling `compose_sheet.dart:468-483`). The API's `likeOnlyForRemote`
value (`misskey_dart_api` `notes_models.dart:14-19`) has no menu entry; the
sender silently maps unknown names to
`nonSensitiveOnlyForLocalLikeOnlyForRemote` (`composer_controller.dart:54-66`).

**Preview.** `_PreviewCard` renders CW text plus `NoteContent` with an
emoji map from the catalog (`compose_sheet.dart:835-873`). It does not render
attachments, poll or recipients. The only entry is the menu switch.

**Poll vs attachments.** Mutually exclusive today. Enabling a poll silently
drops attachments: `fileIds: value ? const <String>[] : state.fileIds`
(`composer_controller.dart:289-297`; the doc comment at 287-288 says the
opposite of what the code does). The upload handler bails with no feedback:
`if (ref.read(provider).showPoll) return;` (`compose_sheet.dart:261`) and the
two upload buttons are disabled while a poll is active
(`compose_sheet.dart:648-671`).

**Text input.** A plain `TextField` (`compose_sheet.dart:178-189`), no rich
text. `@` inserts a bare character via `onInsert('@')`
(`compose_sheet.dart:696-700`, insertion at cursor `compose_sheet.dart:237-253`).
No autocomplete exists for mentions, hashtags or emoji.

**Upload.** Two buttons — image (`Icons.image_outlined`,
`compose_sheet.dart:651-658`) and file (`Icons.cloud_upload_outlined`,
`compose_sheet.dart:659-671`) — call the same `_attach(FileType)` flow
(`compose_sheet.dart:259-284`): `FilePicker.pickFiles` → `drive.upload` →
`controller.addFileId`. They differ only in the `FileType` filter. There is no
way to pick existing drive files (`addFileId` has exactly one caller,
`compose_sheet.dart:270`). Attachment chips show the raw file id with a generic
file icon (`compose_sheet.dart:875-898`).

**Emoji insert sheet.** Search by name/aliases (`emoji_insert_sheet.dart:39-47`)
over a single flat grid
(`GridView.builder` with `maxCrossAxisExtent: 56`,
`lib/features/composer/presentation/emoji_insert_sheet.dart:69-92`); tapping
returns `':name:'`. The catalog model carries `category`, `isSensitive` and
`roleIdsThatCanBeUsedThisEmojiAsReaction` (`EmojiSimple`,
misskey_dart_api `components.dart:1958-1970`), none of which the sheet uses;
there is no grouping and no placeholder logic. The catalog is fetched via
`client.emoji.list()` and cached in the `CacheEntries` table with a 30 s
failure retry (`lib/features/notes/application/emoji_catalog.dart:16-55`).

**Scheduling.** Date+time pickers (`compose_sheet.dart:590-613`); on send a
scheduled post goes to the server-side drafts queue:
`client.notes.draftsCreate(…, isActuallyScheduled: true)`
(`composer_controller.dart:69-88`), after which the local draft row is deleted
(`composer_controller.dart:469`). `scheduledAt` is part of the local draft
schema. There is no UI anywhere to list or cancel scheduled posts (verified by
search: the only `notes.drafts*` calls are the create above and the capability
probe).

**Sending.** `ComposerSender` maps the composer state onto `notes/create`
or `notes/drafts/create` (`composer_controller.dart:39-107`).

## Decisions (maintainer-confirmed)

- Drafts: blank drafts must not exist — nothing is persisted without
  substantive content (text, attachments, or a poll with choices). Drafts
  become a multi-entry list (independent id primary key) including separate
  reply drafts. Storage is hybrid: the server's `notes/drafts` queue when the
  instance supports it (drafts and attachments included), the local Drift table
  otherwise (50 per account, no attachments). The draft list lives in the
  composer header avatar panel.
- Avatar panel: the composer header avatar opens a panel with the drafts list,
  the scheduled posts list, and switching between accounts on the same
  instance.
- Composer header: visibility, localOnly and publish form a right-aligned
  action group (the publish button currently is not visually right-aligned).
- Reaction acceptance: collapsed into a submenu of the more menu, not flat.
- Preview: the menu switch is removed; a live preview toggle (edit/preview
  modes) moves to the toolbar.
- Poll and attachments/images coexist; no mutual exclusion.
- Autocomplete: `@` mentions (local list overlaid with users/search results),
  `#` hashtags and `:custom emoji:` — all three.
- Upload: a single paperclip button with a small menu — pick a local file /
  pick from drive. No separate image vs attachment buttons.
- Scheduled posts are manageable from the avatar panel (list + delete) via the
  existing `notes/drafts` endpoints.

## Design

1. **Draft model (hybrid: server-primary, local fallback).** Drafts live in the
   server's `notes/drafts` queue when the instance probe passes
   (`InstanceInfo.draftsSupported`, probed via `notes/drafts/count`); the local
   Drift table is the fallback for instances without the endpoints or while
   offline. `DraftStore`
   (`lib/features/composer/application/draft_store.dart`) owns the routing and
   merges both sources into one newest-first list for the avatar panel.
   - **Local fallback table** `LocalDrafts` replaces the single-slot `Drafts`
     table (schema v2→v3, drop-and-recreate — drafts are disposable):
     independent `id` primary key, `accountId`, `replyId` (nullable — reply
     drafts are their own entries), `body`, `cw`, `visibility`, `localOnly`,
     `reactionAcceptance`, `scheduledAt`, `fileIds` (JSON), poll choices (JSON)
     + `pollMultiple` + `pollExpiresAt`, `visibleUserIds` (JSON), `updatedAt`.
     Capped at 50 rows per account, oldest pruned.
   - **Substantive-content gate.** A draft is stored only when
     `hasSubstantiveContent` holds: trimmed text non-empty, or ≥1 fileId, or a
     poll with ≥2 non-empty choices. Blank content deletes the stored row
     instead — blank drafts never exist. Deleted on successful post (normal and
     scheduled sends).
   - **Attachments are server-only.** Uploading a file already requires
     connectivity, so a locally written draft can never carry a fileId; local
     rows store none. No offline "attachments dropped" state can arise.
   - **Id namespace.** Server draft ids are opaque server strings; local rows
     prefix their UUID with `local:` so deletes route to the right store.
   - The server's own 999-draft cap is enforced server-side: `draftsCreate`
     surfaces the error as-is, never worked around locally.
   - Account deletion clears the account's local rows via `deleteAccount`.
2. **Avatar panel.** The header avatar (`compose_sheet.dart:344`) becomes a
   tappable entry that opens a panel with three sections:
   - *Drafts list*: one row per draft (snippet, visibility icon, updated time);
     tap loads it into the open composer (the controller is keyed by replyId —
     loading a draft with a different replyId replaces the active controller
     state); swipe or trailing button deletes.
   - *Scheduled posts list*: server-side, via the existing `notes/drafts`
     endpoints (list + delete), shown only when the instance probe
     (`draftsSupported`) is positive.
   - *Same-instance account switcher*: reuses the account switching logic of
     the settings account page, filtered to the active host, without forcing
     navigation away from the composer.
3. **Header layout.** Left: avatar + title/content-warning field. Right: the
   action group `[visibility, localOnly, publish]` right-aligned as a group
   (`Spacer`/`mainAxisAlignment.end` on the trailing segment), fixing the
   current flow layout where the publish button does not sit at the trailing
   edge.
4. **More menu.** Keeps: character budget, expand (sheet mode), save draft,
   schedule. Removes the preview switch (moves to the toolbar, item 5).
   Reaction acceptance collapses into a submenu ("Reaction acceptance >") with
   the four existing options; `likeOnlyForRemote` is added so the menu covers
   the full API enum (`notes_models.dart:14-19`), and the sender's
   unknown-name fallback (`composer_controller.dart:54-66`) becomes an explicit
   mapping with no default guess.
5. **Live preview.** A toolbar icon toggles edit/preview modes in the body
   area. Preview renders text + emoji + CW (as `_PreviewCard` does today) and,
   while attachments/poll/recipients are not rendered, shows an explicit
   footnote listing what the preview does not include, so the surface never
   silently implies completeness.
6. **Poll + attachments coexistence.** Delete the drop-on-toggle
   (`composer_controller.dart:295`), the silent bail (`compose_sheet.dart:261`)
   and the disabled-while-poll button states
   (`compose_sheet.dart:648-671`); both upload entry points stay enabled with a
   poll active. `canPost` validation is unchanged — Misskey accepts notes
   carrying both poll and attachments. Fix the inverted doc comment on
   `setShowPoll`.
7. **Autocomplete.** Trigger-driven overlay anchored to the text field's
   cursor position:
   - `@` opens a local candidate list (followings + recent interactions,
     sourced client-side without a request); after ≥2 more characters the list
     merges remote `users/search` results.
   - `#` uses the instance hashtag/trends source.
   - `:` filters the emoji catalog (`emojiCatalogProvider`) by name/alias.
   Selection (tap, Enter, arrow keys) replaces the active trigger token with
   the completion. Escape/Backspace-before-token dismisses the overlay.
8. **Upload.** One paperclip button; a small popup menu with "Pick local file"
   (existing `file_picker` flow, no type filter) and "Pick from drive" (new
   drive picker reusing the drive listing provider; multi-select; returns
   `fileIds` directly, no re-upload).
9. **Attachment chips.** Once drive metadata is available, chips show
   filename, type badge and a thumbnail for images instead of the raw id
   (`compose_sheet.dart:875-898`); deletion stays per-chip.

## Phases

- **P1 — Draft model + header layout + poll coexistence.** New drafts table
  and migration, substantive-content gate, multi-entry restore, right-aligned
  header action group, remove the poll/attachment mutual exclusion.
- **P2 — Autocomplete.** `@`, `#` and `:emoji:` triggers with the overlay;
  remote `users/search` merge behind the ≥2-character rule.
- **P3 — Avatar panel + drive picker.** Drafts list, scheduled list
  (probe-gated), same-instance switcher; paperclip menu with local-file and
  drive-picker entries; metadata chips.
- **P4 — Live preview + acceptance submenu.** Toolbar edit/preview toggle with
  the not-rendered footnote; more-menu submenu for reaction acceptance incl.
  `likeOnlyForRemote`.

## Acceptance criteria

- Opening the composer, entering nothing, and closing it leaves zero draft
  rows for the account.
- Typing one character and closing leaves exactly one draft row; reopening
  restores it and shows the restore affordance; deleting it leaves zero rows.
- A reply draft and a normal draft coexist as separate rows and each restores
  in its own context.
- Uploading a file, then enabling a poll, keeps the fileId; the note sends
  with both poll and attachment.
- A draft containing an uploaded attachment restores with the attachment chip
  present.
- The header shows `[visibility, localOnly, publish]` flush to the trailing
  edge at both narrow and wide window sizes.
- In the more menu, reaction acceptance is a submenu containing all four API
  values (`likeOnly`, `likeOnlyForRemote`, `nonSensitiveOnly`,
  `nonSensitiveOnlyForLocalLikeOnlyForRemote`) plus "any".
- The toolbar preview toggle switches edit/preview; the preview shows a
  footnote naming what it does not render while those gaps exist; the more
  menu no longer contains a preview switch.
- Typing `@` shows a candidate overlay; typing `@ab` merges remote results;
  Enter or tap inserts the mention in place of the token. The same holds for
  `#` (trends) and `:` (catalog emoji).
- The paperclip menu offers "Pick local file" and "Pick from drive"; picking
  one existing drive file adds its fileId without an upload request.
- With `draftsSupported` probed true, the avatar panel lists scheduled
  posts and deleting one removes it server-side; probed false, the section is
  absent.
- Composer requests continue to go through the shared API client (no
  per-feature HTTP construction).

## Open questions

- Should the drive picker also allow creating a folder inline, or is
  navigation-only acceptable for the first cut?

## Resolved

- Draft retention: local fallback keeps the most recent 50 drafts per account
  (oldest pruned), reply drafts included in that count. Server drafts are
  capped by the server at 999.
