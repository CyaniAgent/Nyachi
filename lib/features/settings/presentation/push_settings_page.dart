// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/network/client_provider.dart';
import '../../../core/network/error_mapper.dart';
import '../../../core/network/instance_repository.dart';
import '../../../core/push/web_push.dart';
import '../../../core/ui/content_width.dart';
import '../../../core/ui/l10n_ext.dart';

/// Enables browser push notifications for this account.
///
/// Only meaningful on the web target and only when the instance both runs a
/// service worker and publishes a VAPID key; every other case is stated
/// outright instead of showing a control that cannot work.
class PushSettingsPage extends ConsumerStatefulWidget {
  const PushSettingsPage({super.key});

  @override
  ConsumerState<PushSettingsPage> createState() => _PushSettingsPageState();
}

class _PushSettingsPageState extends ConsumerState<PushSettingsPage> {
  var _busy = false;
  var _subscribed = false;

  /// Endpoint of the live subscription, kept so disabling can name the exact
  /// record to drop on the server.
  String? _endpoint;

  Future<void> _enable() async {
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      // The public meta answer omits the VAPID key, so detail is requested
      // explicitly; the extension exposing this is not part of the exported
      // SDK surface, hence the direct call.
      final meta = await ref
          .read(misskeyClientProvider)
          .postModel<MetaDetailed>(
            'meta',
            body: const {'detail': true},
            parser: MetaDetailed.fromJson,
          );
      final key = meta.swPublickey;
      if (key == null || key.isEmpty) {
        _report(l10n.pushNoKey);
        return;
      }
      final subscription = await register(vapidPublicKey: key);
      if (subscription == null) {
        _report(l10n.pushDenied);
        return;
      }
      // The server takes the browser endpoint plus the two subscription keys.
      final client = ref.read(misskeyClientProvider);
      await client.account.swRegister(
        endpoint: subscription.endpoint,
        auth: subscription.auth,
        publickey: subscription.p256dh,
      );
      _endpoint = subscription.endpoint;
      if (!mounted) return;
      setState(() => _subscribed = true);
      _report(l10n.pushEnabled);
    } catch (error) {
      if (mounted) _report(mapFailure(error).message(l10n));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disable() async {
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      // The browser is authoritative for the subscription itself; the server
      // record is dropped afterwards so a failed call cannot leave the user
      // believing push is still on when the browser stopped listening.
      await unregister();
      final endpoint = _endpoint;
      if (endpoint != null) {
        await ref
            .read(misskeyClientProvider)
            .account
            .swUnregister(endpoint: endpoint);
      }
    } catch (_) {
      // Best-effort server cleanup: the local state is corrected either way.
    } finally {
      _endpoint = null;
      if (mounted) {
        setState(() {
          _busy = false;
          _subscribed = false;
        });
      }
      if (mounted) _report(l10n.pushDisabled);
    }
  }

  void _report(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final info = ref.watch(instanceInfoProvider).value;
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
              if (!pushSupported) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.notifications_active_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(l10n.pushSystemTitle),
                  subtitle: Text(l10n.pushSystemHint),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.language_outlined),
                  title: Text(l10n.pushUnsupported),
                  subtitle: Text(l10n.pushUnsupportedHint),
                ),
              ] else if (info != null && !info.serviceWorkerEnabled)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.block_outlined),
                  title: Text(l10n.pushUnavailable),
                  subtitle: Text(l10n.pushUnavailableHint),
                )
              else ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.notifications_active_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(l10n.pushSystemTitle),
                  subtitle: Text(l10n.pushSystemHint),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _subscribed,
                  title: Text(l10n.pushEnable),
                  subtitle: Text(l10n.pushEnableHint),
                  onChanged: _busy
                      ? null
                      : (value) => value
                            ? unawaited(_enable())
                            : unawaited(_disable()),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
