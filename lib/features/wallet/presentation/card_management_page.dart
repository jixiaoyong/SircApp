import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/routes/source_detail_navigation.dart';
import 'package:sirc/widgets/settings_item_tile.dart';

import 'card_brand_label.dart';
import 'controllers/wallet_controller.dart';
import 'wallet_page.dart';

/// 本地卡片管理；不模拟银行解绑，不改动交易记录。
class CardManagementPage extends ConsumerWidget {
  const CardManagementPage({super.key, this.onBack});
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final state = ref.watch(walletControllerProvider);
    final settings = Languages.settings;
    return Scaffold(
      appBar: AppBar(
        title: Text(settings.cardManagement),
        leading: BackButton(onPressed: onBack ?? () => context.go('/wallet')),
        actions: [
          TextButton(
            onPressed: () => openSourceDetail(context, 'add-card?from=cards'),
            child: Text(Languages.addCard),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(settings.cardManagementNotice),
          const SizedBox(height: 16),
          if (state.isLoading) const LinearProgressIndicator(),
          if (state.errorMessage != null)
            WalletPanel(
              child: Row(
                children: [
                  Expanded(child: Text(state.errorMessage!)),
                  TextButton(
                    onPressed: state.isLoading
                        ? null
                        : ref.read(walletControllerProvider.notifier).retry,
                    child: Text(Languages.retry),
                  ),
                ],
              ),
            ),
          if (!state.isLoading && state.errorMessage == null && state.cards.isEmpty)
            WalletPanel(
              child: Column(
                children: [
                  Text(Languages.wallet.noCardsYet),
                  TextButton(
                    onPressed: () =>
                        openSourceDetail(context, 'add-card?from=cards'),
                    child: Text(Languages.addCard),
                  ),
                ],
              ),
            ),
          if (state.cards.isNotEmpty)
            Material(
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (final card in state.cards) ...[
                    if (card != state.cards.first)
                      const Divider(height: 1, indent: 68, endIndent: 16),
                    SettingsItemTile(
                      key: ValueKey('managed-card-${card.id}'),
                      icon: Icons.credit_card_outlined,
                      title: card.bankName,
                      subtitle: [
                        if (card.cardType?.isNotEmpty == true)
                          cardBrandLabel(card.cardType),
                        '•••• ${_lastFour(card.cardNumber)}',
                        card.ownerName,
                      ].join(' · '),
                      onTap: () => openSourceDetail(
                        context,
                        'edit-card/${Uri.encodeComponent(card.id)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            key: ValueKey('edit-card-${card.id}'),
                            constraints: const BoxConstraints(
                              minWidth: 44,
                              minHeight: 44,
                            ),
                            tooltip: settings.edit,
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            onPressed: () => openSourceDetail(
                              context,
                              'edit-card/${Uri.encodeComponent(card.id)}',
                            ),
                          ),
                          IconButton(
                            key: ValueKey('delete-card-${card.id}'),
                            constraints: const BoxConstraints(
                              minWidth: 44,
                              minHeight: 44,
                            ),
                            tooltip: settings.delete,
                            icon: const Icon(Icons.delete_outline, size: 20),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: Text(settings.deleteCardQuestion),
                                  content: Text(
                                    '${card.bankName} · •••• ${_lastFour(card.cardNumber)}\n\n${settings.deleteCardNotice}',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext, false),
                                      child: Text(Languages.cancel),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext, true),
                                      child: Text(settings.delete),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed != true || !context.mounted) return;
                              try {
                                await ref
                                    .read(walletControllerProvider.notifier)
                                    .deleteCard(card.id);
                              } catch (_) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(settings.deleteFailed),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  static String _lastFour(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    return digits.length > 4 ? digits.substring(digits.length - 4) : digits;
  }
}
