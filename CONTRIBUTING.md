# Contributing

Thank you for contributing to Nyachi. Read this file before submitting code,
documentation, translations, designs, or other materials.

## 1. Contributor License Agreement (CLA)

Contributions are not accepted without a CLA. On your first pull request:

1. Read [CLA.md](CLA.md). For company or employer contributions, read
   [CLA-CORPORATE.md](CLA-CORPORATE.md).
2. Comment on the PR using the text below, replacing the handle with your
   GitHub username:

   ```text
   I have read and agree to the Nyachi Contributor License Agreement v1.0.
   GitHub username: @your-handle
   ```

3. A maintainer will record the acceptance. Once CLA Assistant is configured,
   its check is authoritative.

The CLA grants a perpetual, irrevocable, worldwide, royalty-free,
non-exclusive, transferable, sublicensable license that allows the project to
use contributions under AGPL-3.0-or-later or commercial/proprietary terms.
Contributors retain copyright.

## 2. Branches and pull requests

- Create feature branches from `develop`: `feature/<short-slug>`.
- Use `fix/<short-slug>` for fixes.
- Keep one PR focused on one change. Avoid unrelated formatting or renames.
- Target `develop` with your PR. Maintainers handle merges into `release/*`
  and `main`.
- In the PR description, explain what changed, why, how it was verified, and
  which issue it addresses.

## 3. Code requirements

- Run before submitting:
  - `dart format .`
  - `flutter analyze`
  - `flutter test`
- New behavior should have tests. Bug fixes should include a regression test,
  or explain why one is not practical.
- Do not commit keys, tokens, private keys, signing files, `.env` files, or
  real user data.
- New source files should use the SPDX header:

  ```dart
  // SPDX-License-Identifier: AGPL-3.0-or-later
  ```

- Follow the repository's current policy on committing generated files. Do not
  hand-edit generated files.
- Do not introduce code or assets incompatible with AGPL-3.0-or-later.
- When adding third-party code or assets, record the source, license, and
  copyright, and update [ATTRIBUTIONS.md](ATTRIBUTIONS.md).
- AI-assisted contributions are allowed if you understand, review, and have the
  right to submit them. You are responsible for them to the same extent as
  hand-written code.

## 4. Conduct and security

- All participants must follow [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
- Do not open a public issue for a security vulnerability. Use GitHub Security
  Advisories; see [SECURITY.md](SECURITY.md).
- Do not paste tokens, cookies, private messages, or other sensitive data into
  issues, PRs, or logs.

## 5. Licensing

By submitting a contribution, you agree that it is licensed to the project
under [CLA.md](CLA.md) and may be distributed to the public under
AGPL-3.0-or-later. The project does not assume an obligation to use, support,
or compensate your contribution.
