import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:sirc/routes/source_detail_navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/core/localization/transaction_localization.dart';
import 'package:sirc/core/theme/app_colors.dart';
import 'package:sirc/features/home/controllers/navigation_controller.dart';
import 'package:sirc/features/wallet/domain/models/transaction.dart';
import 'package:sirc/features/wallet/domain/utils/compact_amount_formatter.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:sirc/routes/app_routes.dart';
import 'package:sirc/features/wallet/domain/utils/transaction_category_helper.dart';
import 'package:sirc/widgets/bank_card_widget.dart';
import 'package:sirc/features/wallet/domain/models/bank_card.dart';
import 'package:sirc/widgets/page_gutter.dart';
import 'package:sirc/utils/date_time_formatter.dart';

class WalletPage extends ConsumerWidget {
  const WalletPage({super.key, this.onMenuTap});
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final state = ref.watch(walletControllerProvider);
    final controller = ref.read(walletControllerProvider.notifier);
    final items = state.walletTransactions;
    final weeklyAmounts = state.weeklyAmounts(items);
    // Total means money moved (income + expense), not the available balance.
    final total = weeklyAmounts.fold<double>(0, (sum, value) => sum + value);
    final balance = WalletPanel(
      key: const ValueKey('wallet-balance'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Languages.availableBalance,
            style: TextStyle(color: AppColors.muted(context)),
          ),
          const SizedBox(height: 12),
          Text(
            '\$ ${state.availableBalance.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => controller.setFilterIndex(0),
                child: Text(Languages.send),
              ),
              OutlinedButton(
                onPressed: () => controller.setFilterIndex(1),
                child: Text(Languages.receive),
              ),
              TextButton(
                onPressed: () => openSourceDetail(context, 'add-card'),
                child: Text(Languages.addCard),
              ),
            ],
          ),
        ],
      ),
    );
    final cards = WalletPanel(
      key: const ValueKey('wallet-card-panel'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  Languages.cardCredit,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(
                key: const ValueKey('manage-cards'),
                onPressed: () => openSourceDetail(context, 'cards'),
                child: Text(Languages.manageCards),
              ),
            ],
          ),
          const SizedBox(height: 12),
          WalletCardCarousel(
            cards: state.cards,
            selectedIndex: state.selectedCardIndex,
            onSelected: controller.selectCard,
          ),
        ],
      ),
    );
    final stats = WalletPanel(
      key: const ValueKey('wallet-statistics'),
      minimumHeight: 282,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Languages.incomeExpenseStats,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          NeutralSegments(
            labels: [Languages.send, Languages.receive, Languages.total],
            selected: state.currentFilterIndex,
            keyPrefix: 'wallet-filter',
            onSelected: controller.setFilterIndex,
          ),
          const SizedBox(height: 8),
          Text(
            '${state.currentFilterIndex == 0
                ? '− '
                : state.currentFilterIndex == 1
                ? '+ '
                : ''}\$ ${total.toStringAsFixed(2)}',
            key: const ValueKey('wallet-total'),
            style: TextStyle(
              fontSize: 29,
              fontWeight: FontWeight.w600,
              letterSpacing: -1,
              color: state.currentFilterIndex == 0
                  ? AppColors.expense(context)
                  : state.currentFilterIndex == 1
                  ? AppColors.income(context)
                  : AppColors.ink(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            [
              Languages.wallet.thisWeekSpending,
              Languages.wallet.thisWeekIncome,
              Languages.wallet.thisWeekTotalVolume,
            ][state.currentFilterIndex],
            style: TextStyle(fontSize: 11, color: AppColors.muted(context)),
          ),
          WalletBars(values: weeklyAmounts),
          WalletDataNotice(state: state),
        ],
      ),
    );
    return SingleChildScrollView(
      child: SafeArea(
        child: PageGutter(
          maxWidth: 1017,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: LayoutScope(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          Languages.walletTitle,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      IconButton(
                        tooltip: Languages.menu,
                        onPressed:
                            onMenuTap ??
                            () => ref
                                .read(navigationControllerProvider.notifier)
                                .openDrawer(),
                        icon: const Icon(Icons.menu),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (state.isLoading) const LinearProgressIndicator(),
                  if (state.errorMessage != null)
                    Row(
                      children: [
                        Expanded(child: Text(state.errorMessage!)),
                        TextButton(
                          onPressed: state.isLoading ? null : controller.retry,
                          child: Text(Languages.retry),
                        ),
                      ],
                    ),
                  Builder(
                    builder: (context) {
                      final beside =
                          ResponsiveQuery.of(context).width >= 760 &&
                          MediaQuery.textScalerOf(context).scale(14) < 24;
                      return Flex(
                        direction: beside ? Axis.horizontal : Axis.vertical,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(flex: beside ? 1 : 0, child: balance),
                          SizedBox(
                            width: beside ? 16 : 0,
                            height: beside ? 0 : 16,
                          ),
                          Flexible(flex: beside ? 1 : 0, child: cards),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  stats,
                  const SizedBox(height: 16),
                  WalletPanel(
                    key: const ValueKey('wallet-transactions'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Languages.transactions,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        WalletTransactionList(
                          items: items.take(3).toList(),
                          heroPrefix: 'heroTag_',
                          designStyle: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A wallet stack with stable title targets and a continuous selection motion.
class WalletCardCarousel extends StatefulWidget {
  const WalletCardCarousel({
    super.key,
    required this.cards,
    required this.selectedIndex,
    required this.onSelected,
  });
  final List<BankCard> cards;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  State<WalletCardCarousel> createState() => _WalletCardCarouselState();
}

class _WalletCardCarouselState extends State<WalletCardCarousel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  )..addStatusListener(_onStatus);
  List<String> _order = [];
  List<String>? _destination;
  String? _active;
  String? _target;
  String? _queued;

  String? get _selectedId => widget.cards.isEmpty
      ? null
      : widget.cards[widget.selectedIndex.clamp(0, widget.cards.length - 1)].id;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    _motion.stop();
    _target = null;
    _destination = null;
    _queued = null;
    _active = _selectedId;
    _order = widget.cards.map((card) => card.id).toList();
    if (_active != null) {
      _order.remove(_active);
      _order.add(_active!);
    }
  }

  @override
  void didUpdateWidget(covariant WalletCardCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final ids = widget.cards.map((card) => card.id).toList();
    final oldIds = oldWidget.cards.map((card) => card.id).toList();
    if (ids.length != oldIds.length ||
        List.generate(ids.length, (i) => ids[i] != oldIds[i]).contains(true)) {
      _reset();
    } else if (widget.selectedIndex != oldWidget.selectedIndex &&
        _selectedId != _active) {
      // An external selection wins over an in-flight local gesture.
      _reset();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) && _target != null) {
      // Commit outside dependency resolution; never notify during build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && MediaQuery.disableAnimationsOf(context)) _finish();
      });
    }
  }

  void _select(String id) {
    if (_target != null) {
      _queued = id;
      return;
    }
    if (id == _active) return;
    setState(() {
      _target = id;
      _destination = [..._order.where((value) => value != id), id];
    });
    if (MediaQuery.disableAnimationsOf(context)) {
      _finish();
    } else {
      _motion.forward(from: 0);
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _finish();
  }

  void _finish() {
    final target = _target;
    if (target == null) return;
    _motion.stop();
    final next = _queued;
    setState(() {
      _order = _destination!;
      _active = target;
      _destination = null;
      _target = null;
      _queued = null;
    });
    final index = widget.cards.indexWhere((card) => card.id == target);
    if (index >= 0) widget.onSelected(index);
    if (next != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _order.contains(next)) _select(next);
      });
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(Languages.noCardsYet),
      );
    }
    final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
    final band = math.max(58.0, 24 + 32 * textScale);
    final cardHeight = 200.0 + math.max(0.0, (textScale - 1) * 120);
    final count = widget.cards.length;
    double top(int rank) => 10 + rank * band;
    double scale(int rank) =>
        1 - (count - 1 - rank) * .02 / math.max(1, count - 2);
    return Column(
      children: [
        SizedBox(
          key: const ValueKey('wallet-cards'),
          height: cardHeight + (count - 1) * band + 20,
          child: AnimatedBuilder(
            animation: _motion,
            builder: (context, _) {
              final progress = _target == null
                  ? 0.0
                  : const Cubic(.2, 0, 0, 1).transform(_motion.value);
              final painted = [..._order];
              if (_target != null) {
                painted.remove(_target);
                painted.add(_target!);
              }
              return Stack(
                children: [
                  for (final id in painted)
                    Builder(
                      key: ValueKey('wallet-card-face-$id'),
                      builder: (context) {
                        final oldRank = _order.indexOf(id);
                        final rank = _destination?.indexOf(id) ?? oldRank;
                        final moving = id == _target;
                        final arc = math.sin(math.pi * progress);
                        final card = widget.cards.firstWhere(
                          (card) => card.id == id,
                        );
                        final size =
                            scale(oldRank) +
                            (scale(rank) - scale(oldRank)) * progress +
                            (moving ? .003 * arc : 0);
                        final visible = moving
                            ? band / scale(oldRank) +
                                  (cardHeight - band / scale(oldRank)) *
                                      progress *
                                      progress *
                                      (3 - 2 * progress)
                            : cardHeight;
                        return Positioned(
                          top: 0,
                          left: 10,
                          right: 10,
                          child: IgnorePointer(
                            child: ExcludeSemantics(
                              child: Transform.translate(
                                offset: Offset(
                                  (moving ? 9 : -2) * arc,
                                  top(oldRank) +
                                      (top(rank) - top(oldRank)) * progress -
                                      (moving ? 4 * arc : 0),
                                ),
                                child: Transform.scale(
                                  scale: size,
                                  alignment: Alignment.topCenter,
                                  child: ClipRect(
                                    clipper: _WalletCardReveal(visible),
                                    child: BankCardWidget(
                                      height: cardHeight,
                                      bankName: card.bankName,
                                      cardNumber: card.cardNumber,
                                      maskCardNumber: true,
                                      ownerName: card.ownerName,
                                      expirationDate: card.expirationDate,
                                      cardType: card.cardType,
                                      isSelected: id == (_target ?? _active),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  // Targets stay put during flight, including keyboard focus.
                  for (final id in _order)
                    Positioned(
                      key: ValueKey('wallet-card-hit-$id'),
                      top: top(_order.indexOf(id)),
                      left: 10,
                      right: 10,
                      height: id == _order.last ? cardHeight : band,
                      child: Semantics(
                        selected: id == _active,
                        label:
                            '${widget.cards.firstWhere((card) => card.id == id).bankName}, '
                            '${widget.cards.indexWhere((card) => card.id == id) + 1} / $count',
                        child: TextButton(
                          key: ValueKey('wallet-card-select-$id'),
                          onPressed: () => _select(id),
                          style:
                              TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ).copyWith(
                                overlayColor: const WidgetStatePropertyAll(
                                  Colors.transparent,
                                ),
                                splashFactory: NoSplash.splashFactory,
                              ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        if (count > 1)
          Text(
            '${widget.cards.indexWhere((card) => card.id == _active) + 1} / $count',
            key: const ValueKey('wallet-card-count'),
          ),
      ],
    );
  }
}

class _WalletCardReveal extends CustomClipper<Rect> {
  const _WalletCardReveal(this.height);
  final double height;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width, height.clamp(0, size.height));

  @override
  bool shouldReclip(_WalletCardReveal oldClipper) =>
      height != oldClipper.height;
}

/// 中性分段切换器
///
/// 用于在多个分类或时间范围（如关注/热门/探索、周/月）之间切换。
/// [labels] 为各选项文本列表；[selected] 为当前选中索引；
/// [onSelected] 为切换回调；[keyPrefix] 为语义与测试键前缀；
/// [borderRadius] 为外部圆角，吸顶满幅时可传 [BorderRadius.zero]。
class NeutralSegments extends StatelessWidget {
  /// 创建中性分段切换器
  const NeutralSegments({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
    required this.keyPrefix,
    this.borderRadius,
  });

  /// 选项文本列表
  final List<String> labels;

  /// 当前选中索引
  final int selected;

  /// 选中回调
  final ValueChanged<int> onSelected;

  /// 键前缀
  final String keyPrefix;

  /// 外部圆角，默认为 11 像素
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeInOut,
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: AppColors.field(context),
      borderRadius: borderRadius ?? BorderRadius.circular(11),
    ),
    child: Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : 4),
              child: Semantics(
                selected: selected == i,
                child: TextButton(
                  key: ValueKey('$keyPrefix-$i'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.ink(context),
                    backgroundColor: selected == i
                        ? Theme.of(context).colorScheme.surface
                        : Colors.transparent,
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 9,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: selected == i
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  onPressed: () => onSelected(i),
                  child: Text(labels[i], textAlign: TextAlign.center),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class WalletPanel extends StatelessWidget {
  const WalletPanel({super.key, required this.child, this.minimumHeight = 0});
  final Widget child;
  final double minimumHeight;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    constraints: BoxConstraints(minHeight: minimumHeight),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.line(context)),
    ),
    child: child,
  );
}

class WalletBars extends StatelessWidget {
  /// 按 [values] 展示比例柱；[labels] 为对应横轴文字，空文字保留柱。
  /// 未指定标签时沿用钱包本周本地化星期；较多长标签可横向滚动。
  const WalletBars({super.key, required this.values, this.labels});
  final List<double> values;
  final List<String>? labels;
  @override
  Widget build(BuildContext context) {
    final maximum = values.fold<double>(0, math.max);
    final axisLabels =
        labels ??
        [
          for (var i = 0; i < values.length; i++)
            Languages.wallet.thisWeekdayLabel[i % 7],
        ];
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final hasLongLabels = axisLabels.any((label) => label.length > 2);
          final chartWidth = hasLongLabels
              ? math.max(
                  constraints.maxWidth,
                  values.length *
                      58.0 *
                      MediaQuery.textScalerOf(context).scale(1),
                )
              : constraints.maxWidth;
          final barWidth = math.min(
            28.0,
            chartWidth / math.max(14, values.length * 2),
          );
          final chart = SizedBox(
            width: chartWidth,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < values.length; i++)
                      Expanded(
                        child: Semantics(
                          label:
                              '${axisLabels[i]}: ${values[i].toStringAsFixed(2)}',
                          child: Column(
                            children: [
                              SizedBox(
                                height: 72,
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    key: ValueKey('bar-$i-${values[i]}'),
                                    width: barWidth,
                                    height: maximum == 0
                                        ? 0
                                        : math.max(0, values[i]) / maximum * 72,
                                    decoration: BoxDecoration(
                                      color: AppColors.ink(context),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 9),
                              SizedBox(
                                height: MediaQuery.textScalerOf(context)
                                    .scale(12),
                                child: OverflowBox(
                                  minWidth: 0,
                                  maxWidth: hasLongLabels
                                      ? chartWidth / math.max(1, values.length)
                                      : 48,
                                  child: Text(
                                    axisLabels[i],
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: AppColors.muted(context),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                if (maximum == 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      Languages.noChartRecords,
                      key: const ValueKey('wallet-chart-empty'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.muted(context),
                      ),
                    ),
                  ),
              ],
            ),
          );
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: chart,
          );
        },
      ),
    );
  }
}

class WalletDataNotice extends StatelessWidget {
  const WalletDataNotice({super.key, required this.state});
  final WalletState state;
  @override
  Widget build(BuildContext context) {
    final now = state.referenceDate ?? DateTime.now();
    if (state.undatedCount == 0) return const SizedBox.shrink();
    return Tooltip(
      message: Languages.undatedRecordsTooltip.replaceAll(
        '{date}',
        AppDateTimeFormatter.date(
          now,
          locale: Localizations.localeOf(context),
          languages: AppLocale.current,
        ),
      ),
      child: Text(
        Languages.undatedRecordsExcluded.replaceAll(
          '{count}',
          '${state.undatedCount}',
        ),
        style: TextStyle(fontSize: 11, color: AppColors.muted(context)),
      ),
    );
  }
}

class WalletTransactionRow extends ConsumerWidget {
  const WalletTransactionRow({
    super.key,
    required this.transaction,
    required this.heroTag,
  });
  final Transaction transaction;
  final String heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = transaction.localizedPlaceholders;
    final expense = (data.moneyAmount ?? 0) < 0;
    final locale = ref.watch(localeProvider);
    final units = AppLocale.current.wallet.compactAmountUnits;
    final amount =
        '${expense ? '−' : '+'} \$ ${CompactAmountFormatter.format(data.moneyAmount ?? 0, units: units)}';
    final tag = heroTag;
    final trailing = Text(
      amount,
      maxLines: 1,
      softWrap: false,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: expense ? AppColors.expense(context) : AppColors.income(context),
      ),
    );
    return Semantics(
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => openSourceDetail(
          context,
          AppRoutes.TRANSACTION_SEGMENT,
          extra: {'data': data, 'heroTag': tag},
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked =
                  constraints.maxWidth < 480 &&
                  MediaQuery.textScalerOf(context).scale(14) > 20;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TransactionCategoryHelper.buildAdaptiveCategoryAvatar(
                    context: context,
                    transaction: data,
                    heroTag: tag,
                    size: 36,
                    iconSize: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.moneyActionName ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppDateTimeFormatter.display(
                            data.time,
                            locale: locale,
                            languages: AppLocale.current,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.muted(context)),
                        ),
                        if (stacked) ...[const SizedBox(height: 8), trailing],
                      ],
                    ),
                  ),
                  if (!stacked) ...[
                    const SizedBox(width: 12),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: trailing,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class WalletTransactionList extends StatelessWidget {
  const WalletTransactionList({
    super.key,
    required this.items,
    required this.heroPrefix,
    this.designStyle = false,
  });
  final List<Transaction> items;
  final String heroPrefix;
  final bool designStyle;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(Languages.noMatchingTransactions),
      );
    }
    if (designStyle) {
      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.line(context)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) Divider(height: 1, color: AppColors.line(context)),
              WalletTransactionRow(
                transaction: items[i],
                heroTag: '$heroPrefix${items[i].hashCode}',
              ),
            ],
          ],
        ),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) Divider(height: 1, color: AppColors.line(context)),
          WalletTransactionRow(
            transaction: items[i],
            heroTag: '$heroPrefix${items[i].hashCode}',
          ),
        ],
      ],
    );
  }
}
