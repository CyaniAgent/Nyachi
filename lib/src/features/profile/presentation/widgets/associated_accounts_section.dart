import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert';
import 'package:nyachi/src/features/auth/application/auth_service.dart';
import 'package:nyachi/src/features/auth/domain/account.dart';
import 'package:nyachi/src/features/auth/presentation/widgets/add_account_dialog.dart';
import 'package:nyachi/src/features/auth/presentation/widgets/misskey_permissions_sheet.dart';
import 'package:nyachi/src/shared/widgets/cyani_loading_indicator.dart';
import 'package:nyachi/src/shared/widgets/cyani_error_widget.dart';
import 'user_details_view.dart';

/// 统一登录管理器组件，与设置页整体样式保持一致。
class AssociatedAccountsSection extends ConsumerStatefulWidget {
  final bool showRemoveButton;

  const AssociatedAccountsSection({
    super.key,
    this.showRemoveButton = true,
  });

  @override
  ConsumerState<AssociatedAccountsSection> createState() =>
      _AssociatedAccountsSectionState();
}

class _AssociatedAccountsSectionState
    extends ConsumerState<AssociatedAccountsSection> {
  Account? _focusedAccount;

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(authServiceProvider);
    final selectedMisskey = ref
        .watch(selectedMisskeyAccountProvider)
        .asData
        ?.value;

    return accountsAsync.when(
      data: (accounts) {
        if (accounts.isEmpty) {
          return _buildEmptyState(context);
        }

        if (_focusedAccount == null || !accounts.contains(_focusedAccount)) {
          _focusedAccount = selectedMisskey ?? accounts.first;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAccountList(context, accounts, selectedMisskey),
              if (_focusedAccount != null) ...[
                const SizedBox(height: 4),
                _buildFocusedCard(context, _focusedAccount!),
              ],
            ],
          ),
        );
      },
      loading: () => const Center(child: CyaniLoadingIndicator()),
      error: (err, stack) => CyaniErrorWidget(message: err.toString()),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        const SizedBox(height: 40),
        Icon(
          Icons.account_circle_outlined,
          size: 80,
          color: colorScheme.outlineVariant,
        ),
        const SizedBox(height: 16),
        Text(
          'accounts_no_linked'.tr(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => _showAddAccountDialog(context),
          icon: const Icon(Icons.add),
          label: Text('accounts_add_account'.tr()),
        ),
      ],
    );
  }

  Widget _buildAccountList(
    BuildContext context,
    List<Account> accounts,
    Account? selectedMisskey,
  ) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'settings_section_account'.tr(),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 64,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: accounts.length + 1,
              itemBuilder: (context, index) {
                if (index == accounts.length) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _AddAccountButton(
                      onTap: () => _showAddAccountDialog(context),
                    ),
                  );
                }

                final account = accounts[index];
                final isMisskeyActive = account.id == selectedMisskey?.id;
                final isFocused = account.id == _focusedAccount?.id;

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _AccountAvatarItem(
                    account: account,
                    isActive: isMisskeyActive,
                    isFocused: isFocused,
                    onTap: () {
                      setState(() => _focusedAccount = account);
                      if (account.platform == 'misskey') {
                        ref
                            .read(selectedMisskeyAccountProvider.notifier)
                            .select(account);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusedCard(BuildContext context, Account account) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAccountHeader(context, account),
          const SizedBox(height: 12),
          _buildRawDataSection(context, account),
          if (widget.showRemoveButton) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmDelete(context, account),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: Text('accounts_remove_button'.tr()),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => MisskeyPermissionsSheet.show(context),
            icon: const Icon(Icons.key, size: 18),
            label: Text('accounts_view_permissions'.tr()),
          ),
        ],
      ),
    ).animate(key: ValueKey(account.id)).fadeIn().slideY(begin: 0.05, end: 0);
  }

  Widget _buildAccountHeader(BuildContext context, Account account) {
    final theme = Theme.of(context);
    final primaryName = (account.name != null && account.name!.isNotEmpty)
        ? account.name!
        : (account.username ?? 'Unknown');
    final secondaryName =
        account.username != null ? '@${account.username}' : '';

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: CircleAvatar(
            radius: 20,
            backgroundImage: account.avatarUrl != null
                ? NetworkImage(account.avatarUrl!)
                : null,
            child: account.avatarUrl == null
                ? Text(account.username?[0].toUpperCase() ?? '?')
                : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                primaryName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (secondaryName.isNotEmpty)
                Text(
                  secondaryName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
      ],
    );
  }

  Widget _buildRawDataSection(BuildContext context, Account account) {
    final detailsAsync = ref.watch(userDetailsProvider(account));

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        'user_details_raw_data'.tr(),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      leading: Icon(Icons.code, size: 20, color: Theme.of(context).colorScheme.primary),
      children: [
        detailsAsync.when(
          data: (data) => Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.5),
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
          loading: () => const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Center(child: SizedBox(
              width: 24, height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )),
          ),
          error: (err, _) => Padding(
            padding: const EdgeInsets.only(top: 8),
            child: CyaniErrorWidget(message: err.toString()),
          ),
        ),
      ],
    );
  }

  void _showAddAccountDialog(BuildContext context) {
    AddAccountBottomSheet.show(context);
  }

  void _confirmDelete(BuildContext context, Account account) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('accounts_remove_title'.tr()),
        content: Text(
          'accounts_remove_confirm'.tr(
            namedArgs: {'username': account.username ?? 'Unknown'},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('accounts_remove_cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              ref.read(authServiceProvider.notifier).removeAccount(account.id);
              Navigator.pop(ctx);
              setState(() => _focusedAccount = null);
            },
            child: Text(
              'accounts_remove_confirm_button'.tr(),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountAvatarItem extends StatelessWidget {
  final Account account;
  final bool isActive;
  final bool isFocused;
  final VoidCallback onTap;

  const _AccountAvatarItem({
    required this.account,
    required this.isActive,
    required this.isFocused,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = isActive
        ? colorScheme.primary
        : (isFocused ? colorScheme.primary : Colors.transparent);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 2),
            boxShadow: isActive
                ? [BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.25),
                    blurRadius: 4,
                    spreadRadius: 1,
                  )]
                : null,
          ),
          child: CircleAvatar(
            radius: 22,
            backgroundImage:
                account.avatarUrl != null ? NetworkImage(account.avatarUrl!) : null,
            child: account.avatarUrl == null
                ? Text(account.username?[0].toUpperCase() ?? '?')
                : null,
          ),
        ),
      ),
    );
  }
}

class _AddAccountButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddAccountButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Icon(Icons.add, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
