// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/network/error_mapper.dart';
import '../../../core/ui/l10n_ext.dart';
import '../application/anonymous_meta.dart';
import '../application/compliance_controller.dart';
import '../application/login_controller.dart';
import 'compliance_doc_page.dart';
import 'instance_summary_card.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({this.addAccount = false, super.key});

  final bool addAccount;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _host = TextEditingController();
  final _token = TextEditingController();
  final _hostFocus = FocusNode();
  var _showToken = false;
  var _showTokenForm = false;

  /// Host committed via blur/submit; keys the anonymous meta card.
  String? _normalizedHost;

  /// Local unchecked mirrors. Consent is never revoked once persisted:
  /// unchecking only blocks the buttons until the user re-checks (which
  /// rewrites `true`).
  var _appUnchecked = false;
  var _instanceUnchecked = false;

  @override
  void initState() {
    super.initState();
    _hostFocus.addListener(_onHostFocusChanged);
  }

  @override
  void dispose() {
    _host.dispose();
    _token.dispose();
    _hostFocus.dispose();
    super.dispose();
  }

  void _onHostFocusChanged() {
    if (!_hostFocus.hasFocus) _commitHost();
  }

  void _commitHost() {
    try {
      final normalized = normalizeHost(_host.text.trim());
      setState(() {
        if (normalized != _normalizedHost) _instanceUnchecked = false;
        _normalizedHost = normalized;
      });
    } on FormatException {
      setState(() {
        _normalizedHost = null;
        _instanceUnchecked = false;
      });
    }
  }

  String? _currentHost() {
    try {
      return normalizeHost(_host.text.trim());
    } on FormatException {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(loginControllerProvider);
    final controller = ref.read(loginControllerProvider.notifier);
    final compliance = ref.watch(complianceControllerProvider);
    final scheme = Theme.of(context).colorScheme;
    final appChecked = !_appUnchecked && compliance.appAccepted;
    final gateHost = _normalizedHost ?? _currentHost();
    final instanceAccepted =
        gateHost != null && compliance.instanceAcceptedHosts.contains(gateHost);
    final instanceChecked = instanceAccepted && !_instanceUnchecked;
    final canLogin = !state.busy && appChecked && instanceChecked;
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
                  _brandHeader(scheme, l10n),
                  _hostInputSection(l10n, state, controller, canLogin),
                  _metaSection(l10n),
                  _complianceSection(l10n, appChecked, instanceChecked),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _brandHeader(ColorScheme scheme, AppLocalizations l10n) {
    return Column(
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
            child: Icon(Icons.pets, size: 32, color: scheme.onPrimaryContainer),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          widget.addAccount ? l10n.addAccount : l10n.appTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 6),
        Text(l10n.loginTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(
          l10n.loginSubtitle,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _hostInputSection(
    AppLocalizations l10n,
    LoginState state,
    LoginController controller,
    bool canLogin,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _host,
              focusNode: _hostFocus,
              decoration: InputDecoration(
                labelText: l10n.instanceHost,
                hintText: l10n.instanceHostHint,
              ),
              autocorrect: false,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _commitHost(),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: canLogin
                  ? () async {
                      if (!_complianceGate(l10n)) return;
                      final ok = await controller.startMiAuth(_host.text);
                      if (ok && context.mounted) _done();
                    }
                  : null,
              icon: const Icon(Icons.login),
              label: Text(l10n.miAuthLogin),
            ),
            _waitingSection(l10n, state, controller),
            _errorSection(l10n, state, scheme),
            _tokenFormSection(l10n, state, controller, canLogin),
          ],
        ),
      ),
    );
  }

  /// Anonymous instance meta: rules and ToS links render once the committed
  /// host resolves; errors surface inline instead of via SnackBar.
  Widget _metaSection(AppLocalizations l10n) {
    final host = _normalizedHost;
    if (host == null) return const SizedBox.shrink();
    final metaAsync = ref.watch(anonymousMetaProvider(host));
    return metaAsync.when(
      data: (meta) => Padding(
        padding: const EdgeInsets.only(top: 16),
        child: InstanceSummaryCard(meta: meta),
      ),
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 16),
        child: LinearProgressIndicator(),
      ),
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(l10n.metaLoadFailed)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _complianceSection(
    AppLocalizations l10n,
    bool appChecked,
    bool instanceChecked,
  ) {
    final host = _normalizedHost;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              value: appChecked,
              onChanged: (checked) {
                if (checked ?? false) {
                  setState(() => _appUnchecked = false);
                  ref
                      .read(complianceControllerProvider.notifier)
                      .acceptAppTerms();
                } else {
                  setState(() => _appUnchecked = true);
                }
              },
            ),
            const SizedBox(width: 4),
            Expanded(child: Text(l10n.agreeAppTerms)),
            TextButton(
              onPressed: () => _openDocs(),
              child: Text(l10n.viewDocument),
            ),
          ],
        ),
        if (host != null)
          Row(
            children: [
              Checkbox(
                value: instanceChecked,
                onChanged: (checked) {
                  if (checked ?? false) {
                    setState(() => _instanceUnchecked = false);
                    ref
                        .read(complianceControllerProvider.notifier)
                        .acceptInstanceForHost(host);
                  } else {
                    setState(() => _instanceUnchecked = true);
                  }
                },
              ),
              const SizedBox(width: 4),
              Expanded(child: Text(l10n.agreeInstanceTos)),
            ],
          ),
      ],
    );
  }

  /// Last-resort guard behind the disabled buttons: if any path reaches a
  /// sign-in handler without consent, hint instead of firing a request.
  bool _complianceGate(AppLocalizations l10n) {
    final compliance = ref.read(complianceControllerProvider);
    final host = _currentHost();
    final ok =
        !_appUnchecked &&
        compliance.appAccepted &&
        host != null &&
        ref
            .read(complianceControllerProvider.notifier)
            .isInstanceAccepted(host);
    if (!ok) _snack(l10n.complianceRequired);
    return ok;
  }

  void _openDocs() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const ComplianceDocPage()),
    );
  }

  Widget _waitingSection(
    AppLocalizations l10n,
    LoginState state,
    LoginController controller,
  ) {
    if (!state.waiting) return const SizedBox.shrink();
    return Column(
      children: [
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
    );
  }

  Widget _errorSection(
    AppLocalizations l10n,
    LoginState state,
    ColorScheme scheme,
  ) {
    final error = state.error;
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: scheme.onErrorContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error.kind == AppFailureKind.auth
                    ? l10n.loginFailed
                    : error.message(l10n),
                style: TextStyle(color: scheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tokenFormSection(
    AppLocalizations l10n,
    LoginState state,
    LoginController controller,
    bool canLogin,
  ) {
    return Column(
      children: [
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
            onPressed: canLogin
                ? () async {
                    if (_token.text.trim().isEmpty) {
                      _snack(l10n.tokenRequired);
                      return;
                    }
                    if (!_complianceGate(l10n)) return;
                    final ok = await controller.loginWithToken(
                      _host.text,
                      _token.text,
                    );
                    if (ok && context.mounted) _done();
                  }
                : null,
            child: Text(l10n.signIn),
          ),
          TextButton(
            onPressed: state.busy
                ? null
                : () => setState(() => _showTokenForm = false),
            child: Text(l10n.cancel),
          ),
        ],
      ],
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
