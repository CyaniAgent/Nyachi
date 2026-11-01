// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/error_mapper.dart';
import '../../../core/ui/content_width.dart';
import '../../../core/ui/l10n_ext.dart';
import '../data/account_settings_repository.dart';

/// Sets or changes the account email.
///
/// Misskey requires the current password for this change, and the address is
/// checked against `email-address/available` before the write so the server
/// does not reject an obviously unavailable one.
class EmailSettingsPage extends ConsumerStatefulWidget {
  const EmailSettingsPage({super.key});

  @override
  ConsumerState<EmailSettingsPage> createState() => _EmailSettingsPageState();
}

class _EmailSettingsPageState extends ConsumerState<EmailSettingsPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _loading = true;
  var _saving = false;
  var _available = true;
  String? _current;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final me = await ref.read(accountSettingsRepositoryProvider).me();
      if (!mounted) return;
      setState(() {
        _current = me.email;
        _email.text = me.email ?? '';
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _checkAvailable(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty || !trimmed.contains('@')) {
      setState(() => _available = true);
      return;
    }
    try {
      final available = await ref
          .read(accountSettingsRepositoryProvider)
          .emailAvailable(trimmed);
      if (mounted) setState(() => _available = available);
    } catch (_) {
      // A failed probe must not block the form; the write reports the truth.
      if (mounted) setState(() => _available = true);
    }
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      await ref
          .read(accountSettingsRepositoryProvider)
          .updateEmail(email: _email.text.trim(), password: _password.text);
      if (!mounted) return;
      _password.clear();
      setState(() => _current = _email.text.trim());
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.emailSettings)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: appMaxContentWidth),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_current != null)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.currentEmail),
                        subtitle: Text(_current!),
                      ),
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: l10n.emailAddress,
                        errorText: _available ? null : l10n.emailUnavailable,
                      ),
                      onChanged: (value) => unawaited(_checkAvailable(value)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _password,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: l10n.currentPassword,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _saving || !_available ? null : _save,
                      child: Text(l10n.save),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.emailPasswordHint,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
