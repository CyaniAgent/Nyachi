// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/network/error_mapper.dart';
import '../../../core/ui/avatar.dart';
import '../../../core/ui/content_width.dart';
import '../../../core/ui/l10n_ext.dart';
import '../data/admin_repository.dart';

/// Account search and per-account moderation.
///
/// Every action here is destructive or security-relevant, so each one either
/// confirms first (suspend) or reports what the server returned (a reset
/// password). The moderation note is the one plain edit: it is a record for
/// other moderators, not an action on the account.
class AdminUsersPage extends ConsumerStatefulWidget {
  const AdminUsersPage({super.key});

  @override
  ConsumerState<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends ConsumerState<AdminUsersPage> {
  final _query = TextEditingController();
  List<UserDetailed>? _users;
  Object? _error;
  var _loading = true;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    unawaited(_search());
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final users = await ref
          .read(adminRepositoryProvider)
          .users(query: _query.text, limit: 30);
      if (!mounted) return;
      setState(() {
        _users = users;
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

  Future<void> _run(Future<String?> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      final message = await action();
      if (message != null) {
        messenger.showSnackBar(SnackBar(content: Text(message)));
      }
      await _search();
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(mapFailure(error).message(l10n))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminUsers)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: appMaxContentWidth),
                child: TextField(
                  controller: _query,
                  decoration: InputDecoration(
                    hintText: l10n.adminSearchUsers,
                    prefixIcon: const Icon(Icons.search),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(),
                ),
              ),
            ),
          ),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    final l10n = context.l10n;
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
    final users = _users ?? const <UserDetailed>[];
    if (users.isEmpty) return Center(child: Text(l10n.nothingHere));
    // The message is resolved before the request starts: `context.l10n` after
    // an await would be a use of context across an async gap.
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: users.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final userId = users[index].id;
        return _UserTile(
          user: users[index],
          busy: _busy,
          onSuspend: () => _run(() async {
            await ref.read(adminRepositoryProvider).suspendUser(userId);
            return l10n.adminSuspended;
          }),
          onUnsuspend: () => _run(() async {
            await ref.read(adminRepositoryProvider).unsuspendUser(userId);
            return l10n.adminUnsuspended;
          }),
          onResetPassword: () => _run(() async {
            final result = await ref
                .read(adminRepositoryProvider)
                .resetPassword(userId);
            return l10n.adminPasswordReset(result.password);
          }),
          onUnsetMfa: () => _run(() async {
            await ref.read(adminRepositoryProvider).unsetMfa(userId);
            return l10n.adminSaved;
          }),
          onUnsetAvatar: () => _run(() async {
            await ref.read(adminRepositoryProvider).unsetAvatar(userId);
            return l10n.adminSaved;
          }),
          onUnsetBanner: () => _run(() async {
            await ref.read(adminRepositoryProvider).unsetBanner(userId);
            return l10n.adminSaved;
          }),
          onNote: (note) => _run(() async {
            await ref.read(adminRepositoryProvider).setUserNote(userId, note);
            return l10n.adminNoteSaved;
          }),
        );
      },
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.user,
    required this.busy,
    required this.onSuspend,
    required this.onUnsuspend,
    required this.onResetPassword,
    required this.onUnsetMfa,
    required this.onUnsetAvatar,
    required this.onUnsetBanner,
    required this.onNote,
  });

  final UserDetailed user;
  final bool busy;
  final VoidCallback onSuspend;
  final VoidCallback onUnsuspend;
  final VoidCallback onResetPassword;
  final VoidCallback onUnsetMfa;
  final VoidCallback onUnsetAvatar;
  final VoidCallback onUnsetBanner;
  final ValueChanged<String> onNote;

  Future<void> _confirmAndSuspend(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.adminSuspend),
        content: Text(l10n.adminConfirmSuspend),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.adminSuspend),
          ),
        ],
      ),
    );
    if (confirmed ?? false) onSuspend();
  }

  Future<void> _editNote(BuildContext context) async {
    final l10n = context.l10n;
    final controller = TextEditingController(text: user.moderationNote ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.adminNote),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 5,
          decoration: InputDecoration(hintText: l10n.adminNote),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(l10n.adminSaveNote),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null) onNote(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final suspended = user.isSuspended;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: NyachiAvatar(url: user.avatarUrl, size: 36),
      title: Row(
        children: [
          Flexible(
            child: Text(
              user.name ?? user.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (suspended) ...[
            const SizedBox(width: 6),
            Icon(Icons.block, size: 14, color: theme.colorScheme.error),
          ],
        ],
      ),
      subtitle: Text(
        '@${user.username}${user.host == null ? '' : '@${user.host}'}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: PopupMenuButton<String>(
        enabled: !busy,
        onSelected: (value) {
          switch (value) {
            case 'suspend':
              _confirmAndSuspend(context);
            case 'unsuspend':
              onUnsuspend();
            case 'password':
              onResetPassword();
            case 'mfa':
              onUnsetMfa();
            case 'avatar':
              onUnsetAvatar();
            case 'banner':
              onUnsetBanner();
            case 'note':
              _editNote(context);
          }
        },
        itemBuilder: (context) => [
          if (suspended)
            PopupMenuItem(value: 'unsuspend', child: Text(l10n.adminUnsuspend))
          else
            PopupMenuItem(value: 'suspend', child: Text(l10n.adminSuspend)),
          PopupMenuItem(value: 'note', child: Text(l10n.adminNote)),
          PopupMenuItem(
            value: 'password',
            child: Text(l10n.adminResetPassword),
          ),
          PopupMenuItem(value: 'mfa', child: Text(l10n.adminUnsetMfa)),
          PopupMenuItem(value: 'avatar', child: Text(l10n.adminUnsetAvatar)),
          PopupMenuItem(value: 'banner', child: Text(l10n.adminUnsetBanner)),
        ],
      ),
    );
  }
}
