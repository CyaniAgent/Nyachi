// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/network/error_mapper.dart';
import '../../../core/network/instance_repository.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../auth/application/anonymous_meta.dart';
import '../../auth/application/compliance_controller.dart';
import '../../auth/application/login_controller.dart';
import '../../auth/presentation/compliance_doc_page.dart';
import '../../auth/presentation/instance_summary_card.dart';
import '../../settings/application/app_settings.dart';
import '../../../app/theme/app_theme.dart';
import '../application/oobe_controller.dart';

/// First-run wizard: language → welcome → compliance + sign-in → appearance
/// → done. No skip and no offline exit; the router guard keeps the app on
/// this route until [SettingsController.completeOobe] persists completion.
class OobePage extends ConsumerWidget {
  const OobePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(oobeControllerProvider);
    final controller = ref.read(oobeControllerProvider.notifier);
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: step == 2 ? 920 : 460),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StepDots(count: 5, index: step),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      child: KeyedSubtree(
                        key: ValueKey<int>(step),
                        child: SingleChildScrollView(
                          child: switch (step) {
                            0 => const _LanguageStep(),
                            1 => const _WelcomeStep(),
                            2 => const _OobeLoginStep(),
                            3 => const _AppearanceStep(),
                            _ => const _DoneStep(),
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (step > 0)
                        TextButton(
                          onPressed: controller.back,
                          child: Text(l10n.oobeBack),
                        ),
                      const Spacer(),
                      // Step 2 advances through the sign-in flow itself;
                      // step 4 advances through its enter button.
                      if (step == 0 || step == 1 || step == 3)
                        FilledButton(
                          onPressed: controller.next,
                          child: Text(l10n.oobeNext),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Wizard progress indicator: one pill per step.
class _StepDots extends StatelessWidget {
  const _StepDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: i == index ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i <= index
                    ? scheme.primary
                    : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
        ],
      ),
    );
  }
}

class _LanguageStep extends ConsumerWidget {
  const _LanguageStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.oobeLanguageTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        RadioGroup<String>(
          groupValue: settings.localeCode,
          onChanged: (value) {
            if (value != null) controller.setLocale(value);
          },
          child: Column(
            children: [
              for (final (code, label) in [
                ('system', l10n.languageSystem),
                ('en', l10n.languageEnglish),
                ('zh', l10n.languageChinese),
                ('ja', l10n.languageJapanese),
              ])
                RadioListTile<String>(value: code, title: Text(label)),
            ],
          ),
        ),
      ],
    );
  }
}

class _WelcomeStep extends ConsumerWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
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
          l10n.oobeWelcomeTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.oobeWelcomeBody,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// Compliance + sign-in step: the full login interaction (host → anonymous
/// meta card → both consents → MiAuth/token) wizard-styled, reusing
/// [LoginController]. If the session is already authenticated (app killed
/// mid-OOBE), only a continue button shows.
class _OobeLoginStep extends ConsumerStatefulWidget {
  const _OobeLoginStep();

  @override
  ConsumerState<_OobeLoginStep> createState() => _OobeLoginStepState();
}

class _OobeLoginStepState extends ConsumerState<_OobeLoginStep> {
  final _host = TextEditingController();
  final _token = TextEditingController();
  final _hostFocus = FocusNode();
  var _showToken = false;
  var _showTokenForm = false;
  String? _normalizedHost;
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

