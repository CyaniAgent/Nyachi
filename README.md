# Nyachi

Nyachi is a Misskey client being rewritten from scratch. The legacy code is
archived at `archive/legacy-1.3.4`; it is no longer used as rewrite input and is
no longer maintained.

## Status

- Rewrite in progress on `develop`.
- `main` still points to the legacy 1.3.4 line; it will become the stable line
  after the rewrite is ready.
- There is no releasable build yet.
- Legacy snapshot: `archive/legacy-1.3.4` (read-only).

## License and copyright

- Code license: GNU Affero General Public License v3.0 or later
  (`AGPL-3.0-or-later`). See [LICENSE](LICENSE).
- Copyright: Copyright (C) 2026 AyaxYuna.
- Third-party components and assets: see [ATTRIBUTIONS.md](ATTRIBUTIONS.md).
- Project name and marks: see [TRADEMARK.md](TRADEMARK.md).

## Branch model

| Branch | Purpose |
|---|---|
| `main` | Legacy history line; stable release line after the rewrite |
| `develop` | Rewrite integration branch |
| `feature/*` | Feature branches from `develop` |
| `fix/*` | Fix branches from `develop` |
| `release/*` | Release stabilization branches from `develop` |
| `archive/*` | Read-only historical snapshots |

Flow: `feature/*` / `fix/*` → `develop` → `release/*` → `main`.

## Contributing

External contributions require a Contributor License Agreement (CLA):

- [CONTRIBUTING.md](CONTRIBUTING.md)
- [CLA.md](CLA.md) (individual contributors)
- [CLA-CORPORATE.md](CLA-CORPORATE.md) (company/employer contributions)

For security issues, use GitHub Security Advisories and do not publish
vulnerability details in a public issue: [SECURITY.md](SECURITY.md).

## Legal

- [TERMS.md](TERMS.md): terms of use
- [PRIVACY.md](PRIVACY.md): privacy policy
- [TRADEMARK.md](TRADEMARK.md): name and mark usage policy
- [GOVERNANCE.md](GOVERNANCE.md): maintainers, branches, and releases

These documents are project policy drafts, not legal advice. Have counsel
review them before a public release.
