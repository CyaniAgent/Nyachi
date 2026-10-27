# Privacy Policy

Effective date: 2026-10-22  
Controller: SakuraCake (individual)  
Project: Nyachi

This policy explains how the Nyachi client handles data. Nyachi is a Misskey
client, not the operator of a Misskey instance. Your account, content, and data
on an instance are controlled by that instance's administrator.

## 1. Data we process

### 1.1 Account and credentials

- When you sign in to a Misskey instance, the client receives an access token
  issued by that instance.
- The rewrite is designed to store tokens in platform secure storage (for
  example Keychain, Keystore, libsecret, or DPAPI), not in plaintext
  configuration or logs.
- Tokens are used only to make requests to the Misskey instance you choose.
  They are not sent to the project maintainer's servers.

### 1.2 Content and actions

- Content you post, read, search, upload, or delete is sent directly to the
  Misskey instance you choose.
- The project maintainer does not operate those instances and does not host your
  posts, private messages, files, or account data.
- Instance administrators may log, process, or publish data under their own
  privacy policies.

### 1.3 Local data

- The client stores settings, caches, logs, and databases locally to improve
  startup and offline behavior.
- You can clear caches/logs in the app settings or clear app data through the
  operating system.
- Logs may contain instance addresses, error messages, and action records. Do
  not share unredacted logs publicly.

### 1.4 Diagnostics and telemetry

The current rewrite codebase **does not include** telemetry or analytics SDKs.
We plan to evaluate whether anonymous crash or usage statistics are needed, but
no decision has been made. If we add them, we will update this policy before
release and explain:

- the fields collected and their purpose;
- the third-party service used;
- the retention period;
- how to opt out;
- the applicable consent mechanism.

We will not enable telemetry before updating this policy and obtaining consent
where required.

### 1.5 GitHub interactions

Information you provide through GitHub issues, PRs, Security Advisories, or the
CLA process is processed by GitHub under GitHub's privacy policy. Do not post
tokens, private messages, or other sensitive data in public issues.

## 2. Purposes and legal bases

We process data only to:

- provide client features (sign-in, timelines, posting, notifications, drive,
  and similar features);
- maintain application security and stability;
- respond to your support, security, or CLA requests;
- comply with legal obligations.

Where the Personal Information Protection Law of the People's Republic of China
or other laws apply, the legal basis may be performance of a contract, consent,
compliance with a legal obligation, or necessity for security. Where separate
consent is required, we will obtain it.

## 3. Sharing and third parties

- **Misskey instances**: the instance you connect to is an independent data
  controller; its privacy policy applies to data on that instance.
- **GitHub**: repositories, issues, PRs, advisories, and the CLA process are
  provided by GitHub.
- **App stores and operating systems**: if you install through a store, the
  store and OS may collect installation, crash, or device data.
- **Legal requirements**: we may disclose data to authorities when required by
  law, but the project maintainer does not hold your Misskey account data.

We do not sell your personal information.

## 4. Retention

- Local data remains until you clear app data, clear caches/logs, or uninstall
  the app.
- GitHub issues, PRs, and CLA records are retained under GitHub's mechanisms
  unless you request deletion and the law permits it.
- Security reports are retained as long as necessary after the fix and
  disclosure process.

## 5. Security

We take reasonable measures to protect data, including secure token storage,
HTTPS/WSS, and limiting sensitive log data. No system can guarantee absolute
security; use strong credentials, protect your device, and keep the app
updated.

## 6. Your rights

Where applicable law provides, you may:

- access, correct, or delete local data;
- clear caches/logs or uninstall the app;
- request deletion of personal information you provided on GitHub, except where
  retention is legally required;
- exercise rights regarding instance data with the instance administrator;
- complain to a supervisory authority.

Contact the maintainer through a GitHub Issue; for sensitive information, use
Security Advisories.

## 7. Children

Nyachi is not directed to children under 13 and does not knowingly collect their
personal information. If the consent age in your jurisdiction is higher, use the
app only after reaching that age. If we learn that a child's data was collected
by mistake, contact us for deletion.

## 8. International transfers

The Misskey instance you choose, GitHub, app stores, and operating systems may be
located in other countries or regions. Using those services may involve
cross-border processing; review their privacy policies.

## 9. Changes

We may update this policy. Material changes will be reasonably announced in the
repository and in the app where appropriate, and the effective date will be
updated. Continued use means acceptance of the updated policy; where law
requires consent, we will obtain it separately.

## 10. Contact

- General privacy questions: GitHub Issue (do not include sensitive data).
- Sensitive requests: GitHub Security Advisories.
- Project: https://github.com/CyaniAgent/Nyachi