  void _next() {
    ref.read(oobeControllerProvider.notifier).next();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(loginControllerProvider);
    final controller = ref.read(loginControllerProvider.notifier);
    final compliance = ref.watch(complianceControllerProvider);
    final authenticated = ref.watch(sessionControllerProvider).isAuthenticated;
    final scheme = Theme.of(context).colorScheme;

    if (authenticated) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.oobeLoginTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _next,
            icon: const Icon(Icons.arrow_forward),
            label: Text(l10n.oobeLoginDone),
          ),
        ],
      );
    }

    final appChecked = !_appUnchecked && compliance.appAccepted;
    final gateHost = _normalizedHost ?? _currentHost();
    final instanceChecked =
        gateHost != null &&
        compliance.instanceAcceptedHosts.contains(gateHost) &&
        !_instanceUnchecked;
    final canLogin = !state.busy && appChecked && instanceChecked;

    final signInCard = Card(
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
                      final ok = await controller.startMiAuth(_host.text);
                      if (ok) _next();
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
    final complianceSection = _complianceSection(
      l10n,
      appChecked,
      instanceChecked,
    );

    // Wide screens render the sign-in form and the instance summary side by
    // side; compact screens stack them in one column.
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        if (!wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.oobeLoginTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              signInCard,
              _metaSection(l10n),
              complianceSection,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.oobeLoginTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [signInCard, complianceSection],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(child: _metaSection(l10n)),
              ],
            ),
          ],
        );
      },
    );
  }

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
        CheckboxListTile(
          value: appChecked,
          onChanged: (checked) {
            if (checked ?? false) {
              setState(() => _appUnchecked = false);
              ref.read(complianceControllerProvider.notifier).acceptAppTerms();
            } else {
              setState(() => _appUnchecked = true);
            }
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(l10n.agreeAppTerms),
          secondary: TextButton(
            onPressed: _openDocs,
            child: Text(l10n.viewDocument),
          ),
        ),
        if (host != null)
          CheckboxListTile(
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
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(l10n.agreeInstanceTos),
          ),
      ],
    );
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
                    final ok = await controller.loginWithToken(
                      _host.text,
                      _token.text,
                    );
                    if (ok) _next();
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

  Future<void> _copy(Uri uri) async {
    await Clipboard.setData(ClipboardData(text: uri.toString()));
    if (mounted) _snack(context.l10n.copied);
  }

  Future<void> _open(Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) _snack(context.l10n.externalLinkFailed);
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

/// Accent swatch — copied from `settings_page.dart` `_AccentDot` (private
/// there) to keep the appearance controls visually identical.
class _AccentDot extends StatelessWidget {
  const _AccentDot({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? scheme.onSurface : scheme.outlineVariant,
                width: selected ? 2.5 : 1,
              ),
            ),
            child: selected
                ? Icon(
                    Icons.check,
                    size: 18,
                    color:
                        ThemeData.estimateBrightnessForColor(color) ==
                            Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

const _accentColors = [
  ('#3F51B5', 'indigo'),
  ('#E91E63', 'pink'),
  ('#4CAF50', 'green'),
  ('#2196F3', 'blue'),
  ('#FF9800', 'orange'),
];

class _AppearanceStep extends ConsumerWidget {
  const _AppearanceStep();

  String _accentLabel(AppLocalizations l10n, String key) {
    return switch (key) {
      'indigo' => l10n.colorIndigo,
      'pink' => l10n.colorPink,
      'green' => l10n.colorGreen,
      'blue' => l10n.colorBlue,
      'orange' => l10n.colorOrange,
      _ => key,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final instance = ref.watch(instanceInfoProvider).value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.oobeAppearanceTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Text(l10n.accentColor, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _AccentDot(
              label: l10n.instanceColor,
              color: parseThemeColor(instance?.themeColor),
              selected: settings.accentColor == 'instance',
              onTap: () => controller.setAccentColor('instance'),
            ),
            for (final accent in _accentColors)
              _AccentDot(
                label: _accentLabel(l10n, accent.$2),
                color: parseThemeColor(accent.$1),
                selected: settings.accentColor == accent.$1,
                onTap: () => controller.setAccentColor(accent.$1),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text(l10n.theme, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(
              value: 'system',
              label: Text(l10n.themeSystem),
              icon: const Icon(Icons.brightness_auto_outlined),
            ),
            ButtonSegment(
              value: 'light',
              label: Text(l10n.themeLight),
              icon: const Icon(Icons.light_mode_outlined),
            ),
            ButtonSegment(
              value: 'dark',
              label: Text(l10n.themeDark),
              icon: const Icon(Icons.dark_mode_outlined),
            ),
          ],
          selected: {settings.themeMode},
          onSelectionChanged: (selection) {
            final mode = selection.first;
            controller.setThemeMode(mode);
          },
        ),
      ],
    );
  }
}

class _DoneStep extends ConsumerWidget {
  const _DoneStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.oobeDoneTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.oobeDoneBody,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () async {
            await ref.read(oobeControllerProvider.notifier).complete();
            if (!context.mounted) return;
            final authenticated = ref
                .read(sessionControllerProvider)
                .isAuthenticated;
            context.go(authenticated ? '/home' : '/login');
          },
          icon: const Icon(Icons.pets),
          label: Text(l10n.oobeEnterApp),
        ),
      ],
    );
  }
}
