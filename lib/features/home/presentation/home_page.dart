import 'dart:ui' show lerpDouble;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart'
    hide SizeExtension;
import 'package:flutter/services.dart';
import 'package:sirc/routes/source_detail_navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/home/controllers/home_controller.dart';
import 'package:sirc/features/home/controllers/navigation_controller.dart';
import 'package:sirc/core/theme/app_colors.dart';
import 'package:sirc/utils/toast.dart';
import 'package:sirc/widgets/bank_card_widget.dart';
import 'package:sirc/widgets/expandable_page_view.dart';
import 'package:go_router/go_router.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:sirc/features/home/data/article_repository.dart';
import 'package:sirc/features/wallet/presentation/wallet_page.dart'
    hide NeutralSegments;
import 'package:sirc/features/wallet/domain/utils/compact_amount_formatter.dart';
import 'package:sirc/routes/app_routes.dart';
import 'package:sirc/widgets/jingang_widget.dart';
import 'package:sirc/features/home/presentation/home_transaction_chart.dart';
import 'package:sirc/widgets/network_web_image.dart';
import 'package:sirc/widgets/neutral_segments.dart';
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
      padding: EdgeInsets.symmetric(horizontal: 16),
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
        return _HomeBankCardPages(
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

class _HomeBankCardPages extends StatefulWidget {
  const _HomeBankCardPages({
    required this.cardWidth,
    required this.viewportWidth,
    required this.homeState,
    required this.onPageChanged,
  });

  final double cardWidth;
  final double viewportWidth;
  final HomeState homeState;
  final ValueChanged<int> onPageChanged;

  @override
  State<_HomeBankCardPages> createState() => _HomeBankCardPagesState();
}

class _HomeBankCardPagesState extends State<_HomeBankCardPages>
    with SingleTickerProviderStateMixin {
  final _controller = ScrollController(keepScrollOffset: false);
  late final _selectionHighlight = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _selectionHighlight.reset();
    }
  }

  bool _dragging = false;
  bool _selecting = false;
  static const _gap = 18.0;

  // 窄屏让首尾卡面居中露边；宽屏仅在整组卡片放得下时居中整组。
  double get _horizontalPadding {
    final contentWidth =
        widget.homeState.banks.length * widget.cardWidth +
        (widget.homeState.banks.length - 1) * _gap;
    if (contentWidth <= widget.viewportWidth) {
      return (widget.viewportWidth - contentWidth) / 2;
    }
    return widget.viewportWidth < 420
        ? (widget.viewportWidth - widget.cardWidth) / 2
        : 0;
  }

  @override
  void didUpdateWidget(covariant _HomeBankCardPages oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.homeState.currentBankIndex !=
        widget.homeState.currentBankIndex) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _selectionHighlight.reset();
      } else {
        _selectionHighlight.forward(from: 0);
      }
    }
    // 窄屏保持选中卡居中；多卡宽屏仅最小滚动，不挪动已完整可见的卡片。
    if (oldWidget.viewportWidth != widget.viewportWidth ||
        oldWidget.homeState.currentBankIndex !=
            widget.homeState.currentBankIndex ||
        oldWidget.homeState.banks.length != widget.homeState.banks.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_dragging) _reveal(widget.homeState.currentBankIndex);
      });
    }
  }

  void _reveal(int index, {bool animate = false}) {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    final start = _horizontalPadding + index * (widget.cardWidth + _gap);
    final end = start + widget.cardWidth;
    final current = position.pixels;
    final target =
        (widget.viewportWidth < 420
                ? (start + end - position.viewportDimension) / 2
                : start < current
                ? start
                : end > current + position.viewportDimension
                ? end - position.viewportDimension
                : current)
            .clamp(0.0, position.maxScrollExtent);
    if ((target - current).abs() < .5) return;
    if (animate && !MediaQuery.disableAnimationsOf(context)) {
      _controller.animateTo(
        target,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    } else {
      _controller.jumpTo(target);
    }
  }

  void _select(int index) {
    _selecting = true;
    widget.onPageChanged(index);
    _reveal(index, animate: true);
    // 程序滚动不能覆盖用户点击的选中索引。
    _dragging = false;
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _dragging = true;
      _selecting = false;
    }
    if (notification is ScrollEndNotification && _dragging && !_selecting) {
      _dragging = false;
      final index = (_controller.offset / (widget.cardWidth + _gap))
          .round()
          .clamp(0, widget.homeState.banks.length - 1);
      widget.onPageChanged(index);
    }
    return false;
  }

  @override
  void dispose() {
    _selectionHighlight.dispose();
    _controller.dispose();
    super.dispose();
  }

  String _localizedBankName(String bankName) {
    switch (bankName) {
      case 'CNSS':
        return Languages.cnss;
      case 'DXSS':
        return Languages.dxss;
      case 'CID':
        return Languages.cid;
      default:
        return bankName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = widget.homeState;
    if (homeState.banks.isEmpty) {
      return SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(Languages.home.noCardsInWallet),
        ),
      );
    }
    final cardHeight = widget.cardWidth * 200 / 380;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: double.infinity,
          height: cardHeight,
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: ListView.separated(
              key: const ValueKey('home-bank-scroll'),
              controller: _controller,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
              itemCount: homeState.banks.length,
              separatorBuilder: (_, _) => const SizedBox(width: _gap),

              itemBuilder: (context, index) {
                final card = homeState.banks[index];
                return GestureDetector(
                  key: ValueKey('home-bank-card-$index'),
                  onTap: () => _select(index),
                  child: Semantics(
                    selected: homeState.currentBankIndex == index,
                    child: SizedBox(
                      width: widget.cardWidth,
                      height: cardHeight,
                      child: Container(
                        key: const ValueKey('home-bank-backdrop'),
                        child: FittedBox(
                          child: SizedBox(
                            width: 380,
                            height: 200,
                            // 银行卡按固定比例缩放；外围 UI 仍遵循大字设置。
                            child: MediaQuery.withClampedTextScaling(
                              maxScaleFactor: 1,
                              child: AnimatedBuilder(
                                animation: _selectionHighlight,
                                builder: (context, _) => BankCardWidget(
                                  bankName: _localizedBankName(card.bankName),
                                  cardNumber: card.cardNumber,
                                  ownerName: card.ownerName,
                                  expirationDate: card.expirationDate,
                                  cardType: card.cardType,
                                  isSelected:
                                      homeState.currentBankIndex == index,
                                  selectionHighlightProgress:
                                      homeState.currentBankIndex == index &&
                                          _selectionHighlight.isAnimating &&
                                          _selectionHighlight.value < 1 &&
                                          !MediaQuery.disableAnimationsOf(
                                            context,
                                          )
                                      ? _selectionHighlight.value
                                      : null,
                                ),
                              ),
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
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(homeState.banks.length, (index) {
            return GestureDetector(
              key: ValueKey('bank-card-indicator-$index'),
              behavior: HitTestBehavior.opaque,
              onTap: () => _select(index),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: homeState.currentBankIndex == index
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.outlineVariant,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
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
    return Container(
      key: const ValueKey('home-transactions'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  Languages.home.recentTransactions,
                  style: const TextStyle(
                    fontSize: 13,
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
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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

/// 展示本地文章面板
///
/// 作为 [SliverMainAxisGroup] 提供分类栏局域吸顶（Scoped Sticky Header）与文章列表。
class HomeArticlesPanel extends ConsumerStatefulWidget {
  /// 创建文章面板 Sliver
  const HomeArticlesPanel({super.key});

  @override
  ConsumerState<HomeArticlesPanel> createState() => _HomeArticlesPanelState();
}

class _HomeArticlesPanelState extends ConsumerState<HomeArticlesPanel> {
  int selected = 0;

  Widget _buildHeading() {
    return Row(
      children: [
        Expanded(
          child: Text(
            Languages.articles,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          Languages.home.localExamples,
          style: TextStyle(fontSize: 10, color: AppColors.muted(context)),
        ),
      ],
    );
  }

  Widget _buildSegments({
    Key? key,
    required String keyPrefix,
    bool isPinned = false,
  }) {
    return NeutralSegments(
      key: key,
      labels: [Languages.follow, Languages.hot, Languages.explore],
      selected: selected,
      onSelected: (i) => setState(() => selected = i),
      keyPrefix: keyPrefix,
      borderRadius: isPinned ? BorderRadius.zero : BorderRadius.circular(11),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final articlesState = ref.watch(articleGroupsProvider(locale));

    final articleItems = articlesState.when(
      loading: () => [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
      error: (error, stack) => [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(Languages.common.loadFailed),
              TextButton(
                onPressed: () => ref.invalidate(articleGroupsProvider(locale)),
                child: Text(Languages.common.retry),
              ),
            ],
          ),
        ),
      ],
      data: (groups) => selected >= groups.length || groups[selected].isEmpty
          ? [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(Languages.common.notFound),
              ),
            ]
          : [
              for (var i = 0; i < groups[selected].length; i++) ...[
                if (i > 0) Divider(height: 1, color: AppColors.line(context)),
                _RepositoryArticleItem(
                  article: groups[selected][i],
                  group: selected,
                  index: i,
                ),
              ],
            ],
    );

    final surfaceColor = Theme.of(context).colorScheme.surface;
    final borderColor = AppColors.line(context);

    final sectionStart = SliverToBoxAdapter(
      child: Container(
        key: const ValueKey('home-articles'),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          border: Border(
            top: BorderSide(color: borderColor),
            left: BorderSide(color: borderColor),
            right: BorderSide(color: borderColor),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: _buildHeading(),
      ),
    );

    final stickySegments = SliverPersistentHeader(
      pinned: true,
      delegate: _ArticleSegmentsHeaderDelegate(
        builder: (context, isPinned) => _buildSegments(
          keyPrefix: 'article-segment',
          isPinned: isPinned,
        ),
      ),
    );

    final sectionEnd = SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
          border: Border(
            left: BorderSide(color: borderColor),
            right: BorderSide(color: borderColor),
            bottom: BorderSide(color: borderColor),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.only(top: 14, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: articleItems,
        ),
      ),
    );

    return SliverMainAxisGroup(
      slivers: [
        sectionStart,
        stickySegments,
        sectionEnd,
      ],
    );
  }
}

/// 文章分类吸顶栏 Delegate
///
/// 固定 44 像素高度，在吸顶时展示横向满幅扩展动画、平滑阴影与边框贴合。
class _ArticleSegmentsHeaderDelegate extends SliverPersistentHeaderDelegate {
  /// 创建文章分类吸顶栏 Delegate
  ///
  /// [builder] 根据是否吸顶构建子组件。
  const _ArticleSegmentsHeaderDelegate({required this.builder});

  /// 吸顶栏子组件构建函数
  final Widget Function(BuildContext context, bool isPinned) builder;

  @override
  double get minExtent => 44.0;

  @override
  double get maxExtent => 44.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final isPinned = shrinkOffset > 0 || overlapsContent;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final borderColor = AppColors.line(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      height: 44.0,
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(
          left: BorderSide(color: borderColor),
          right: BorderSide(color: borderColor),
        ),
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
      padding: EdgeInsets.symmetric(horizontal: isPinned ? 0 : 16),
      child: builder(context, isPinned),
    );
  }

  @override
  bool shouldRebuild(covariant _ArticleSegmentsHeaderDelegate oldDelegate) =>
      true;
}

class _RepositoryArticleItem extends StatelessWidget {
  const _RepositoryArticleItem({
    required this.article,
    required this.group,
    required this.index,
  });
  final Article article;
  final int group;
  final int index;

  @override
  Widget build(BuildContext context) {
    final title = article.title;
    final summary = article.summary;
    return InkWell(
      key: ValueKey('home-article-$group-$index'),
      onTap: () => openSourceDetail(context, 'article/$group-$index'),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                summary,
                style: TextStyle(fontSize: 12, color: AppColors.muted(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 本地设计示例，未连接文章 API；保留原有文章组件边界。
class HomeTabViewListItemWidget extends StatelessWidget {
  const HomeTabViewListItemWidget({
    super.key,
    required this.tabTitle,
    required this.index,
  });

  final String tabTitle;
  final int index;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
