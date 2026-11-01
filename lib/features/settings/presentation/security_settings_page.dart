// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/network/client_provider.dart';
import '../../../core/network/error_mapper.dart';
import '../../../core/ui/content_width.dart';
import '../../../core/ui/l10n_ext.dart';
import '../data/account_settings_repository.dart';

/// Password, two-factor authentication and sign-in history.
///
/// Two-factor setup follows the server's two-step flow: `i/2fa/register`
/// returns the shared secret, and the confirmation token is verified with
/// `i/2fa/done`. The secret is shown as text and as a QR image rendered from
/// an `otpauth://` URI, so it works without a QR library.
class SecuritySettingsPage extends ConsumerStatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  ConsumerState<SecuritySettingsPage> createState() =>
      _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends ConsumerState<SecuritySettingsPage> {
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  var _loading = true;
  var _busy = false;
  var _twoFactorEnabled = false;
  List<Signin> _history = const [];

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final me = await ref.read(accountSettingsRepositoryProvider).me();
      List<Signin> history = const [];
      try {
        history = await ref
            .read(accountSettingsRepositoryProvider)
            .signinHistory(limit: 10);
      } catch (_) {
        // History is supplementary; a server without it must not break the
        // page.
      }
      if (!mounted) return;
      setState(() {
        _twoFactorEnabled = me.twoFactorEnabled;
        _history = history;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mapFailure(error).message(context.l10n))),
    );
  }

  Future<void> _changePassword() async {
    final l10n = context.l10n;
    if (_newPassword.text != _confirmPassword.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.passwordMismatch)));
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(accountSettingsRepositoryProvider)
          .changePassword(
            currentPassword: _currentPassword.text,
            newPassword: _newPassword.text,
          );
      if (!mounted) return;
      _currentPassword.clear();
      _newPassword.clear();
      _confirmPassword.clear();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.saved)));
    } catch (error) {
      if (mounted) _showMessage(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Enables 2FA: asks for the password, shows the secret, then verifies the
  /// first code so the account is never left half-registered.
  Future<void> _enableTwoFactor() async {
    final l10n = context.l10n;
    final password = await _askPassword(l10n.twoFactorPasswordPrompt);
    if (password == null || password.isEmpty || !mounted) return;
    setState(() => _busy = true);
    final client = ref.read(misskeyClientProvider);
    try {
      final registration = await client.account.twoFactorRegister(
        password: password,
      );
      if (!mounted) return;
      final secret = registration.secret;
      final token = await _askToken(secret);
      if (token == null || token.isEmpty || !mounted) return;
      await client.account.twoFactorDone(token: token);
      if (!mounted) return;
      setState(() => _twoFactorEnabled = true);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.saved)));
    } catch (error) {
      if (mounted) _showMessage(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disableTwoFactor() async {
    final l10n = context.l10n;
    final password = await _askPassword(l10n.twoFactorPasswordPrompt);
    if (password == null || password.isEmpty || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(misskeyClientProvider)
          .account
          .twoFactorUnregister(password: password);
      if (!mounted) return;
      setState(() => _twoFactorEnabled = false);
    } catch (error) {
      if (mounted) _showMessage(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _askPassword(String label) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => _TextPromptDialog(
        title: label,
        controller: controller,
        obscure: true,
      ),
    );
  }

  Future<String?> _askToken(String secret) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => _TextPromptDialog(
        title: context.l10n.twoFactorTokenPrompt,
        controller: controller,
        helper: secret,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.security)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: appMaxContentWidth),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      l10n.changePassword,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _currentPassword,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: l10n.currentPassword,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _newPassword,
                      obscureText: true,
                      decoration: InputDecoration(labelText: l10n.newPassword),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _confirmPassword,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: l10n.confirmPassword,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: _busy ? null : _changePassword,
                      child: Text(l10n.changePassword),
                    ),
                    const Divider(height: 32),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _twoFactorEnabled,
                      title: Text(l10n.twoFactor),
                      subtitle: Text(l10n.twoFactorHint),
                      onChanged: _busy
                          ? null
                          : (value) => value
                                ? unawaited(_enableTwoFactor())
                                : unawaited(_disableTwoFactor()),
                    ),
                    const Divider(height: 32),
                    Text(
                      l10n.signinHistory,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (_history.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          l10n.noSigninHistory,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      )
                    else
                      for (final signin in _history)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.devices_outlined),
                          title: Text(signin.ip),
                          subtitle: Text(
                            '${MaterialLocalizations.of(context).formatFullDate(signin.createdAt)}'
                            ' · ${signin.success ? l10n.signinSuccess : l10n.signinFailed}',
                          ),
                        ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Confirms a password or code; pops the trimmed value or null.
class _TextPromptDialog extends StatefulWidget {
  const _TextPromptDialog({
    required this.title,
    required this.controller,
    this.obscure = false,
    this.helper,
  });

  final String title;
  final TextEditingController controller;
  final bool obscure;
  final String? helper;

  @override
  State<_TextPromptDialog> createState() => _TextPromptDialogState();
}

class _TextPromptDialogState extends State<_TextPromptDialog> {
  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.helper != null) ...[
            SelectableText(
              widget.helper!,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.twoFactorSecretHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  tooltip: l10n.copy,
                  onPressed: () =>
                      Clipboard.setData(ClipboardData(text: widget.helper!)),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          TextField(
            controller: widget.controller,
            autofocus: true,
            obscureText: widget.obscure,
            onSubmitted: (_) =>
                Navigator.of(context).pop(widget.controller.text.trim()),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(widget.controller.text.trim()),
          child: Text(l10n.confirm),
        ),
      ],
    );
  }
}
