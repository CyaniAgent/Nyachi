# Governance

## Roles

- **Maintainer**: SakuraCake. Responsible for merges, releases, security
  response, and governance decisions.
- **Copyright holder**: AyaxYuna (individual). Holds the project copyright and
  is the Licensor under the CLA.
- **Contributor**: anyone submitting code, documentation, translations, design,
  or issue reports.
- **User**: anyone using Nyachi.

The maintainer list is defined by GitHub repository permissions. New
maintainers must be confirmed in writing by the current maintainer.

## Decision making

- Day-to-day technical decisions use lazy consensus: raise the matter in an
  issue/PR; if no substantive objection is raised, the maintainer proceeds.
- Licensing, copyright, trademark, security disclosure, and release-blocking
  decisions are made by the maintainer.
- Major architecture changes should start with a proposal (issue or document)
  covering goals, alternatives, migration, and verification.
- The maintainer should explain rejected PRs but is not required to accept
  every contribution.

## Branches

| Branch | Purpose |
|---|---|
| `main` | Stable release line; legacy 1.3.4 is the historical line for now |
| `develop` | Rewrite integration line |
| `feature/*` | Feature branches from `develop` |
| `fix/*` | Fix branches from `develop` |
| `release/*` | Release stabilization branches from `develop` |
| `archive/*` | Read-only historical snapshots |

Flow: `feature/*` / `fix/*` → `develop` → `release/*` → `main`.

## Releases

- Follow SemVer; use `-alpha`, `-beta`, and `-rc` for prereleases.
- Release tags use `vX.Y.Z` and include change notes and known issues.
- Releases must pass formatting, static analysis, tests, and build checks.
- Release artifacts must include the license and third-party notices.
- Never print secrets in CI; inject signing keys only through protected
  secrets.

## Contributions and CLA

External contributions require [CLA.md](CLA.md); company contributions use
[CLA-CORPORATE.md](CLA-CORPORATE.md). The CLA grants a perpetual, irrevocable,
sublicensable license that allows the project to use contributions under
AGPL-3.0-or-later or commercial/proprietary terms.

## License

The project uses AGPL-3.0-or-later. Changing the license requires:

1. a decision by the maintainer and the copyright holder;
2. legal review;
3. the required consents from affected copyright holders/contributors;
4. updates to LICENSE, NOTICE, README, and release notes.

Rights already granted to recipients of an AGPL release cannot be revoked.

## Security

Report security issues privately; see [SECURITY.md](SECURITY.md). Maintainers
should avoid publishing vulnerability details before a fix is released.

## Trademarks

See [TRADEMARK.md](TRADEMARK.md). The code license does not grant trademark
rights.

## Amendments

The maintainer may amend this document and record the change in the repository.
Major changes should allow time for community discussion, but not every comment
must be adopted.
