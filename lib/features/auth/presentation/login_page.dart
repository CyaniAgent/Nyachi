// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/error_mapper.dart';
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
  var _showTokenForm = false;

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
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.pets,
                        size: 32,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.addAccount ? l10n.addAccount : l10n.appTitle,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.loginTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.loginSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _host,
                            decoration: InputDecoration(
                              labelText: l10n.instanceHost,
                              hintText: l10n.instanceHostHint,
                            ),
                            autocorrect: false,
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: state.busy
                                ? null
                                : () async {
                                    if (_host.text.trim().isEmpty) {
                                      _snack(l10n.hostRequired);
                                      return;
                                    }
                                    final ok = await controller.startMiAuth(
                                      _host.text,
                                    );
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
                                    onPressed: () =>
                                        _copy(state.authorizationUri!),
                                    child: Text(l10n.copyLink),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        _open(state.authorizationUri!),
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
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: scheme.errorContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: scheme.onErrorContainer,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      state.error!.kind == AppFailureKind.auth
                                          ? l10n.loginFailed
                                          : state.error!.message(l10n),
                                      style: TextStyle(
                                        color: scheme.onErrorContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          if (!_showTokenForm)
                            OutlinedButton.icon(
                              onPressed: state.busy
                                  ? null
                                  : () => setState(() => _showTokenForm = true),
                              icon: const Icon(Icons.key_outlined),
                              label: Text(l10n.manualToken),
                            )
                          else ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                l10n.manualToken,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _token,
                              obscureText: !_showToken,
                              decoration: InputDecoration(
                                labelText: l10n.token,
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      setState(() => _showToken = !_showToken),
                                  icon: Icon(
                                    _showToken
                                        ? Icons.visibility_off
                                        : Icons.visibility,
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
                                      final ok = await controller
                                          .loginWithToken(
                                            _host.text,
                                            _token.text,
                                          );
                                      if (ok && context.mounted) _done();
                                    },
                              child: Text(l10n.signIn),
                            ),
                            TextButton(
                              onPressed: state.busy
                                  ? null
                                  : () =>
                                        setState(() => _showTokenForm = false),
                              child: Text(l10n.cancel),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
