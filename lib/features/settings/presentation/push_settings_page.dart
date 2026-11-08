// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/network/client_provider.dart';
import '../../../core/network/error_mapper.dart';
import '../../../core/platform/residency.dart';
import '../../../core/push/web_push.dart';
import '../../../core/ui/content_width.dart';
import '../../../core/ui/l10n_ext.dart';

/// Tells the user how notifications reach them, and why browser push cannot.
///
/// Misskey's `sw/register` is `secure: true`, which the server reads as "the
/// instance's own session": every client that authenticates with an access
/// token — MiAuth included — is refused with `ACCESS_DENIED`. Nyachi only ever
/// holds tokens, so it has no browser-push path on any instance that carries
/// the fix; saying so is the honest state of the feature, and offering a switch
/// that cannot work would not be.
///
/// A subscription an older build left behind is still removable: the matching
/// `sw/unregister` takes no credentials.
class PushSettingsPage extends ConsumerStatefulWidget {
  const PushSettingsPage({super.key});

  @override
  ConsumerState<PushSettingsPage> createState() => _PushSettingsPageState();
}

class _PushSettingsPageState extends ConsumerState<PushSettingsPage> {
  /// A subscription this browser still holds from an earlier build.
  PushSubscription? _leftover;

  var _busy = false;

  @override
  void initState() {
    super.initState();
    if (pushSupported) _loadLeftover();
  }

  Future<void> _loadLeftover() async {
    try {
      final subscription = await currentSubscription();
      if (!mounted || subscription == null) return;
      setState(() => _leftover = subscription);
    } on Object {
      // Nothing to clean up if the browser will not answer.
    }
  }

  Future<void> _removeLeftover() async {
    final subscription = _leftover;
    if (subscription == null || _busy) return;
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      // Server first: a failed call must not leave a record pointing at a
      // subscription that no longer exists.
      await ref
          .read(misskeyClientProvider)
          .account
          .swUnregisterSubscription(
            endpoint: subscription.endpoint,
            auth: subscription.auth,
            publickey: subscription.p256dh,
          );
      await dropSubscription();
      if (!mounted) return;
      setState(() => _leftover = null);
      _report(l10n.pushLeftoverRemoved);
    } catch (error) {
      if (mounted) _report(mapFailure(error).message(l10n));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _report(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // macOS has no system-notification wiring yet (notificationsSupported is
    // false there), so the page must not claim background delivery on it.
    final systemSupported = ref.watch(residencyProvider).notificationsSupported;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.pushNotifications)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: appMaxContentWidth),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Non-web builds deliver notifications through the resident
              // connection (tray on desktop, foreground service on Android);
              // they get a status page, not a dead end.
              if (systemSupported)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.notifications_active_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(l10n.pushSystemTitle),
                  subtitle: Text(l10n.pushSystemHint),
                )
              else
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.notifications_off_outlined),
                  title: Text(l10n.pushSystemUnavailable),
                  subtitle: Text(l10n.pushSystemUnavailableHint),
                ),
              if (!pushSupported)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.language_outlined),
                  title: Text(l10n.pushUnsupported),
                  subtitle: Text(l10n.pushUnsupportedHint),
                )
              else ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.block_outlined),
                  title: Text(l10n.pushBlockedTitle),
                  subtitle: Text(l10n.pushBlockedHint),
                ),
                if (_leftover != null)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.cleaning_services_outlined),
                    title: Text(l10n.pushLeftover),
                    trailing: TextButton(
                      onPressed: _busy ? null : _removeLeftover,
                      child: Text(l10n.pushLeftoverRemove),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
