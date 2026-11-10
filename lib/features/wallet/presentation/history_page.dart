import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/core/theme/app_colors.dart';
import 'package:sirc/features/home/controllers/navigation_controller.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:sirc/features/wallet/presentation/wallet_page.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key, this.onMenuTap});
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final state = ref.watch(walletControllerProvider);
    final controller = ref.read(walletControllerProvider.notifier);
    final items = state.historyTransactions;
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    final theme = Theme.of(context);
    final periods = zh
        ? ['全部', '本周', '本月']
        : ['All', 'This week', 'This month'];
    final total = items.fold<double>(
      0,
      (sum, item) => sum + (item.moneyAmount ?? 0).abs(),
    );
    // All/month views group the visible dated records by weekday, not a fake week.
    final buckets = List<double>.filled(7, 0);
    for (final item in items) {
      final date = WalletState.transactionDate(item, now: state.referenceDate);
      if (date != null) {
        buckets[date.weekday - 1] += (item.moneyAmount ?? 0).abs();
      }
    }
    final summary = WalletPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            zh ? '总交易额' : 'Total transaction amount',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.muted(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$ ${total.toStringAsFixed(2)}',
            key: const ValueKey('history-total'),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -1,
              color: AppColors.ink(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            zh ? '按交易绝对金额汇总' : 'Sum of absolute transaction amounts',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.muted(context),
            ),
          ),
          WalletBars(
            values: buckets,
            labels: zh
                ? const ['一', '二', '三', '四', '五', '六', '日']
                : const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
          ),
          Text(
            zh ? '所选记录 · 按星期汇总' : 'Selected records · grouped by weekday',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.muted(context),
            ),
          ),
        ],
      ),
    );
    final filters = WalletPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            zh ? '按日期查阅' : 'Filter by date',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 16),
          DecoratedBox(
            key: const ValueKey('history-segments'),
            decoration: BoxDecoration(
              color: AppColors.field(context),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < periods.length; i++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: i == 0 ? 0 : 4),
                        child: TextButton(
                          key: ValueKey('history-period-$i'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.ink(context),
                            backgroundColor: state.historyPeriod == i
                                ? theme.colorScheme.surface
                                : Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 12,
                            ),
                            minimumSize: const Size(0, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: state.historyPeriod == i
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          onPressed: () => controller.setHistoryPeriod(i),
                          child: Semantics(
                            selected: state.historyPeriod == i,
                            child: Text(
                              periods[i],
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '${periods[state.historyPeriod]} · ${items.length} ${zh ? '笔交易' : 'transactions'}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          WalletDataNotice(state: state),
        ],
      ),
    );
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      Languages.history,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -.5,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: zh ? '打开菜单' : 'Open menu',
                    onPressed:
                        onMenuTap ??
                        () => ref
                            .read(navigationControllerProvider.notifier)
                            .openDrawer(),
                    icon: const Icon(Icons.menu),
                  ),
                ],
              ),
              Text(
                zh
                    ? '查阅收支，了解每一笔交易'
                    : 'Review your income, spending and transactions',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.muted(context),
                ),
              ),
              const SizedBox(height: 22),
              summary,
              const SizedBox(height: 22),
              filters,
              const SizedBox(height: 22),
              Text(
                zh ? '搜索交易' : 'Search transactions',
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const ValueKey('history-search'),
                initialValue: state.searchQuery,
                onChanged: controller.setSearchQuery,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: zh ? '输入收支名称' : 'Search income or spending',
                  prefixIcon: const Icon(Icons.search, size: 20),
                ),
              ),
              const SizedBox(height: 17),
              if (state.isLoading) const LinearProgressIndicator(),
              if (state.errorMessage != null) Text(state.errorMessage!),
              Material(
                key: const ValueKey('history-transaction-container'),
                color: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: AppColors.line(context)),
                ),
                clipBehavior: Clip.antiAlias,
                child: items.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          zh
                              ? '当前条件下没有交易记录'
                              : 'No transactions match these filters',
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColors.line(context),
                        ),
                        itemBuilder: (context, index) => WalletTransactionRow(
                          transaction: items[index],
                          heroTag: 'hero_history_${items[index].hashCode}',
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
