import 'dart:ui' show lerpDouble;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart'
    hide SizeExtension;
import 'package:flutter/services.dart';
import 'package:sirc/features/home/presentation/widgets/home_articles_panel.dart';
import 'package:sirc/features/home/presentation/widgets/home_bank_card_pages.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/home/controllers/home_controller.dart';
import 'package:sirc/features/home/controllers/navigation_controller.dart';
import 'package:sirc/core/theme/app_colors.dart';
import 'package:sirc/utils/toast.dart';
import 'package:sirc/widgets/expandable_page_view.dart';
import 'package:go_router/go_router.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:sirc/features/wallet/presentation/wallet_page.dart';
import 'package:sirc/features/wallet/domain/utils/compact_amount_formatter.dart';
import 'package:sirc/routes/app_routes.dart';
import 'package:sirc/widgets/jingang_widget.dart';
import 'package:sirc/features/home/presentation/home_transaction_chart.dart';
import 'package:sirc/widgets/network_web_image.dart';
import 'package:sirc/widgets/page_gutter.dart';

/// 应用主页
///
/// 展示用户信息、快捷操作、收支图表、交易概览及文章列表。
class HomePage extends ConsumerStatefulWidget {
  /// 创建应用主页
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0.0);

  @override
  void dispose() {
    _scrollOffset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final homeState = ref.watch(homeControllerProvider);
    final userAvatar = ref.watch(
      navigationControllerProvider.select((s) => s.userAvatar),
    );
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
      ),
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: ValueListenableBuilder<double>(
              valueListenable: _scrollOffset,
              builder: (context, offset, child) {
                // 向上滚动时平滑缩小头像并收起下边距，为下方内容释放纵向空间
                final progress = (offset / 50.0).clamp(0.0, 1.0);
                final curveProgress = Curves.easeInOut.transform(progress);
                final avatarSize = lerpDouble(50.0, 34.0, curveProgress)!;
                final topPadding = lerpDouble(12.0, 6.0, curveProgress)!;
                final bottomPadding = lerpDouble(35.0, 10.0, curveProgress)!;
                final rightPadding = lerpDouble(30.0, 24.0, curveProgress)!;

                return Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      topPadding,
                      rightPadding,
                      bottomPadding,
                    ),
                    child: GestureDetector(
                      key: const ValueKey('home-avatar'),
                      onTap: () => ref
                          .read(navigationControllerProvider.notifier)
                          .openDrawer(),
                      child: ClipOval(
                        child: SizedBox(
                          width: avatarSize,
                          height: avatarSize,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: NetworkWebImage(
                              userAvatar,
                              size: const Size(50, 50),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.depth == 0) {
                  _scrollOffset.value = notification.metrics.pixels;
                }
                return false;
              },
              child: HomeTopBodyWidget(
                homeState: homeState,
                userAvatar: userAvatar,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 首页可滚动内容区
class HomeTopBodyWidget extends ConsumerWidget {
  /// 创建首页内容区
  ///
  /// [homeState] 为首页全局状态。
  /// [userAvatar] 为用户头像资源路径或链接。
  const HomeTopBodyWidget({
    super.key,
    required this.homeState,
    required this.userAvatar,
  });

  /// 首页全局状态
  final HomeState homeState;

  /// 用户头像
  final String userAvatar;

  String _quickActionLabel(String title) => title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final headerAndCards = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const HomeBankCardCarousel(),
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: JingangWidget(
            // 行高由图标和两行文字决定，不随每列宽度增长。
            mainAxisExtent: 80,
            childAspectRatio: 0.7,
            data: homeState.quickActions,
            // 分页滑条高 10px、上下 margin 各 10px，完整预留空间，
            // 不挤占最后一排文字，也不改变图标、文字及网格行高。
            indicatorOffset: Offset(0, -30),
            itemBuilder:
                (BuildContext context, int index, int pageIndex, data) {
                  return GestureDetector(
                    onTap: () {
                      Toast.showDefaultToast();
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox.square(
                          dimension: 40,
                          child: NetworkWebImage(
                            data.imageUrl,
                            fit: BoxFit.contain,
                            isAvatar: false,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(
                            _quickActionLabel(data.title),
                            overflow: TextOverflow.clip,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              height: 1,
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
            indicatorBuilder: (context, onPageSelected, scrollPercentage) {
              return ScrollableIndicator(
                onPageSelected: onPageSelected,
                scrollPercentage: scrollPercentage,
                indicatorColor: Theme.of(context).colorScheme.onSurface,
                indicatorBackgroundColor: Theme.of(context)
                    .colorScheme
                    .outlineVariant,
              );
            },
          ),
        ),
      ],
    );
    final graph = Container(
      key: const ValueKey('home-weekly-graph'),
      child: const HomeTransactionChart(),
    );
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: PageGutter(
          child: LayoutScope(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final beside =
                    ResponsiveQuery.of(context).width >= 760 &&
                    MediaQuery.textScalerOf(context).scale(14) < 24;
                final content = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    headerAndCards,
                    const SizedBox(height: 18),
                    if (beside)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: graph),
                          const SizedBox(width: 22),
                          const Expanded(child: HomeSummaryCards()),
                        ],
                      )
                    else ...[
                      graph,
                      const SizedBox(height: 18),
                      const HomeSummaryCards(),
                    ],
                    const SizedBox(height: 18),
                    const HomeTransactionsPanel(),
                    const SizedBox(height: 18),
                  ],
                );
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: content),
                    const HomeArticlesPanel(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// 按局部可用宽度显示一张露边或多张银行卡，卡片高度不随宽度增长。
class HomeBankCardCarousel extends ConsumerWidget {
  const HomeBankCardCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final homeState = ref.watch(homeControllerProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (!width.isFinite || width <= 0) return const SizedBox.shrink();
        final cardWidth = (width < 420 ? width * .9 : 360.0).clamp(0.0, 380.0);
        return HomeBankCardPages(
          viewportWidth: width,
          cardWidth: cardWidth,
          homeState: homeState,
          onPageChanged: (index) =>
              ref.read(homeControllerProvider.notifier).setBankIndex(index),
        );
      },
    );
  }
}

/// 复用钱包记录与详情入口，不把设计稿中的示例金额写入首页。
class HomeTransactionsPanel extends ConsumerWidget {
  const HomeTransactionsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final state = ref.watch(walletControllerProvider);
    final colors = Theme.of(context).colorScheme;
    final items = state.allTransactions.take(3).toList();
    return Column(
      key: const ValueKey('home-transactions'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                Languages.home.recentTransactions,
                key: const ValueKey('home-transactions-heading'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              key: const ValueKey('home-all-transactions'),
              tooltip: Languages.history,
              onPressed: () => context.go(AppRoutes.HISTORY),
              icon: const Icon(Icons.arrow_forward, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          key: const ValueKey('home-transactions-content'),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.isLoading) const LinearProgressIndicator(),
              if (state.errorMessage != null) Text(state.errorMessage!),
              if (!state.isLoading && items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(Languages.wallet.noTransactions),
                ),
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) Divider(height: 1, color: colors.outlineVariant),
                WalletTransactionRow(
                  key: ValueKey('home-transaction-$i'),
                  transaction: items[i],
                  heroTag: 'home-transaction-$i',
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class HomeSummaryCards extends ConsumerWidget {
  const HomeSummaryCards({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final transactions = ref.watch(walletControllerProvider).allTransactions;
    final compactUnits = AppLocale.current.wallet.compactAmountUnits;
    final amounts = [
      transactions
          .where((e) => (e.moneyAmount ?? 0) < 0)
          .fold<double>(0, (sum, e) => sum + (e.moneyAmount ?? 0).abs()),
      transactions
          .where((e) => (e.moneyAmount ?? 0) > 0)
          .fold<double>(0, (sum, e) => sum + (e.moneyAmount ?? 0)),
    ];
    Widget card(int i) => Material(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.line(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('home-summary-$i'),
        onTap: () {
          ref.read(walletControllerProvider.notifier).setFilterIndex(i);
          context.go(AppRoutes.WALLET);
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                i == 0
                    ? Icons.north_east
                    : Icons.account_balance_wallet_outlined,
                size: 20,
              ),
              const SizedBox(height: 14),
              Text(
                i == 0 ? Languages.wallet.outgoing : Languages.wallet.incoming,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '${i == 0 ? '−' : '+'} \$${CompactAmountFormatter.format(amounts[i], units: compactUnits)}',
                  key: ValueKey('home-summary-amount-$i'),
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w600,
                    color: i == 0
                        ? AppColors.expense(context)
                        : AppColors.income(context),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Icon(Icons.arrow_forward, size: 20),
            ],
          ),
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Languages.home.transactionSummary,
          key: const ValueKey('home-summary-heading'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) =>
              constraints.maxWidth < 340 ||
                  MediaQuery.textScalerOf(context).scale(14) > 22
              ? Column(
                  children: [
                    SizedBox(width: double.infinity, child: card(0)),
                    const SizedBox(height: 12),
                    SizedBox(width: double.infinity, child: card(1)),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: card(0)),
                    const SizedBox(width: 12),
                    Expanded(child: card(1)),
                  ],
                ),
        ),
      ],
    );
  }
}
