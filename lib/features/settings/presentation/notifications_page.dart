import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale.dart';
import '../../../widgets/constrained_content.dart';
import '../../../widgets/one_title_with_back_button_appbar.dart';
import '../controllers/settings_controller.dart';

/// Transaction-backed notification centre. No notification permission or backend
/// is implied by the local category and period filters.
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final zh = locale.languageCode == 'zh';
    final state = ref.watch(notificationsControllerProvider);
    final notifier = ref.read(notificationsControllerProvider.notifier);
    final colors = Theme.of(context).colorScheme;
    final groups = state.notificationGroups;

    Widget segments(
      List<String> labels,
      int selected,
      ValueChanged<int> onSelected,
      String key,
    ) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: labels.asMap().entries.map((entry) {
            final active = selected == entry.key;
            return TextButton(
              key: ValueKey('$key-${entry.key}'),
              onPressed: () => onSelected(entry.key),
              style: TextButton.styleFrom(
                foregroundColor: active
                    ? colors.onSurface
                    : colors.onSurfaceVariant,
                backgroundColor: active ? colors.surface : Colors.transparent,
                minimumSize: const Size(48, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Semantics(selected: active, child: Text(entry.value)),
            );
          }).toList(),
        ),
      );
    }

    return Scaffold(
      appBar: OneTitleWithBackButtonAppBar(
        title: Languages.notifications,
        onBack: onBack,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedContent(
          maxWidth: 720,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                zh ? '按类别和时间查阅已有交易。当前无独立通知服务；类别由交易名称识别，未识别的归入其他。' : 'Browse existing transactions by category and time. There is no separate notification service; categories use action labels, with unknown actions in Other.',
                style: TextStyle(color: colors.onSurfaceVariant, height: 1.6),
              ),
              const SizedBox(height: 20),
              segments(
                state.categories,
                state.currentCategoryIndex,
                notifier.setCategory,
                'period',
              ),
              const SizedBox(height: 20),
              Text(
                Languages.category,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              segments(
                groups.map((group) => group.$2).toList(),
                state.currentExpandIndex,
                notifier.selectNotificationCategory,
                'category',
              ),
              const SizedBox(height: 24),
              if (state.undatedCount > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    zh
                        ? '${state.undatedCount} 条记录缺少可解析日期（如“刚刚”），未纳入时间筛选。'
                        : '${state.undatedCount} records have no parseable date (for example “Just now”) and are excluded from time filters.',
                    key: const ValueKey('undated-notice'),
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                ),
              if (state.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (state.error != null)
                Text(
                  zh
                      ? '交易加载失败，请稍后重试。'
                      : 'Unable to load transactions. Please try again later.',
                  style: TextStyle(color: colors.error),
                )
              else if (state.visibleItems.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 40,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border.all(color: colors.outlineVariant),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    zh
                        ? '当前筛选下暂无交易通知'
                        : 'No transaction notifications for these filters',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border.all(color: colors.outlineVariant),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: state.visibleItems.asMap().entries.map((entry) {
                      final item = entry.value;
                      final amount = item.moneyAmount;
                      return Column(
                        children: [
                          if (entry.key > 0)
                            Divider(height: 1, color: colors.outlineVariant),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              alignment: WrapAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.moneyActionName ?? ''),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.time ?? '',
                                      style: TextStyle(
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  amount == null
                                      ? '—'
                                      : '${amount >= 0 ? '+' : '−'} \$${amount.abs().toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: amount != null && amount < 0
                                        ? colors.error
                                        : colors.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
