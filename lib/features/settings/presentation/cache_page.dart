// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_manager.dart';
import '../../../core/network/instance_repository.dart';
import '../../../core/ui/content_width.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../notes/application/emoji_catalog.dart';
import '../../notifications/application/notification_list_controller.dart';

/// Lists every managed cache kind with its entry count and byte size and
/// lets the user clear one kind or everything.
class CacheSettingsPage extends ConsumerStatefulWidget {
  const CacheSettingsPage({super.key});

  @override
  ConsumerState<CacheSettingsPage> createState() => _CacheSettingsPageState();
}

class _CacheSettingsPageState extends ConsumerState<CacheSettingsPage> {
  late Future<Map<CacheKind, CacheKindStats>> _stats;

  @override
  void initState() {
    super.initState();
    _stats = ref.read(cacheManagerProvider).statsAll();
  }

  void _reload() {
    setState(() {
      _stats = ref.read(cacheManagerProvider).statsAll();
    });
  }

  /// Drops the in-memory providers fed by the cleared cache so the next
  /// access refetches instead of serving what was just deleted.
  void _invalidateConsumers(CacheKind kind) => switch (kind) {
    CacheKind.instanceMeta => ref.invalidate(instanceInfoProvider),
    CacheKind.emojiCatalog => ref.invalidate(emojiCatalogProvider),
    CacheKind.notifications => ref.invalidate(
      notificationListControllerProvider,
    ),
  };

  Future<void> _clear(CacheKind kind) => _clearWithConfirm(
    message: context.l10n.cacheClearConfirm,
    action: () => ref.read(cacheManagerProvider).clear(kind),
    consumers: () => _invalidateConsumers(kind),
  );

  Future<void> _clearAll() => _clearWithConfirm(
    message: context.l10n.cacheClearAllConfirm,
    action: () => ref.read(cacheManagerProvider).clearAll(),
    consumers: () {
      ref.invalidate(instanceInfoProvider);
      ref.invalidate(emojiCatalogProvider);
      ref.invalidate(notificationListControllerProvider);
    },
  );

  Future<void> _clearWithConfirm({
    required String message,
    required Future<void> Function() action,
    required void Function() consumers,
  }) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.clear),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await action();
    consumers();
    if (!mounted) return;
    _reload();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.cacheCleared)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final labels = {
      CacheKind.instanceMeta: l10n.cacheKindInstanceMeta,
      CacheKind.emojiCatalog: l10n.cacheKindEmojiCatalog,
      CacheKind.notifications: l10n.cacheKindNotifications,
    };
    return Scaffold(
      appBar: AppBar(title: Text(l10n.cacheManagement)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: appMaxContentWidth),
          child: FutureBuilder<Map<CacheKind, CacheKindStats>>(
            future: _stats,
            builder: (context, snapshot) {
              final stats = snapshot.data;
              return ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  for (final kind in CacheKind.values) ...[
                    ListTile(
                      leading: Icon(_iconFor(kind)),
                      title: Text(labels[kind]!),
                      subtitle: stats == null
                          ? null
                          : Text(
                              '${l10n.cacheEntryCount(stats[kind]!.entries)}'
                              ' · ${_formatBytes(stats[kind]!.bytes)}',
                            ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: l10n.clearCache,
                        onPressed: stats == null ? null : () => _clear(kind),
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                  ListTile(
                    leading: Icon(
                      Icons.delete_sweep_outlined,
                      color: scheme.error,
                    ),
                    title: Text(
                      l10n.clearAllCaches,
                      style: TextStyle(color: scheme.error),
                    ),
                    onTap: stats == null ? null : _clearAll,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  IconData _iconFor(CacheKind kind) => switch (kind) {
    CacheKind.instanceMeta => Icons.dns_outlined,
    CacheKind.emojiCatalog => Icons.emoji_emotions_outlined,
    CacheKind.notifications => Icons.notifications_outlined,
  };
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(kb < 10 ? 1 : 0)} KB';
  final mb = kb / 1024;
  if (mb < 1024) return '${mb.toStringAsFixed(mb < 10 ? 1 : 0)} MB';
  return '${(mb / 1024).toStringAsFixed(1)} GB';
}
