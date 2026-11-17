import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sirc/features/wallet/domain/services/transaction_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/core/layout/app_layout.dart';
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
    final periods = [Languages.all, Languages.thisWeek, Languages.thisMonth];
    final total = items.fold<double>(
      0,
      (sum, item) => sum + (item.moneyAmount ?? 0).abs(),
    );
    final chart = TransactionStatistics.historyBuckets(
      items,
      period: state.historyPeriod,
      referenceDate: state.referenceDate ?? DateTime.now(),
    );
    final labels = [
      for (final date in chart.dates)
        if (state.historyPeriod == 1)
          wallet.thisWeekdayLabel[date.weekday - 1]
        else if (state.historyPeriod == 2)
          {1, 5, 10, 15, 20, 25, chart.dates.length}.contains(date.day)
              ? '${date.day}'
              : ''
        else
          DateFormat(
            'yyyy-MM',
            Localizations.localeOf(context).toLanguageTag(),
          ).format(date),
    ];
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
          WalletBars(values: chart.values, labels: labels),
        ],
      ),
    );

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gutter = PageGutter.gutterFor(constraints.maxWidth);
          final isWide = AppLayout.isWideWindow(context);

          return CustomScrollView(
            cacheExtent: 1000,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              // 1. 顶部历史标题与菜单抽屉按钮
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 8),
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
                    ],
                  ),
                ),
              ),

              // 2. 搜索栏上浮悬停：上滑时自动收起隐藏，下拉时带平滑动画即刻显现
              SliverAppBar(
                floating: true,
                snap: true,
                elevation: 0,
                scrolledUnderElevation: 0,
                backgroundColor: theme.scaffoldBackgroundColor,
                automaticallyImplyLeading: false,
                toolbarHeight:
                    56 +
                    (MediaQuery.textScalerOf(context).scale(1.0) - 1.0).clamp(
                          0.0,
                          2.0,
                        ) *
                        24,
                titleSpacing: 0,
                title: Padding(
                  padding: EdgeInsets.symmetric(horizontal: gutter),
                  child: TextFormField(
                    key: const ValueKey('history-search'),
                    initialValue: state.searchQuery,
                    onChanged: controller.setSearchQuery,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: wallet.searchTransactions,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),

              // 3. 按日期查询标题
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 8),
                  child: Text(
                    wallet.filterByDate,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ),

              // 4. 日期筛选栏吸顶（pinned: true），未吸顶时保持正常边距与圆角，吸顶时窄屏占满屏幕宽度
              SliverPersistentHeader(
                pinned: true,
                delegate: _HistoryStickyFilterDelegate(
                  theme: theme,
                  periods: periods,
                  selectedPeriod: state.historyPeriod,
                  onSelectPeriod: controller.setHistoryPeriod,
                  textScale: MediaQuery.textScalerOf(context).scale(1.0),
                  gutter: gutter,
                  isWide: isWide,
                ),
              ),

              // 5. 总交易额卡片与所选范围流水图表
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(gutter, 12, gutter, 16),
                  child: summary,
                ),
              ),

              // 6. 过滤状态统计与交易流水列表
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(gutter, 12, gutter, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${periods[state.historyPeriod]} · ${items.length} ${wallet.transactionsLabel}',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      WalletDataNotice(state: state),
                      const SizedBox(height: 16),
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
                                itemBuilder: (context, index) =>
                                    WalletTransactionRow(
                                      transaction: items[index],
                                      heroTag:
                                          'hero_history_${items[index].id ?? items[index].hashCode}',
                                    ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 历史页面吸顶筛选栏代理组件。
///
/// 未吸顶时保持与页面卡片一致的边距与圆角；吸顶时窄屏横向铺满屏幕宽度，宽屏自适应保持窗格留白。
class _HistoryStickyFilterDelegate extends SliverPersistentHeaderDelegate {
  _HistoryStickyFilterDelegate({
    required this.theme,
    required this.periods,
    required this.selectedPeriod,
    required this.onSelectPeriod,
    this.textScale = 1.0,
    this.gutter = 16.0,
    this.isWide = false,
  });

  final ThemeData theme;
  final List<String> periods;
  final int selectedPeriod;
  final ValueChanged<int> onSelectPeriod;
  final double textScale;
  final double gutter;
  final bool isWide;

  @override
  double get maxExtent => 52.0 * textScale.clamp(1.0, 2.0);

  @override
  double get minExtent => 52.0 * textScale.clamp(1.0, 2.0);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final isPinned = shrinkOffset > 0 || overlapsContent;
    final horizontalPadding = (isPinned && !isWide) ? 0.0 : gutter;
    final radius = (isPinned && !isWide)
        ? BorderRadius.zero
        : BorderRadius.circular(11);
    final buttonRadius = BorderRadius.circular(8);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isPinned ? theme.colorScheme.surface : Colors.transparent,
        border: isPinned
            ? Border(
                bottom: BorderSide(color: AppColors.line(context), width: 1),
              )
            : null,
        boxShadow: isPinned
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: DecoratedBox(
          key: const ValueKey('history-segments'),
          decoration: BoxDecoration(
            color: AppColors.field(context),
            borderRadius: radius,
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                for (var i = 0; i < periods.length; i++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: i == 0 ? 0 : 4),
                      child: TextButton(
                        key: ValueKey('history-period-$i'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.ink(context),
                          backgroundColor: selectedPeriod == i
                              ? theme.colorScheme.surface
                              : Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 10,
                          ),
                          minimumSize: const Size(0, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: buttonRadius,
                          ),
                          textStyle: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: selectedPeriod == i
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        onPressed: () => onSelectPeriod(i),
                        child: Semantics(
                          selected: selectedPeriod == i,
                          child: Text(periods[i], textAlign: TextAlign.center),
                        ),
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

  @override
  bool shouldRebuild(covariant _HistoryStickyFilterDelegate oldDelegate) =>
      oldDelegate.selectedPeriod != selectedPeriod ||
      oldDelegate.periods != periods ||
      oldDelegate.theme != theme ||
      oldDelegate.gutter != gutter ||
      oldDelegate.isWide != isWide;
}
