import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/core/theme/app_colors.dart';
import 'package:sirc/features/home/controllers/navigation_controller.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:sirc/features/wallet/presentation/wallet_page.dart';
import 'package:sirc/widgets/page_gutter.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key, this.onMenuTap});
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final state = ref.watch(walletControllerProvider);
    final controller = ref.read(walletControllerProvider.notifier);
    final items = state.historyTransactions;
    final theme = Theme.of(context);
    final wallet = Languages.wallet;
    final periods = [
      Languages.common.search,
      Languages.thisWeek,
      Languages.thisMonth,
    ];
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
            wallet.historyTotalAmount,
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
            wallet.amountAbsoluteSummary,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.muted(context),
            ),
          ),
          WalletBars(
            values: buckets,
            labels: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
          ),
          Text(
            wallet.recordsGroupedByWeekday,
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
          Text(wallet.filterByDate, style: theme.textTheme.titleSmall),
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
            '${periods[state.historyPeriod]} · ${items.length} ${wallet.transactionsLabel}',
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
        child: PageGutter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
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
                      tooltip: Languages.settings.openNavigationMenu,
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
                  wallet.history,
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
                  wallet.searchTransactions,
                  style: theme.textTheme.labelMedium,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  key: const ValueKey('history-search'),
                  initialValue: state.searchQuery,
                  onChanged: controller.setSearchQuery,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: wallet.searchIncomeExpense,
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
                          child: Text(wallet.noMatchingTransactions),
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
      ),
    );
  }
}
