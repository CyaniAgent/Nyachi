# Push notifications plan

## Goal

Notifications reach the user in near-real-time on every platform, in phases,
without inventing server infrastructure in phase 1.

## Current state (verified, with file:line references)

- Notifications are request-only: the list controller refreshes via
  `account.notificationsPage`
  (`lib/features/notifications/application/notification_list_controller.dart:36-43`)
  and caches 50 items (:69-73). No polling and no stream subscription exist
  under `lib/features/notifications/`; the only stream in the app is the home
  timeline (`lib/features/timeline/application/home_stream_service.dart:92-96`).
- The web service worker `web/nyachi_service_worker.js` has install precache
  (:30-37) and stale-while-revalidate fetch (:50-69) handlers, registered from
  `web/index.html:41`, but no `push` or `notificationclick` handlers.
- Misskey server push endpoints exist and the SDK generates them:
  `sw/register`, `sw/show-registration`, `sw/unregister`,
  `sw/update-registration`
  (`misskey_dart_api-0.1.0/lib/src/api/generated/api_manifest.dart:4830-4870`);
  `swRegister` is generated
  (`lib/src/api/generated/account_api.dart:978`, high-level wrapper
  `lib/src/api/high_level/account_api.dart:1239`). Feasibility caveat
  [INFERENCE]: `sw/register` only helps when the instance has the push service
  enabled.
- The Android manifest declares only INTERNET
  (`android/app/src/main/AndroidManifest.xml:4`) — no POST_NOTIFICATIONS, no
  foreground-service permission, no `<service>` declarations.
- No tray/notification/window_manager plugin is in `pubspec.yaml`; the desktop
  runners are stock Flutter templates (`windows/runner/`).

## Decisions (maintainer-confirmed)

- Phase 1 = Web Push (PWA) + in-app realtime via the stream (shared decision
  log).
- Phase 2 = a self-hosted push gateway for all platforms, positioned as an
  optional (possibly sponsor-gated) service (shared decision log).
- Resident = desktop tray + Android foreground service, both in scope (shared
  decision log).

## Design

**Phase 1 — in-app realtime + web push**

- Subscribe the notification channel through the SDK stream module (today only
  the home timeline channel is subscribed,
  `home_stream_service.dart:92-96`) so in-app notifications arrive live; this
  stream is the unread badge/count source.
- Web: extend `web/nyachi_service_worker.js` with `push` and
  `notificationclick` handlers; request the Notification permission; register
  via the SDK's `swRegister` and store the subscription server-side; document
  the instance prerequisite (server push service must be enabled).
- Android/desktop phase 1 scope is in-app only (no background delivery) — the
  foreground service and tray are deliberately deferred to phase 2.

**Phase 2 — resident + background**

- Desktop: tray icon + background process (Windows first); local notifications
  on new events while resident.
- Android: foreground service with a persistent notification;
  POST_NOTIFICATIONS permission.
- Manifest changes and plugin additions are enumerated at implementation — no
  plugin is chosen yet; evaluation happens then.

**Phase 3 — optional gateway**

- Self-hosted relay (VAPID for web, FCM or a parallel channel for Android,
  desktop push) with per-user subscription storage; positioned as an optional
  hosted/sponsor-gated service — the cost note is recorded, the decision
  deferred.

## Phases

1. Phase 1 — notification stream subscription + web push handlers.
2. Phase 2 — desktop tray/resident process; Android foreground service.
3. Phase 3 — optional self-hosted gateway (decision deferred).

## Acceptance criteria

- Phase 1 web: a notification published while the PWA is closed produces a
  system notification.
- Phase 1 in-app: a new note mention appears without manual refresh.
- Phase 2 Windows: closing the window keeps the tray resident and
  notifications still arrive.
- Phase 2 Android: events produce notifications while the app is backgrounded,
  via the persistent-notification foreground service.
- Phase 3: entered only after the maintainer approves the hosted/sponsor-gated
  service.

## Open questions

- Which instances have the push service enabled — needs a runtime probe, same
  pattern as the other capability probes.
- Battery/DOZE behaviour of the Android foreground service.
