// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/ui/l10n_ext.dart';
import '../application/login_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({this.addAccount = false, super.key});

  final bool addAccount;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _host = TextEditingController();
  final _token = TextEditingController();
  var _showToken = false;

  @override
  void dispose() {
    _host.dispose();
    _token.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(loginControllerProvider);
    final controller = ref.read(loginControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.loginTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            l10n.loginSubtitle,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _host,
            decoration: InputDecoration(
              labelText: l10n.instanceHost,
              hintText: l10n.instanceHostHint,
              border: const OutlineInputBorder(),
            ),
            autocorrect: false,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: state.busy
                ? null
                : () async {
                    if (_host.text.trim().isEmpty) {
                      _snack(l10n.hostRequired);
                      return;
                    }
                    final ok = await controller.startMiAuth(_host.text);
                    if (ok && context.mounted) _done();
                  },
            icon: const Icon(Icons.login),
            label: Text(l10n.miAuthLogin),
          ),
          if (state.waiting) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Center(child: Text(l10n.waitingApproval)),
            if (state.authorizationUri != null)
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: () => _copy(state.authorizationUri!),
                    child: Text(l10n.copyLink),
                  ),
                  TextButton(
                    onPressed: () => _open(state.authorizationUri!),
                    child: Text(l10n.openBrowser),
                  ),
                  TextButton(
                    onPressed: controller.cancel,
                    child: Text(l10n.cancelLogin),
                  ),
                ],
              ),
          ],
          if (state.error != null) ...[
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.error_outline),
                title: Text(state.error!.message(l10n)),
              ),
            ),
          ],
          const SizedBox(height: 24),
          ExpansionTile(
            title: Text(l10n.manualToken),
            children: [
              TextField(
                controller: _token,
                obscureText: !_showToken,
                decoration: InputDecoration(
                  labelText: l10n.token,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _showToken = !_showToken),
                    icon: Icon(
                      _showToken ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
                autocorrect: false,
              ),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: state.busy
                    ? null
                    : () async {
                        if (_host.text.trim().isEmpty) {
                          _snack(l10n.hostRequired);
                          return;
                        }
                        if (_token.text.trim().isEmpty) {
                          _snack(l10n.tokenRequired);
                          return;
                        }
                        final ok = await controller.loginWithToken(
                          _host.text,
                          _token.text,
                        );
                        if (ok && context.mounted) _done();
                      },
                child: Text(l10n.manualToken),
              ),
            ],
          ),
          if (widget.addAccount) ...[
            const SizedBox(height: 12),
            Text(l10n.addAccount, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }

  void _done() {
    context.go('/home');
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _copy(Uri uri) async {
    await Clipboard.setData(ClipboardData(text: uri.toString()));
    if (mounted) _snack(context.l10n.copied);
  }

  Future<void> _open(Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) _snack(context.l10n.externalLinkFailed);
  }
}
