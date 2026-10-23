# Style Guide

## Naming

- Feature directories use plural concept names: `notes`, `notifications`,
  `chat`, `settings`.
- Controllers end with `Controller`; repositories end with `Repository`;
  Freezed data models use domain nouns without suffixes.
- Providers are generated when annotated. Refer to the generated provider name
  (`settingsControllerProvider`, `noteListControllerProvider`), not a hand-made
  alias.
- Files are `snake_case.dart`; classes are `UpperCamelCase`.

## Providers

- Use `@Riverpod(keepAlive: true)` only for session-lifetime services: database,
  preferences, token store, session, client, settings, instance metadata,
  emoji catalog, and note overrides.
- Use auto-dispose for screens and paged data.
- Never read Drift or mutate a controller's state during `build`; schedule async
  hydration with a microtask.
- Every async state write after an `await` checks the controller's disposed flag.

## Widgets and state

- Prefer small `ConsumerWidget`/`ConsumerStatefulWidget` widgets.
- Providers own business state; widgets own ephemeral UI state such as a CW
  reveal or a selected tab.
- Use Material 3 components and `Theme.of(context)` colors; do not hardcode
  colors except media scrims.
- Shell detail links call `openDetail(context, DetailLocation(...))`; do not
  hardcode detail `context.push` calls. The helper chooses the wide panel or a
  full-page route from the breakpoint and the caller's feed/panel origin.
- Media uses `CachedNetworkImage` and `media_kit`. Dispose every player.

## Localization

- All user-facing strings live in `lib/app/l10n/app_{en,zh,ja}.arb`.
- Use `context.l10n`. Do not concatenate translated sentence fragments when a
  placeholder can express the value.
- Counts use `NumberFormat.compact`; times use the shared relative-time helper.

## Errors

- Convert external errors with `mapFailure` before storing them in state.
- Show the localized failure and a retry action; never expose raw URIs, request
  bodies, or tokens.

## Tests

- Test state transitions and cache policy, not widget wiring alone.
- Repositories are represented by interfaces so controllers can use fakes.
- Database tests use `NativeDatabase.memory()`.
- CI regenerates code, runs format, analyze, tests, and a release web build.
