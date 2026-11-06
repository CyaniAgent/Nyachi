# Release codenames

Codenames belong to **pre-releases only**. A beta gets a name, and that name is
retired with the beta's line: it never reaches a stable version, so a later
stable release can still be named whatever fits it. This is what keeps
`2.0.0-beta.9` from consuming a name that `2.0.9` or `2.0.0` might want.

A `beta.N` suffix is a build counter inside one version, not a version of its
own, so every pre-release of `2.1.0` shares one codename. New codenames are
reserved for a new `major.minor.patch`.

Where a codename lives:

- a `### Codename` line at the top of the version's `CHANGELOG.md` section —
  the single source of truth;
- the GitHub release title, which `release.yml` reads from that line;
- nothing else: not the tag, not `pubspec.yaml`, not the artifact names, and
  not the in-app version string, which stays the plain semver the build reports.

Adding one is therefore a one-line edit to the changelog section; if the line is
absent the release simply carries no codename.

| Version line | Codename |
|---|---|
| 2.0.0-beta | Baka |
| 2.1.0-beta | Kumo |

`beta.N` is a build counter within one version, not a new version: every
pre-release of `2.1.0` therefore carries the same codename, and `2.1.0-beta.5`
does not start a second name.