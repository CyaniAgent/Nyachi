# Plans

Product and engineering plans, one file per domain. Every file follows the same
structure: Goal / Current state (verified, with file:line references) /
Decisions / Design / Phases / Acceptance criteria / Open questions. Decisions
recorded here are confirmed by the maintainer; new work starts from these
documents instead of chat history.

## Files

| File | Scope |
| --- | --- |
| [composer.md](composer.md) | Composer: multi-entry drafts, header layout, autocomplete, unified upload entry, live preview, scheduled posts, avatar panel |
| [home-nav.md](home-nav.md) | Startup page setting, default tab, tab configuration |
| [note-thread.md](note-thread.md) | Note detail: conversation view, four-button action row, favorite/delete/report/memo |
| [emoji-picker.md](emoji-picker.md) | Custom emoji grouping (sticky headers) for the reaction picker and insert sheet |
| [settings.md](settings.md) | Personal settings: profile, privacy, notifications, email, security, drive |
| [push.md](push.md) | Push notifications (web push first) and resident/background operation |
| [streams.md](streams.md) | Realtime streams and scroll-position-stable pagination for chat and every feed |
| [cache.md](cache.md) | Unified cache manager and the settings page that shows and clears managed caches |

## Confirmed decisions

- Startup: a setting offers Timeline (default) / Remember last page / a specific
  tab.
- Home tabs: only a "default startup tab" setting; no in-home edit mode.
- Drafts: blank drafts never exist; drafts are a multi-entry list (independent
  id) including separate reply drafts, and carry attachments. The list lives in
  the composer header avatar panel.
- Note card action row: reply / renote / react / detail side by side; the
  overflow menu becomes a real menu (favorite, user memo, delete, report,
  copy link, ...).
- Thread view: linear with reference lines.
- Own reaction: the add-reaction button turns into "cancel reaction".
- Composer header: visibility, localOnly and publish form a right-aligned
  action group.
- Reaction acceptance: a submenu of the more menu.
- Preview: live preview toggle on the toolbar; the menu switch is removed.
- Poll and attachments/images coexist.
- Autocomplete: @ mentions (local list + users/search), #hashtags,
  :custom emoji:.
- Upload: one paperclip button with a small menu — local file / pick from
  drive.
- Emoji grouping: sticky group titles by category, in both emoji surfaces.
- Settings: profile, privacy, notifications, email, security and drive, as
  separate pages.
- Push: web push + in-app realtime first; a self-hosted gateway for all
  platforms is a later, optional (possibly sponsor-gated) service.
- Resident: desktop tray + Android foreground service.
- Caches: one `CacheManager` owns the canonical cache keys and bulk
  clearing; settings can show sizes and clear per kind or everything.

## Roadmap

1. Correctness wave (shipped): back navigation (2.0.0-beta.9); composer
   drafts, header layout, poll coexistence.
2. Reading wave: note thread view and actions; emoji grouping; chat scroll
   fix, feed auto-load, notification/chat streams.
3. Writing wave: autocomplete; unified upload entry with drive picker; live
   preview; avatar panel (drafts / scheduled / same-instance switcher).
4. Settings wave: the six personal-settings domains.
5. Delivery wave: web push + in-app realtime notifications; desktop tray and
   Android foreground service.
6. Optional later: self-hosted push gateway (possible sponsor-gated service).

## Rules

- Each plan file carries its own acceptance criteria; implementation starts by
  re-verifying its "Current state" references — line numbers drift.
- Decisions change only with the maintainer's explicit confirmation, recorded
  in the file they affect.
