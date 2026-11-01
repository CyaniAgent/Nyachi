# Personal settings plan

## Goal

Bring the six personal-settings domains — profile, privacy, notifications,
email, security, drive — into the app as first-class pages, each backed by the
Misskey APIs that already exist in misskey_dart_api 0.1.0.

## Current state (verified, with file:line references)

The main settings page has exactly four entries — accounts, navigation,
appearance, about (`lib/features/settings/presentation/settings_page.dart:35-68`).
None of the six domains has a page. Every server-side API they need already
exists in the SDK (`misskey_dart_api-0.1.0/lib/src/api/generated/api_manifest.dart`):

| Domain | Endpoints |
|---|---|
| Profile | `i/update` (:3762) |
| Privacy | `mute/create` / `mute/delete` / `mute/list` (:3930-3958); `blocking/create` / `blocking/delete` / `blocking/list` (:1482-1510) |
| Notifications | `i/update`'s `notificationRecieveConfig` field (`lib/src/api/generated/account_models.dart:1533,1572`; high-level wrapper `lib/src/api/high_level/account_api.dart:1042`) |
| Email | `i/update-email` (:3774); `email-address/available` (:2550) |
| Security | full `i/2fa/*` suite (:3186-3274); `i/change-password` (:3306); `i/signin-history` (:3738); password reset `request-reset-password` / `reset-password` (:4626-4663) |
| Drive | the whole `/drive` group (:2310-2549) |

- The drive app surface already exists: `lib/features/drive/data/drive_repository.dart`
  (list :37-53, usage :55-64, upload :66-76, delete :78-84, folder create :86-88)
  and `lib/features/drive/presentation/drive_page.dart` (breadcrumbs :16-18 and
  :115, :141; multi-select delete :290-297; folder create :376-411; upload via
  file_picker :416-418). Missing UI: move (SDK `drive/files/move-bulk`,
  :2418) and rename/metadata update (`drive/files/update`, :2442).
- Notifications are request-only today: the list controller refreshes via
  `account.notificationsPage`
  (`lib/features/notifications/application/notification_list_controller.dart:36-43`)
  and caches 50 items (:69-73). No polling and no stream subscription exist
  under `lib/features/notifications/`; the only stream subscription in the app
  is the home timeline
  (`lib/features/timeline/application/home_stream_service.dart:92-96`).

## Decisions (maintainer-confirmed)

- All six domains — profile, privacy, notifications, email, security, drive —
  are in scope, implemented as separate pages (shared decision log).

## Design

A "Personal" section on the main settings page routes to six sub-pages.

1. **Profile** — edit name, description, fields, banner/avatar (upload via
   drive), birthday/location, flags (isBot/isCat); uses `i/update`; preview
   where cheap.
2. **Privacy** — default visibility/localOnly for new notes (stored locally),
   mute/block management (lists with create/delete), approval flags surfaced
   by `i/update`.
3. **Notifications** — per-event delivery config mapped to
   `notificationRecieveConfig` (`i/update`), reading-mark behaviour.
4. **Email** — show/set email (`i/update-email`), availability check,
   verification state.
5. **Security** — change password, 2FA (TOTP register/done, security-key
   register/done/remove, password-less), sign-in history, password reset entry.
6. **Drive** — link to the existing drive page plus capacity/quota display;
   fold drive settings (default upload sensitivity etc.) here if the API
   exposes them.

Each page is read-modify-write against the SDK, surfaces errors through the
existing failure mapping, and has no phantom toggles: every control maps to a
real API field.

## Phases

1. P1 — profile + privacy.
2. P2 — notifications + email.
3. P3 — security.
4. P4 — drive integration polish (move, rename/metadata update).

## Acceptance criteria

- Each page renders real server state on open.
- Writes round-trip: make a change, reload, the change is shown.
- Errors are user-visible, never silent.
- No control exists without a backing API call.

## Open questions

- The exact `notificationRecieveConfig` shape per event type is confirmed
  against the SDK models at implementation time.
