# Security Policy

## Supported scope

| Version/branch | Security support |
|---|---|
| `develop` | Yes (rewrite in progress; best-effort fixes) |
| `main` / `archive/legacy-1.3.4` | Legacy archive; no security fixes |

There is no public release yet. This table will be updated when the rewrite
enters release.

## Reporting a vulnerability

**Do not** disclose vulnerability details through public issues, pull requests,
discussions, or social media.

Use GitHub Security Advisories:

https://github.com/CyaniAgent/Nyachi/security/advisories/new

Please include:

- the affected commit, branch, or version;
- reproduction steps or a minimal proof of concept;
- impact (data exposure, remote code execution, denial of service, etc.);
- a suggested fix, if any;
- whether you want public credit, and how you want to be credited.

Remove tokens, cookies, private messages, server addresses, and other sensitive
data. If you must include them, state that in the advisory and redact them.

## Response targets

This is a personal open-source project without a commercial SLA. Targets:

- acknowledge receipt within 3 business days;
- complete initial triage within 7 business days;
- fix time depends on severity, reproducibility, and maintainer availability.

Do not publish details before a fix is available. We will coordinate a
disclosure date with you.

## Scope

In scope:

- Nyachi application code, build scripts, and release configuration;
- credential storage, logs, caches, TLS/WebSocket connections;
- dependencies and supply-chain configuration;
- update checks and download paths.

Out of scope:

- vulnerabilities in Misskey instances (contact the instance administrator);
- GitHub, app stores, operating systems, and other third-party services;
- social engineering, physical access, and denial-of-service stress testing;
- known issues in the archived legacy code unless they affect the rewrite.

## Security baseline

New code must:

- store tokens only in platform secure storage, never in logs or plaintext
  configuration;
- keep tokens out of URLs, exception messages, and analytics events;
- never disable TLS certificate validation unconditionally; self-signed
  instances require an explicit, revocable user choice;
- review dependency licenses and sources;
- avoid running secret-bearing steps in CI for untrusted forks.

## Credit

With your consent, we will credit reporters in the fix notes. No bug bounty is
offered unless separately agreed in writing.
