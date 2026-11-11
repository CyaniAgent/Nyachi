// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/network/error_mapper.dart';
import '../../../core/ui/content_width.dart';
import '../../../core/ui/l10n_ext.dart';
import '../data/admin_repository.dart';

/// Queues, relays and server facts.
///
/// The queues are the reason this screen exists: when federated delivery stalls
/// the answer is almost always here, either a paused queue or a growing pile of
/// failed jobs. Relays are editable in place because adding one is a single
/// string and the list is short.
class AdminSystemPage extends ConsumerStatefulWidget {
  const AdminSystemPage({super.key});

  @override
  ConsumerState<AdminSystemPage> createState() => _AdminSystemPageState();
}

class _AdminSystemPageState extends ConsumerState<AdminSystemPage> {
  AdminServerInfoResponse? _info;
  List<AdminQueueQueuesResponseItem>? _queues;
  List<AdminRelaysListResponseItem>? _relays;
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
      final repo = ref.read(adminRepositoryProvider);
      final results = await Future.wait([
        repo.serverInfo(),
        repo.queues(),
        repo.relays(),
      ]);
      if (!mounted) return;
      setState(() {
        _info = results[0] as AdminServerInfoResponse;
        _queues = results[1] as List<AdminQueueQueuesResponseItem>;
        _relays = results[2] as List<AdminRelaysListResponseItem>;
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminSystem),
        actions: [
          IconButton(
            tooltip: l10n.retry,
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    if (_loading) return const Center(child: CircularProgressIndicator());
    final error = _error;
    if (error != null) {
      return Center(
        child: Text(
          mapFailure(error).message(l10n),
          textAlign: TextAlign.center,
        ),
      );
    }
    final info = _info!;
    final queues = _queues!;
    final relays = _relays!;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: appMaxContentWidth),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            _SectionHeader(title: l10n.adminSystem),
            ListTile(
              title: const Text('OS'),
              subtitle: Text('${info.os} ${info.node}'),
            ),
            ListTile(
              title: const Text('PostgreSQL'),
              subtitle: Text(info.psql),
            ),
            const Divider(height: 1),
            _SectionHeader(title: l10n.adminQueueName),
            if (queues.isEmpty)
              ListTile(title: Text(l10n.nothingHere))
            else
              ...queues.map(
                (queue) => ListTile(
                  leading: Icon(
                    queue.isPaused ? Icons.pause_circle : Icons.play_circle,
                    color: queue.isPaused
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                  ),
                  title: Text(queue.name.name),
                  subtitle: Text(
                    queue.isPaused
                        ? l10n.adminQueuePaused
                        : l10n.adminQueueActive,
                  ),
                ),
              ),
            const Divider(height: 1),
            _SectionHeader(title: l10n.adminRelays),
            if (relays.isEmpty)
              ListTile(title: Text(l10n.nothingHere))
            else
              ...relays.map(
                (relay) => ListTile(
                  title: Text(relay.inbox),
                  trailing: IconButton(
                    tooltip: l10n.adminRemove,
                    onPressed: () => _removeRelay(relay.inbox),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              ),
            ListTile(
              leading: const Icon(Icons.add),
              title: Text(l10n.adminAddRelay),
              onTap: _addRelay,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeRelay(String inbox) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(adminRepositoryProvider).removeRelay(inbox);
      await _load();
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(mapFailure(error).message(l10n))),
      );
    }
  }

  Future<void> _addRelay() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final controller = TextEditingController();
    final inbox = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.adminAddRelay),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'https://relay.example/inbox',
            labelText: l10n.adminRelayInbox,
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (inbox == null || inbox.trim().isEmpty) return;
    try {
      await ref.read(adminRepositoryProvider).addRelay(inbox.trim());
      await _load();
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(mapFailure(error).message(l10n))),
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
