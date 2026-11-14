# Privacy Policy

Effective date: 2026-11-14  
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
- Some features may route data through additional services beyond the
  instance (for example, future opt-in push notification delivery). Such a
  feature will not be enabled before this policy is updated to describe it.

### 1.3 Local data

- The client stores settings, caches, logs, and databases locally to improve
  startup and offline behavior.
- You can clear caches/logs in the app settings or clear app data through the
  operating system.
- Logs may contain instance addresses, error messages, and action records. Do
  not share unredacted logs publicly.

### 1.4 Diagnostics and telemetry

As of the effective date, the app's codebase **does not include** telemetry
or analytics SDKs.
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

### 1.6 Microsoft Store crash and analytics data

If you install Nyachi through the Microsoft Store, Microsoft collects its own
installation, crash, and performance data under Microsoft's terms and privacy
policy; that processing is Microsoft's, not the maintainer's.

The maintainer currently does not receive Error Reporting Data or App
Analytics Data from Microsoft. If we enable them later, we will update this
policy before doing so, and we will use that data only to diagnose defects
and improve Nyachi. We will delete any Personal Information it contains
within 30 days of receipt, keep it only on secured systems with restricted
access, not disclose it, and not use it to identify individual users. Only
non-identifying technical data (such as error counts, exception codes, call
stacks, and module lists) would be kept beyond 30 days.

## 2. Purposes and legal bases

We process data only to:

- provide client features (sign-in, timelines, posting, notifications, drive,
  and similar features);
- maintain application security and stability;
- respond to your support, security, or CLA requests;
- comply with legal obligations.

Where data protection laws apply, the legal bases are: performance of a
contract (providing the app's features), your consent where requested,
legitimate interests in security and abuse prevention, and compliance with
legal obligations. This covers the Personal Information Protection Law of
the People's Republic of China (PIPL), the EU General Data Protection
Regulation (GDPR), and Japan's Act on the Protection of Personal
Information (APPI). Where separate consent is required, we will obtain it.

## 3. Sharing and third parties

- **Misskey instances**: the instance you connect to is an independent data
  controller; its privacy policy applies to data on that instance.
- **GitHub**: repositories, issues, PRs, advisories, and the CLA process are
  provided by GitHub.
- **App stores and operating systems**: if you install Nyachi through a
  store such as the Microsoft Store, the store and OS may collect
  installation, crash, or device data under their own terms. The maintainer
  does not receive that data; see section 1.6.
- **skono.dev**: features of the app may access skono.dev or its subdomains
  to fetch resource information. Requests are delivered through the EdgeOne
  CDN, which transiently processes request data such as your IP address.
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

## 6. Your rights and controls

Where applicable law provides, you may:

- access, correct, or delete local data; your settings, caches, logs, and
  databases stay on your device and are reachable through the app or the
  operating system's app-data tools;
- disconnect an account in the app, which removes that account's access
  token from the device;
- clear caches/logs or uninstall the app;
- withdraw consent where processing relies on consent, for example by
  disconnecting an account or uninstalling;
- control what you share: what you post, and to which instance, is chosen by
  you in the app;
- request deletion of personal information you provided on GitHub, except where
  retention is legally required;
- exercise rights regarding instance data with the instance administrator;
  your posts, reactions, follows, and files on an instance are accessed and
  managed through the instance's own settings and tools;
- complain to a supervisory authority.

Under the GDPR (EU/EEA) you may additionally request restriction or
portability of your data and object to processing; under the CCPA/CPRA
(California) the rights above apply as rights to know, access, correct, and
delete; under the APPI (Japan) you may request disclosure, correction,
deletion, or cessation of use.

We do not sell personal information or share it for cross-context behavioral
advertising, and we will not discriminate against you for exercising these
rights.

Contact the maintainer through a GitHub Issue; for sensitive information, use
Security Advisories.

## 7. Children

Nyachi is not directed to children under 13 and does not knowingly collect their
personal information. If the consent age in your jurisdiction is higher, use the
app only after reaching that age. If we learn that a child's data was collected
by mistake, contact us for deletion.

## 8. International transfers

The Misskey instance you choose, GitHub, app stores, operating systems, and
other services the app accesses may be located in other countries or
regions. Using those services may involve cross-border processing; review
their privacy policies. Where required — for example under the GDPR —
transfers rely on safeguards such as adequacy decisions or standard
contractual clauses; under Japan's APPI, we disclose recipient countries
and ensure recipients apply comparable protection measures.

## 9. Changes

We may update this policy. Material changes will be reasonably announced in the
repository and in the app where appropriate, and the effective date will be
updated. Continued use means acceptance of the updated policy; where law
requires consent, we will obtain it separately.

## 10. Contact

- General privacy questions: GitHub Issue (do not include sensitive data).
- Sensitive requests: GitHub Security Advisories.
- Project: https://github.com/CyaniAgent/Nyachi

