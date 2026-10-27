// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/network/client_provider.dart';
import '../../../core/network/error_mapper.dart';
import '../../../core/ui/avatar.dart';
import '../../../core/ui/l10n_ext.dart';

/// Picks the recipients for a direct (`specified`) note.
///
/// Returns the selected user ids, or null when dismissed.
Future<List<String>?> showRecipientPicker(
  BuildContext context, {
  required List<String> preselected,
}) {
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _RecipientPicker(preselected: preselected),
  );
}

class _RecipientPicker extends ConsumerStatefulWidget {
  const _RecipientPicker({required this.preselected});

  final List<String> preselected;

  @override
  ConsumerState<_RecipientPicker> createState() => _RecipientPickerState();
}

class _RecipientPickerState extends ConsumerState<_RecipientPicker> {
  final _controller = TextEditingController();
  late final Set<String> _selected = {...widget.preselected};
  final Map<String, User> _known = {};
  Timer? _debounce;
  List<User> _results = const [];
  var _loading = false;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _search(String query) {
    _debounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _results = const [];
        _error = null;
        _loading = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      setState(() {
        _loading = true;
        _error = null;
      });
      try {
        final users = await ref
            .read(misskeyClientProvider)
            .users
            .search(query: trimmed, limit: 20);
        if (!mounted) return;
        setState(() {
          _results = users;
          for (final user in users) {
            _known[user.id] = user;
          }
          _loading = false;
        });
      } catch (error) {
        if (!mounted) return;
        setState(() {
          _error = mapFailure(error).message(context.l10n);
          _loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.75,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.searchUsers,
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
                onChanged: _search,
              ),
            ),
            if (_selected.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final id in _selected)
                      InputChip(
                        label: Text(_known[id]?.name ?? id),
                        onDeleted: () => setState(() => _selected.remove(id)),
                      ),
                  ],
                ),
              ),
            if (_loading) const LinearProgressIndicator(minHeight: 2),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _error!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            Expanded(
              child: _results.isEmpty
                  ? Center(
                      child: Text(
                        _controller.text.trim().isEmpty
                            ? l10n.selectRecipients
                            : l10n.noResults,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final user = _results[index];
                        final selected = _selected.contains(user.id);
                        return CheckboxListTile(
                          value: selected,
                          onChanged: (value) => setState(() {
                            if (value == true) {
                              _selected.add(user.id);
                            } else {
                              _selected.remove(user.id);
                            }
                          }),
                          secondary: NyachiAvatar(
                            url: user.avatarUrl,
                            size: 36,
                          ),
                          title: Text(user.name ?? user.username),
                          subtitle: Text('@${user.username}'),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () =>
                        Navigator.of(context).pop(_selected.toList()),
                    child: Text(l10n.create),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
