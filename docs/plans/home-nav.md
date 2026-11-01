# Home & navigation plan

## Goal

Make the start page configurable and the default tab selectable, without disturbing the existing tab model.

## Current state (verified, with file:line references)

- Startup is hard-coded: `initialLocation: '/home'` (`lib/app/router/app_router.dart:41`). The session/OOBE guard `authRedirect` (`lib/app/router/router_guards.dart:13-29`) runs as `GoRouter.redirect` (`lib/app/router/app_router.dart:54-58`): OOBE not completed pins every route to `/oobe` (:23); unauthenticated users are held on `/login` (:25-28).
- No last-page persistence exists anywhere. Persisted state is limited to settings keys (`lib/features/settings/application/app_settings.dart:85-92` — theme, locale, accent color, tab order, hidden tabs, layout keys, `oobe.completed`), the active-account id `session.activeAccountId` (`lib/core/auth/session_controller.dart:23`, written at :132), the detail-panel width `layout.detailPanelWidth` (`lib/app/detail_panel/detail_panel_controller.dart:33`), and composer drafts (drift `Drafts` table, `lib/core/storage/app_database.dart:39-51`, read/saved by `DraftDao` at :214-260; the composer saves on dispose at `lib/features/composer/application/composer_controller.dart:182-197`). Grepping for `lastLocation`/`lastPage`/`lastTab`/`lastRoute` returns nothing.
- Tabs are the `AppTab` enum `{home, notifications, explore, chat, profile}` (`lib/features/settings/application/app_settings.dart:14`). `NavConfig` holds `order` + `visible` (:17-22). `sanitizeNavConfig` forces home to stay visible (:27-35, `..add(AppTab.home)` at :33).
- The config is persisted as `settings.tabOrder` / `settings.hiddenTabs` (`lib/features/settings/application/app_settings.dart:88-89`; read at :99-100, written by `setNavConfig` at :168-179). There is no default-tab or startup setting.
- The editing UI is `NavigationSettingsPage` (`lib/features/settings/presentation/settings_page.dart:187-268`): a `ReorderableListView.builder` (:201) with per-tab visibility `Switch`es (:231-245); home's switch is disabled (:233-234).
- A hidden current tab falls back to home via `shouldFallbackToHome` (`lib/app/router/router_guards.dart:31-33`), called from the shell build (`lib/features/shell/presentation/root_shell.dart:150-155`, post-frame `shell.goBranch(AppTab.home.index)` at :153).
- The bottom-bar profile avatar and the rail avatar (collapsed `IconButton` and extended `InkWell` variants) all just select the profile tab: `onProfile` is wired to `_select(shell, AppTab.profile)` (`lib/features/shell/presentation/root_shell.dart:181-182`; avatar renderings at :282-290, :459-465, :492-499). `_select` (:199-207) closes the detail panel, clears the branch stack to its first route, then `goBranch`.
- Account switching lives in `AccountsSettingsPage` (`lib/features/settings/presentation/settings_page.dart:76-185`): after `switchAccount` it forces `context.go('/home')` (:144-145); sign-out also lands on `/home` (or `/login`) (:182-184). Same-instance multi-account is supported: `addAccount` normalizes the host and reuses the existing row per host+user (`lib/core/auth/session_controller.dart:109-140`), with the `Accounts` table keyed unique on `{host, userId}` (`lib/core/storage/app_database.dart:24-26`, upsert at :129-130).
- Back handling (just changed): a `PopScope` on the shell (`lib/features/shell/presentation/root_shell.dart:166-174`) sets `canPop: !hasStateToUnwind(...)` (:171) and unwinds one layer per press through `unwindAppState` (:173; defined at `lib/app/router/back_navigation.dart:32-52` — detail panel first, then a non-home tab returns to home). At the home root with nothing open, `canPop` is true and the platform default (exit the app) applies.

## Decisions (maintainer-confirmed)

- Startup: a setting offers Timeline (default) / Remember last page / a specific tab.
- Home tabs: only add a "default startup tab" setting — explicitly no in-home edit mode (the maintainer declined it).

## Design

1. New settings keys in `app_settings.dart`: `startupMode` (enum: `timeline` | `lastPage` | `specific`) and `startupTab` (`AppTab`, used only when `startupMode == specific`); a "default startup tab" value is used whenever `startupMode` resolves to a tab (it is also the fallback target for `lastPage` on first run).
2. Router: `initialLocation` becomes a computed value read at `GoRouter` construction (`lib/app/router/app_router.dart:41`) — session/OOBE redirects stay authoritative (`lib/app/router/router_guards.dart:13-29` takes precedence over any startup preference).
3. Last-page persistence: record the matched location on every successful navigation (router listener or route observer) into the settings store; restore it on next start only when `startupMode == lastPage`; sanitize against hidden tabs via the existing `shouldFallbackToHome` rules (`lib/app/router/router_guards.dart:31-33`).
4. The "default startup tab" setting lives in `NavigationSettingsPage` next to the existing order/visibility controls (`lib/features/settings/presentation/settings_page.dart:187-268`); the startup mode control lives there too (a small "Startup" section) — one page, no new top-level entry.
5. Interaction with the back behaviour: restoring a non-home tab means the first back press returns to the timeline (existing unwind logic, `lib/app/router/back_navigation.dart:32-52`) — documented here so the startup choice and back semantics stay consistent.

## Phases

- P1: `startupMode` + `startupTab` settings and router wiring.
- P2: last-page recording/restoration.

## Acceptance criteria

- With `startupMode = specific` and `startupTab = notifications`, a fresh logged-in start lands on `/notifications`.
- With `lastPage`, revisiting after navigating to `/notes/:id` and killing the app restores the last location.
- Hidden-tab fallback still wins over every startup preference.
- OOBE/login gating is unchanged.

## Open questions

- Does "remember last page" also restore pushed detail pages, or only the tab root? Proposal: tab root only, for privacy (a shared machine would otherwise reopen a specific note) — confirm with the maintainer.
