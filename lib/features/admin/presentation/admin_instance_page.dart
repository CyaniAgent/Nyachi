// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/network/error_mapper.dart';
import '../../../core/ui/content_width.dart';
import '../../../core/ui/l10n_ext.dart';
import '../data/admin_repository.dart';

/// The instance's own settings: what the site calls itself, whether sign-up is
/// open, and who to contact.
///
/// The form is loaded from the server on open and only the fields that changed
/// are written, so a stale screen cannot overwrite a setting another moderator
/// changed in the meantime.
class AdminInstancePage extends ConsumerStatefulWidget {
  const AdminInstancePage({super.key});

  @override
  ConsumerState<AdminInstancePage> createState() => _AdminInstancePageState();
}

class _AdminInstancePageState extends ConsumerState<AdminInstancePage> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _maintainerName = TextEditingController();
  final _maintainerEmail = TextEditingController();
  var _disableRegistration = false;
  var _emailRequired = false;
  var _loading = true;
  var _saving = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _maintainerName.dispose();
    _maintainerEmail.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final meta = await ref.read(adminRepositoryProvider).meta();
      if (!mounted) return;
      setState(() {
        _name.text = meta.name ?? '';
        _description.text = meta.description ?? '';
        _maintainerName.text = meta.maintainerName ?? '';
        _maintainerEmail.text = meta.maintainerEmail ?? '';
        _disableRegistration = meta.disableRegistration;
        _emailRequired = meta.emailRequiredForSignup;
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

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await ref
          .read(adminRepositoryProvider)
          .updateMeta(
            name: _name.text,
            description: _description.text,
            maintainerName: _maintainerName.text,
            maintainerEmail: _maintainerEmail.text,
            disableRegistration: _disableRegistration,
            emailRequiredForSignup: _emailRequired,
          );
      messenger.showSnackBar(SnackBar(content: Text(l10n.adminSaved)));
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(mapFailure(error).message(l10n))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminInstance),
        actions: [
          if (!_loading)
            TextButton(
              onPressed: _saving ? null : _save,
              child: Text(l10n.save),
            ),
        ],
      ),
      body: _body(l10n),
    );
  }

  Widget _body(AppLocalizations l10n) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final error = _error;
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mapFailure(error).message(l10n), textAlign: TextAlign.center),
            TextButton(onPressed: _load, child: Text(l10n.retry)),
          ],
        ),
      );
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: appMaxContentWidth),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: l10n.adminServerName),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _description,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.adminServerDescription,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _maintainerName,
              decoration: InputDecoration(labelText: l10n.adminMaintainer),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _maintainerEmail,
              decoration: InputDecoration(labelText: l10n.adminMaintainerEmail),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _disableRegistration,
              onChanged: (value) =>
                  setState(() => _disableRegistration = value),
              title: Text(l10n.adminDisableRegistration),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              value: _emailRequired,
              onChanged: (value) => setState(() => _emailRequired = value),
              title: Text(l10n.adminEmailRequired),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
