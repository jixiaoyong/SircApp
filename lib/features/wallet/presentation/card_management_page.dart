import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/routes/source_detail_navigation.dart';
import 'package:sirc/widgets/settings_item_tile.dart';

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
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    return Scaffold(
      appBar: AppBar(
        title: Text(zh ? '卡片管理' : 'Manage cards'),
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
          Text(
            zh ? '仅管理本应用中的卡片，不会解绑真实银行账户。列表仅显示卡号尾号，不显示安全码。' : 'Manage cards in this app only, not your bank connections. Only the last four digits are shown; security codes are never displayed.',
          ),
          const SizedBox(height: 16),
          if (state.isLoading) const LinearProgressIndicator(),
          if (!state.isLoading && state.cards.isEmpty)
            WalletPanel(
              child: Column(
                children: [
                  Text(zh ? '暂无卡片' : 'No cards yet'),
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
                        if (card.cardType?.isNotEmpty == true) card.cardType!,
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
                            tooltip: zh ? '编辑' : 'Edit',
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
                            tooltip: zh ? '删除' : 'Delete',
                            icon: const Icon(Icons.delete_outline, size: 20),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: Text(zh ? '删除卡片？' : 'Delete card?'),
                                  content: Text(
                                    '${card.bankName} · •••• ${_lastFour(card.cardNumber)}\n\n${zh ? '仅从本应用移除此卡片，不会删除交易历史，也不会解绑真实银行账户。' : 'This removes the card from this app only. Transaction history stays unchanged, and your bank account is not disconnected.'}',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext, false),
                                      child: Text(zh ? '取消' : 'Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext, true),
                                      child: Text(zh ? '删除' : 'Delete'),
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
                                      content: Text(
                                        zh ? '删除失败，请重试' : 'Could not delete card. Try again.',
                                      ),
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
