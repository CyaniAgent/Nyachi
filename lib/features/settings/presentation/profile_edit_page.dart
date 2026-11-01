// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/network/error_mapper.dart';
import '../../../core/ui/avatar.dart';
import '../../../core/ui/content_width.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/network_image.dart';
import '../data/account_settings_repository.dart';

/// Edits the signed-in account's profile: identity text, custom fields and
/// the avatar/banner images.
///
/// The page reads the account from the server when opened, so it never edits
/// stale cached values; every control maps to one `i/update` field.
class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController();
  final _birthday = TextEditingController();
  final _fields =
      <({TextEditingController name, TextEditingController value})>[];

  MeDetailed? _me;
  Object? _error;
  var _loading = true;
  var _saving = false;
  var _isBot = false;
  var _isCat = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _location.dispose();
    _birthday.dispose();
    for (final field in _fields) {
      field.name.dispose();
      field.value.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final me = await ref.read(accountSettingsRepositoryProvider).me();
      if (!mounted) return;
      setState(() {
        _me = me;
        _name.text = me.name ?? '';
        _description.text = me.description ?? '';
        _location.text = me.location ?? '';
        _birthday.text = me.birthday ?? '';
        _isBot = me.isBot ?? false;
        _isCat = me.isCat ?? false;
        for (final field in _fields) {
          field.name.dispose();
          field.value.dispose();
        }
        _fields
          ..clear()
          ..addAll([
            for (final field in me.fields)
              (
                name: TextEditingController(text: field.name),
                value: TextEditingController(text: field.value),
              ),
          ]);
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
    setState(() => _saving = true);
    final l10n = context.l10n;
    try {
      final me = await ref
          .read(accountSettingsRepositoryProvider)
          .update(
            name: _name.text.trim(),
            description: _description.text.trim(),
            location: _location.text.trim().isEmpty
                ? null
                : _location.text.trim(),
            birthday: _birthday.text.trim().isEmpty
                ? null
                : _birthday.text.trim(),
            fields: [
              for (final field in _fields)
                if (field.name.text.trim().isNotEmpty)
                  AccountUpdateRequestFieldsItem(
                    name: field.name.text.trim(),
                    value: field.value.text.trim(),
                  ),
            ],
            isBot: _isBot,
            isCat: _isCat,
          );
      if (!mounted) return;
      setState(() => _me = me);
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

  /// Uploads to drive, then writes the new file id to the profile.
  ///
  /// The write is immediate - a chosen image is a committed change, and the
  /// profile picture is the only place it appears.
  Future<void> _pickImage({required bool banner}) async {
    final l10n = context.l10n;
    final picked = await FilePicker.pickFiles(type: FileType.image);
    if (picked.isEmpty || !mounted) return;
    setState(() => _saving = true);
    final repository = ref.read(accountSettingsRepositoryProvider);
    try {
      final file = picked.first;
      final id = await repository.uploadImage(
        bytes: await file.readAsBytes(),
        fileName: file.name,
      );
      final me = await repository.update(
        avatarId: banner ? null : id,
        bannerId: banner ? id : null,
      );
      if (!mounted) return;
      setState(() => _me = me);
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
      appBar: AppBar(
        title: Text(l10n.editProfile),
        actions: [
          TextButton(
            onPressed: _loading || _saving ? null : _save,
            child: Text(l10n.save),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: appMaxContentWidth),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final l10n = context.l10n;
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mapFailure(_error!).message(l10n)),
            const SizedBox(height: 8),
            TextButton(onPressed: _load, child: Text(l10n.retry)),
          ],
        ),
      );
    }
    final me = _me;
    if (me == null) return const SizedBox.shrink();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _BannerHeader(
          avatarUrl: me.avatarUrl,
          bannerUrl: me.bannerUrl,
          onPickAvatar: _saving ? null : () => _pickImage(banner: false),
          onPickBanner: _saving ? null : () => _pickImage(banner: true),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _name,
          decoration: InputDecoration(labelText: l10n.displayName),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _description,
          minLines: 3,
          maxLines: 6,
          decoration: InputDecoration(labelText: l10n.bio),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _location,
          decoration: InputDecoration(labelText: l10n.location),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _birthday,
          decoration: InputDecoration(
            labelText: l10n.birthday,
            hintText: 'YYYY-MM-DD',
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          value: _isBot,
          onChanged: (value) => setState(() => _isBot = value),
          title: Text(l10n.accountTypeBot),
        ),
        SwitchListTile(
          value: _isCat,
          onChanged: (value) => setState(() => _isCat = value),
          title: Text(l10n.accountTypeCat),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.profileFields,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            TextButton.icon(
              onPressed: () => setState(() {
                _fields.add((
                  name: TextEditingController(),
                  value: TextEditingController(),
                ));
              }),
              icon: const Icon(Icons.add),
              label: Text(l10n.addField),
            ),
          ],
        ),
        for (var index = 0; index < _fields.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fields[index].name,
                    decoration: InputDecoration(labelText: l10n.fieldName),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _fields[index].value,
                    decoration: InputDecoration(labelText: l10n.fieldValue),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  tooltip: l10n.delete,
                  onPressed: () => setState(() {
                    final removed = _fields.removeAt(index);
                    removed.name.dispose();
                    removed.value.dispose();
                  }),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Banner strip with the avatar overlapping it; both are tappable.
class _BannerHeader extends StatelessWidget {
  const _BannerHeader({
    required this.avatarUrl,
    required this.bannerUrl,
    required this.onPickAvatar,
    required this.onPickBanner,
  });

  final String avatarUrl;
  final String? bannerUrl;
  final VoidCallback? onPickAvatar;
  final VoidCallback? onPickBanner;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onPickBanner,
          child: SizedBox(
            height: 120,
            width: double.infinity,
            child: bannerUrl == null
                ? ColoredBox(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    child: Center(
                      child: Icon(
                        Icons.add_photo_alternate_outlined,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : NyachiImage(url: bannerUrl!, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            InkWell(
              onTap: onPickAvatar,
              child: NyachiAvatar(url: avatarUrl, size: 56),
            ),
            const SizedBox(width: 12),
            TextButton.icon(
              onPressed: onPickAvatar,
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(l10n.changeAvatar),
            ),
            const SizedBox(width: 4),
            TextButton.icon(
              onPressed: onPickBanner,
              icon: const Icon(Icons.panorama_outlined),
              label: Text(l10n.changeBanner),
            ),
          ],
        ),
      ],
    );
  }
}
