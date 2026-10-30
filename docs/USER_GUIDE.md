# User Guide

A practical tour of Nyachi for everyday use: first launch, signing in,
compliance, appearance, and where to find the instance's rules.

## First launch (OOBE)

The first time Nyachi starts it walks you through a short wizard. The wizard
cannot be skipped — the app needs an account to be useful, and the compliance
steps are mandatory.

1. **Welcome & language** — pick the interface language from the dropdown
   (system, 简体中文, English, 日本語). The page re-renders immediately.
2. **Compliance & sign-in** — read the app terms, accept two checkboxes, and
   sign in (details below).
3. **Appearance** — accent colour (including "instance colour", which follows
   the server you signed in to) and light/dark/system theme.
4. **Done** — enter the app.

Progress shows as animated pills at the top; back/forward arrow buttons move
between steps except on the sign-in step, which is advanced by signing in
itself.

## Compliance

Two granularities, tracked separately:

- **App terms & privacy policy** — one acceptance for the application itself.
  "View" opens the full documents (tabs: Terms of Service / Privacy Policy).
  They ship inside the app, so they work offline.
- **Instance terms** — one acceptance per instance host. The instance card
  opens a detail page with the server rules and the instance's ToS / privacy /
  Impressum links, which open in an embedded browser page. If an instance
  declares a link section but ships empty URLs, those rows appear disabled.

Unchecking a box only blocks sign-in until you re-check it; consent is never
revoked behind your back.

## Signing in

Two options on the compliance step (and later from the login page):

- **MiAuth** — enter the instance host (e.g. `misskey.io`), press the MiAuth
  button; the authorization page opens in your browser, and Nyachi waits for
  approval (up to five minutes, retrying through network hiccups).
- **Access token** — expand "Use an access token" and paste a token from the
  instance's API settings.

The instance card loads as soon as you commit the host field, showing the
server's display name before you sign in.

## Appearance

Settings → Appearance offers the accent colour swatches (indigo, pink, green,
blue, orange) plus "Instance colour", which seeds the theme from the active
server's own branding. Theme mode is a system/light/dark segmented control.

## App icon

The launcher icon is the in-app brand mark: the pets paw on the theme's
container colour. Android uses an adaptive icon (solid background, centred
paw), web icons show the bare paw on transparency.

## Links and documents

- In-app pages open external documents in an embedded browser view, with a
  retry prompt if loading fails.
- The bundled app terms work offline; links inside them that point at the
  source repository are plain text on purpose (they cannot resolve offline).
