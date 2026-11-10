import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sirc/routes/source_detail_navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/home/controllers/home_controller.dart';
import 'package:sirc/features/home/controllers/navigation_controller.dart';
import 'package:sirc/core/theme/app_colors.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/utils/toast.dart';
import 'package:sirc/widgets/bank_card_widget.dart';
import 'package:sirc/widgets/expandable_page_view.dart';
import 'package:go_router/go_router.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:sirc/features/home/presentation/sample_articles.dart';
import 'package:sirc/features/wallet/presentation/wallet_page.dart';
import 'package:sirc/routes/app_routes.dart';
import 'package:sirc/widgets/jingang_widget.dart';
import 'package:sirc/widgets/line_graph.dart';
import 'package:sirc/widgets/network_web_image.dart';
import 'package:sirc/widgets/title_text.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 30, 0),
                child: GestureDetector(
                  key: const ValueKey('home-avatar'),
                  onTap: () => ref
                      .read(navigationControllerProvider.notifier)
                      .openDrawer(),
                  child: ClipOval(
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
          Expanded(
            child: SingleChildScrollView(
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

/// 首页顶部可滚动内容区
class HomeTopBodyWidget extends ConsumerWidget {
  const HomeTopBodyWidget({
    super.key,
    required this.homeState,
    required this.userAvatar,
  });

  final HomeState homeState;
  final String userAvatar;

  String _quickActionLabel(String title) => switch (title) {
    'Bonds' => Languages.home.bonds,
    'Billing' => Languages.home.billing,
    'Cash' => Languages.home.cash,
    'Money Bag' => Languages.home.moneyBag,
    'Wallet' => Languages.wallet.wallet,
    'Bounced Check' => Languages.home.bouncedCheck,
    'Tax' => Languages.home.tax,
    'Purchase Order' => Languages.home.purchaseOrder,
    'Payment History' => Languages.home.paymentHistory,
    'Card In Use' => Languages.home.cardInUse,
    'Card Security' => Languages.home.cardSecurity,
    'Bank Card Front Side' => Languages.home.bankCardFrontSide,
    'bank card missing' => Languages.home.bankCardMissing,
    'Credit Control' => Languages.home.creditControl,
    'Commodity' => Languages.home.commodity,
    _ => title,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final headerAndCards = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const HomeBankCardCarousel(),
        Padding(
          padding: EdgeInsets.only(top: 10.dp),
          child: JingangWidget(
            // 行高由图标和两行文字决定，不随每列宽度增长。
            mainAxisExtent: 80,
            childAspectRatio: 0.7,
            data: homeState.quickActions,
            indicatorOffset: Offset(0, -2.dp),
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
                          dimension: 40.dp,
                          child: NetworkWebImage(
                            data.imageUrl,
                            fit: BoxFit.contain,
                            isAvatar: false,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 2.dp),
                          child: Text(
                            _quickActionLabel(data.title),
                            overflow: TextOverflow.clip,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              height: 1,
                              fontSize: 11.sp,
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
      padding: EdgeInsets.symmetric(horizontal: 16.dp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleText(text: Languages.february),
          Builder(
            builder: (context) {
              final weekLabels = [
                Languages.mon,
                Languages.tues,
                Languages.wed,
                Languages.thur,
                Languages.fri,
                Languages.satu,
                Languages.sun,
              ];
              return SizedBox(
                height: 200.dp,
                width: double.infinity,
                child: LineGraph(
                  data: List.generate(
                    homeState.weeklyPercentages.length,
                    (index) => (
                      weekLabels[index % weekLabels.length],
                      homeState.weeklyPercentages[index],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final beside =
                  constraints.maxWidth >= 760 &&
                  MediaQuery.textScalerOf(context).scale(14) < 24;
              return Column(
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
                  const HomeArticlesPanel(),
                ],
              );
            },
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

class _HomeBankCardPagesState extends State<_HomeBankCardPages> {
  final _controller = ScrollController(keepScrollOffset: false);
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
    if (animate) {
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
          // 卡面上下各留 8px，下侧空间容纳选中短线。
          height: cardHeight + 16,
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
                  child: SizedBox(
                    width: widget.cardWidth,
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        SizedBox(
                          width: widget.cardWidth,
                          height: cardHeight,
                          child: Container(
                            key: const ValueKey('home-bank-backdrop'),
                            child: FittedBox(
                              child: SizedBox(
                                width: 380,
                                height: 200,
                                // 银行卡是按固定比例缩放的实体卡面；外围 UI 仍遵循大字设置。
                                child: MediaQuery.withClampedTextScaling(
                                  maxScaleFactor: 1,
                                  child: BankCardWidget(
                                    bankName: _localizedBankName(card.bankName),
                                    cardNumber: card.cardNumber,
                                    ownerName: card.ownerName,
                                    expirationDate: card.expirationDate,
                                    cardType: card.cardType,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          height: 3,
                          width: 32,
                          color: homeState.currentBankIndex == index
                              ? Theme.of(context).colorScheme.onSurface
                              : Colors.transparent,
                        ),
                      ],
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
              Text(
                '${i == 0 ? '−' : '+'} \$${amounts[i].toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                  color: i == 0
                      ? AppColors.expense(context)
                      : AppColors.income(context),
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

class HomeArticlesPanel extends StatefulWidget {
  const HomeArticlesPanel({super.key});
  @override
  State<HomeArticlesPanel> createState() => _HomeArticlesPanelState();
}

class _HomeArticlesPanelState extends State<HomeArticlesPanel> {
  int selected = 0;
  @override
  Widget build(BuildContext context) {
    // 跟随 MaterialApp 的语言变化重建，文案仍统一由 Languages 读取。
    Localizations.localeOf(context);
    return WalletPanel(
      key: const ValueKey('home-articles'),
      minimumHeight: 224,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  Languages.articles,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                Languages.home.localExamples,
                style: TextStyle(fontSize: 10, color: AppColors.muted(context)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          NeutralSegments(
            labels: [Languages.follow, Languages.hot, Languages.explore],
            selected: selected,
            onSelected: (i) => setState(() => selected = i),
            keyPrefix: 'article-segment',
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < sampleArticleGroups[selected].length; i++) ...[
            if (i > 0) Divider(height: 1, color: AppColors.line(context)),
            HomeTabViewListItemWidget(tabTitle: '$selected', index: i),
          ],
        ],
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
  Widget build(BuildContext context) {
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    final group = int.tryParse(tabTitle) ?? 0;
    final article = sampleArticleForId('$group-$index');
    if (article == null) return const SizedBox.shrink();
    return InkWell(
      key: ValueKey('home-article-$group-$index'),
      onTap: () => openSourceDetail(context, 'article/$group-$index'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.title(zh),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              article.summary(zh),
              style: TextStyle(fontSize: 12, color: AppColors.muted(context)),
            ),
          ],
        ),
      ),
    );
  }
}
