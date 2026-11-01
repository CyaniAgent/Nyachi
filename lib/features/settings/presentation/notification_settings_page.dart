// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/network/error_mapper.dart';
import '../../../core/ui/content_width.dart';
import '../../../core/ui/l10n_ext.dart';
import '../data/account_settings_repository.dart';

/// Which delivery channel an event type uses.
enum _Channel { all, normal, none }

/// Per-event notification delivery configuration.
///
/// Each row maps to one field of `notificationRecieveConfig`; the three
/// choices match the server's `{type: all|normal|none}`, so nothing here is a
/// client-only preference.
class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage> {
  /// Event key, matching both the API field and the l10n label.
  static const _events = [
    'note',
    'follow',
    'mention',
    'reply',
    'renote',
    'quote',
    'reaction',
    'pollEnded',
    'receiveFollowRequest',
    'followRequestAccepted',
    'roleAssigned',
    'chatRoomInvitationReceived',
    'achievementEarned',
    'app',
  ];

  final _channels = <String, _Channel>{};
  Object? _error;
  var _loading = true;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final me = await ref.read(accountSettingsRepositoryProvider).me();
      if (!mounted) return;
      setState(() {
        for (final event in _events) {
          final config = me.notificationRecieveConfig.toJson()[event];
          final type = config is Map ? config['type'] as String? : null;
          _channels[event] = switch (type) {
            'normal' => _Channel.normal,
            'none' => _Channel.none,
            _ => _Channel.all,
          };
        }
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    setState(() => _saving = true);
    try {
      final config = AccountUpdateRequestNotificationRecieveConfig(
        note: _map('note'),
        follow: _map('follow'),
        mention: _map('mention'),
        reply: _map('reply'),
        renote: _map('renote'),
        quote: _map('quote'),
        reaction: _map('reaction'),
        pollEnded: _map('pollEnded'),
        receiveFollowRequest: _map('receiveFollowRequest'),
        followRequestAccepted: _map('followRequestAccepted'),
        roleAssigned: _map('roleAssigned'),
        chatRoomInvitationReceived: _map('chatRoomInvitationReceived'),
        achievementEarned: _map('achievementEarned'),
        app: _map('app'),
      );
      await ref
          .read(accountSettingsRepositoryProvider)
          .update(notificationRecieveConfig: config);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.saved)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mapFailure(error).message(l10n))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  JsonMap _map(String event) => {
    'type': switch (_channels[event]) {
      _Channel.normal => 'normal',
      _Channel.none => 'none',
      _ => 'all',
    },
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationSettings),
        actions: [
          TextButton(
            onPressed: _loading || _saving ? null : _save,
            child: Text(l10n.save),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: appMaxContentWidth),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final l10n = context.l10n;
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mapFailure(_error!).message(l10n)),
            const SizedBox(height: 8),
            TextButton(onPressed: _load, child: Text(l10n.retry)),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (final event in _events)
          ListTile(
            title: Text(_eventLabel(l10n, event)),
            trailing: DropdownButton<_Channel>(
              value: _channels[event] ?? _Channel.all,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _channels[event] = value);
              },
              items: [
                DropdownMenuItem(
                  value: _Channel.all,
                  child: Text(l10n.notifyAll),
                ),
                DropdownMenuItem(
                  value: _Channel.normal,
                  child: Text(l10n.notifyNormal),
                ),
                DropdownMenuItem(
                  value: _Channel.none,
                  child: Text(l10n.notifyNone),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _eventLabel(AppLocalizations l10n, String event) => switch (event) {
    'note' => l10n.notifyEventNote,
    'follow' => l10n.notifyEventFollow,
    'mention' => l10n.notifyEventMention,
    'reply' => l10n.notifyEventReply,
    'renote' => l10n.notifyEventRenote,
    'quote' => l10n.notifyEventQuote,
    'reaction' => l10n.notifyEventReaction,
    'pollEnded' => l10n.notifyEventPollEnded,
    'receiveFollowRequest' => l10n.notifyEventReceiveFollowRequest,
    'followRequestAccepted' => l10n.notifyEventFollowRequestAccepted,
    'roleAssigned' => l10n.notifyEventRoleAssigned,
    'chatRoomInvitationReceived' => l10n.notifyEventChatRoomInvitation,
    'achievementEarned' => l10n.notifyEventAchievement,
    _ => l10n.notifyEventApp,
  };
}
