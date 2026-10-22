import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nyachi/src/core/api/misskey_api.dart';
import 'package:nyachi/src/core/core.dart';
import 'package:nyachi/src/features/auth/domain/account.dart';
import 'package:nyachi/src/features/misskey/data/misskey_repository.dart';
import 'package:nyachi/src/features/misskey/domain/misskey_user.dart';
import 'package:nyachi/src/shared/widgets/cyani_loading_indicator.dart';
import 'package:nyachi/src/shared/widgets/cyani_error_widget.dart';

part 'user_details_view.g.dart';

@riverpod
Future<dynamic> userDetails(Ref ref, Account account) async {
  logger.info(
    'UserDetailsView: Fetching details for ${account.platform} account: ${account.id}',
  );
  try {
    if (account.platform == 'misskey') {
      final repo = MisskeyRepository(
        MisskeyApi(host: account.host, token: account.token),
      );
      return await repo.getMe();
    }
    throw Exception('Unknown platform');
  } catch (e) {
    logger.error(
      'UserDetailsView: Error fetching user details for ${account.id}',
      e,
    );
    rethrow;
  }
}

class UserDetailsView extends ConsumerWidget {
  final Account account;

  const UserDetailsView({super.key, required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    logger.info(
      'UserDetailsView: Building details view for ${account.platform} account: ${account.id}',
    );
    final detailsAsync = ref.watch(userDetailsProvider(account));

    return detailsAsync.when(
      data: (data) {
        logger.info(
          'UserDetailsView: Successfully built details view with data',
        );
        return _buildDetails(context, data);
      },
      loading: () {
        logger.info('UserDetailsView: Loading user details');
        return const Center(child: CyaniLoadingIndicator());
      },
      error: (err, stack) {
        logger.error('UserDetailsView: Error building details view', err);
        return CyaniErrorWidget(message: err.toString());
      },
    );
  }

  Widget _buildDetails(BuildContext context, dynamic data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(context, data),
        const SizedBox(height: 20),
        _buildSectionTitle(context, 'user_details_roles_permissions'.tr()),
        _buildRolesCard(context, data),
        const SizedBox(height: 20),
        _buildRawDataCard(context, data),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, dynamic data) {
    final theme = Theme.of(context);

    if (account.platform == 'misskey') {
      final user = data as MisskeyUser;
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'user_details_notes_count'.tr(),
                  user.notesCount?.toString() ?? '0',
                  Icons.notes,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'user_details_following'.tr(),
                  user.followingCount?.toString() ?? '0',
                  Icons.person_add_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'user_details_followers'.tr(),
                  user.followersCount?.toString() ?? '1',
                  Icons.people_outline,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1, end: 0),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDetailRow(
                    context,
                    'user_details_name'.tr(),
                    user.name ?? 'N/A',
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    context,
                    'user_details_username'.tr(),
                    '@${user.username}',
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: primaryColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildRolesCard(BuildContext context, dynamic data) {
    final roles = <String>[];
    if (account.platform == 'misskey') {
      final user = data as MisskeyUser;
      if (user.isAdmin) roles.add('user_details_admin'.tr());
      if (user.isModerator) roles.add('user_details_moderator'.tr());
      if (roles.isEmpty) roles.add('user_details_standard_user'.tr());
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 8,
          children: roles
              .map(
                (r) => Chip(
                  label: Text(r),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildRawDataCard(BuildContext context, dynamic data) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: Text(
          'user_details_raw_data'.tr(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        leading: const Icon(Icons.code),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectableText(
                  const JsonEncoder.withIndent('  ').convert(data),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
