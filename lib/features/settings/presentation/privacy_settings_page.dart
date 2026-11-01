// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/network/client_provider.dart';
import '../../../core/network/error_mapper.dart';
import '../../../core/ui/avatar.dart';
import '../../../core/ui/content_width.dart';
import '../../../core/ui/l10n_ext.dart';
import '../application/app_settings.dart';

/// Privacy settings: the muted and blocked user lists plus the defaults a
/// new note starts from.
///
/// Lists are read from the server on open and every unblock/unmute writes
/// through immediately, because each row is one concrete relationship.
class PrivacySettingsPage extends ConsumerStatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  ConsumerState<PrivacySettingsPage> createState() =>
      _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends ConsumerState<PrivacySettingsPage> {
  List<Muting>? _muted;
  List<Blocking>? _blocked;
  Object? _error;
  var _loading = true;

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
      final client = ref.read(misskeyClientProvider);
      final muted = await client.mute.list(limit: 50);
      final blocked = await client.blocking.list(limit: 50);
      if (!mounted) return;
      setState(() {
        _muted = muted;
        _blocked = blocked;
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

  Future<void> _unmute(String userId) async {
    final l10n = context.l10n;
    try {
      await ref.read(misskeyClientProvider).mute.delete(userId: userId);
      if (!mounted) return;
      setState(() {
        _muted = [
          for (final item in _muted ?? const <Muting>[])
            if (item.muteeId != userId) item,
        ];
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mapFailure(error).message(l10n))));
    }
  }

  Future<void> _unblock(String userId) async {
    final l10n = context.l10n;
    try {
      await ref.read(misskeyClientProvider).blocking.delete(userId: userId);
      if (!mounted) return;
      setState(() {
        _blocked = [
          for (final item in _blocked ?? const <Blocking>[])
            if (item.blockeeId != userId) item,
        ];
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mapFailure(error).message(l10n))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacy)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: appMaxContentWidth),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _SectionHeader(title: l10n.newNoteDefaults),
              RadioGroup<String>(
                groupValue: settings.defaultVisibility,
                onChanged: (value) {
                  if (value == null) return;
                  unawaited(controller.setDefaultVisibility(value));
                },
                child: Column(
                  children: [
                    for (final visibility in const [
                      'public',
                      'home',
                      'followers',
                    ])
                      RadioListTile<String>(
                        value: visibility,
                        title: Text(_visibilityLabel(l10n, visibility)),
                      ),
                  ],
                ),
              ),
              SwitchListTile(
                value: settings.defaultLocalOnly,
                title: Text(l10n.defaultLocalOnly),
                subtitle: Text(l10n.defaultLocalOnlyHint),
                onChanged: (value) =>
                    unawaited(controller.setDefaultLocalOnly(value)),
              ),
              const Divider(height: 24),
              ..._buildLists(),
            ],
          ),
        ),
      ),
    );
  }

  String _visibilityLabel(AppLocalizations l10n, String visibility) =>
      switch (visibility) {
        'home' => l10n.visibilityHome,
        'followers' => l10n.visibilityFollowers,
        _ => l10n.visibilityPublic,
      };

  List<Widget> _buildLists() {
    final l10n = context.l10n;
    if (_loading) {
      return const [
        Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (_error != null) {
      return [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(mapFailure(_error!).message(l10n)),
              const SizedBox(height: 8),
              TextButton(onPressed: _load, child: Text(l10n.retry)),
            ],
          ),
        ),
      ];
    }
    final muted = _muted ?? const <Muting>[];
    final blocked = _blocked ?? const <Blocking>[];
    return [
      _SectionHeader(title: l10n.mutedUsers),
      if (muted.isEmpty)
        _EmptyRow(text: l10n.noMutedUsers)
      else
        for (final item in muted)
          ListTile(
            leading: NyachiAvatar(url: item.mutee.avatarUrl),
            title: Text(item.mutee.name ?? item.mutee.username),
            trailing: TextButton(
              onPressed: () => _unmute(item.muteeId),
              child: Text(l10n.unmute),
            ),
          ),
      const Divider(height: 24),
      _SectionHeader(title: l10n.blockedUsers),
      if (blocked.isEmpty)
        _EmptyRow(text: l10n.noBlockedUsers)
      else
        for (final item in blocked)
          ListTile(
            leading: NyachiAvatar(url: item.blockee.avatarUrl),
            title: Text(item.blockee.name ?? item.blockee.username),
            trailing: TextButton(
              onPressed: () => _unblock(item.blockeeId),
              child: Text(l10n.unblock),
            ),
          ),
    ];
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleSmall
          ?.copyWith(color: Theme.of(context).colorScheme.primary),
    ),
  );
}

class _EmptyRow extends StatelessWidget {
  const _EmptyRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    child: Text(
      text,
      style: Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
    ),
  );
}
