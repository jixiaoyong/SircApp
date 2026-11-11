import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sirc/routes/source_detail_navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/core/localization/transaction_localization.dart';
import 'package:sirc/core/theme/app_colors.dart';
import 'package:sirc/features/home/controllers/navigation_controller.dart';
import 'package:sirc/features/wallet/domain/models/transaction.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:sirc/routes/app_routes.dart';
import 'package:sirc/widgets/bank_card_widget.dart';
import 'package:sirc/features/wallet/domain/models/bank_card.dart';
import 'package:sirc/widgets/network_web_image.dart';

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
    final zh = Localizations.localeOf(context).languageCode == 'zh';
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
                child: Text(zh ? '管理' : 'Manage'),
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
            zh ? '收支统计' : 'Transactions',
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
            zh
                ? ['本周支出', '本周收入', '本周交易总额'][state.currentFilterIndex]
                : [
                    'This week · spending',
                    'This week · income',
                    'This week · total volume',
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
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1017),
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        zh ? '钱包' : 'Wallet',
                        style: Theme.of(context).textTheme.headlineSmall,
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
                const SizedBox(height: 20),
                if (state.isLoading) const LinearProgressIndicator(),
                if (state.errorMessage != null) Text(state.errorMessage!),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final beside =
                        constraints.maxWidth >= 760 &&
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
                        zh ? '交易记录' : 'Transactions',
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
    );
  }
}

/// A single, fully visible card with touch paging and explicit desktop controls.
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

class _WalletCardCarouselState extends State<WalletCardCarousel> {
  late final PageController _pages = PageController(
    initialPage: widget.cards.isEmpty
        ? 0
        : widget.selectedIndex.clamp(0, widget.cards.length - 1),
  );

  @override
  void didUpdateWidget(covariant WalletCardCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cards.isNotEmpty) {
      final target = widget.selectedIndex.clamp(0, widget.cards.length - 1);
      if (oldWidget.selectedIndex != target ||
          oldWidget.cards.length != widget.cards.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _pages.hasClients) _pages.jumpToPage(target);
        });
      }
    }
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _select(int index) {
    _pages.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
    widget.onSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    if (widget.cards.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          zh
              ? '暂无银行卡，点击“添加银行卡”开始。'
              : 'No cards yet. Choose Add card to get started.',
        ),
      );
    }
    final index = widget.selectedIndex.clamp(0, widget.cards.length - 1);
    return Column(
      children: [
        SizedBox(
          height:
              220 +
              math.max(0, MediaQuery.textScalerOf(context).scale(40) - 40),
          child: LayoutBuilder(
            builder: (context, constraints) => Stack(
              children: [
                PageView.builder(
                  key: const ValueKey('wallet-cards'),
                  controller: _pages,
                  itemCount: widget.cards.length,
                  onPageChanged: widget.onSelected,
                  itemBuilder: (context, i) {
                    final card = widget.cards[i];
                    return Semantics(
                      label:
                          '${card.bankName}, ${i + 1} / ${widget.cards.length}',
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: SizedBox(
                            width: math.max(
                              380 *
                                  MediaQuery.textScalerOf(context).scale(16) /
                                  16,
                              constraints.maxWidth,
                            ),
                            height:
                                200 +
                                math.max(
                                  0,
                                  MediaQuery.textScalerOf(context).scale(80) -
                                      80,
                                ),
                            child: BankCardWidget(
                              bankName: card.bankName,
                              cardNumber: card.cardNumber,
                              ownerName: card.ownerName,
                              expirationDate: card.expirationDate,
                              cardType: card.cardType,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        if (widget.cards.length > 1) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                key: const ValueKey('wallet-card-previous'),
                tooltip: zh ? '上一张卡' : 'Previous card',
                onPressed: index > 0 ? () => _select(index - 1) : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Flexible(
                child: Text(
                  '${index + 1} / ${widget.cards.length}',
                  key: const ValueKey('wallet-card-count'),
                ),
              ),
              IconButton(
                key: const ValueKey('wallet-card-next'),
                tooltip: zh ? '下一张卡' : 'Next card',
                onPressed: index < widget.cards.length - 1
                    ? () => _select(index + 1)
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// HTML .seg: a soft-grey group with a raised neutral selected surface.
class NeutralSegments extends StatelessWidget {
  const NeutralSegments({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
    required this.keyPrefix,
  });
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: AppColors.field(context),
      borderRadius: BorderRadius.circular(11),
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
  const WalletBars({
    super.key,
    required this.values,
    this.labels = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
  });
  final List<double> values;
  final List<String> labels;
  @override
  Widget build(BuildContext context) {
    final maximum = values.fold<double>(0, math.max);
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = math.min(28.0, constraints.maxWidth / 14);
          return Stack(
            alignment: Alignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < values.length; i++)
                    Expanded(
                      child: Semantics(
                        label: '${labels[i]}: ${values[i].toStringAsFixed(2)}',
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
                            Text(
                              zh
                                  ? const [
                                      '一',
                                      '二',
                                      '三',
                                      '四',
                                      '五',
                                      '六',
                                      '日',
                                    ][i % 7]
                                  : labels[i],
                              style: TextStyle(
                                fontSize: 9,
                                color: AppColors.muted(context),
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
                    zh
                        ? '所选范围暂无可统计记录'
                        : 'No records to summarize in the selected range',
                    key: const ValueKey('wallet-chart-empty'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.muted(context),
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

class WalletDataNotice extends StatelessWidget {
  const WalletDataNotice({super.key, required this.state});
  final WalletState state;
  @override
  Widget build(BuildContext context) {
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    final now = state.referenceDate ?? DateTime.now();
    if (state.undatedCount == 0) return const SizedBox.shrink();
    return Tooltip(
      message: zh
          ? '按设备日期 ${now.year}-${now.month}-${now.day} 统计，支持今天、昨天和 ISO 日期。'
          : 'Grouped using device date ${now.year}-${now.month}-${now.day}; supports Today, Yesterday and ISO dates.',
      child: Text(
        zh
            ? '${state.undatedCount} 笔日期未识别，未计入图表'
            : '${state.undatedCount} undated records excluded',
        style: TextStyle(fontSize: 11, color: AppColors.muted(context)),
      ),
    );
  }
}

class WalletTransactionRow extends StatelessWidget {
  const WalletTransactionRow({
    super.key,
    required this.transaction,
    required this.heroTag,
  });
  final Transaction transaction;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final data = transaction.localizedPlaceholders;
    final expense = (data.moneyAmount ?? 0) < 0;
    final amount =
        '${expense ? '−' : '+'} \$ ${(data.moneyAmount ?? 0).abs().toStringAsFixed(2)}';
    final tag = heroTag;
    final trailing = Text(
      amount,
      style: TextStyle(
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
                  Hero(
                    tag: tag,
                    // Keep the source transaction avatar during both flight directions;
                    // the resting wallet icon remains neutral as in the design.
                    flightShuttleBuilder:
                        (flightContext, animation, direction, from, to) =>
                            ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: NetworkWebImage(
                                data.userIcon ?? '',
                                fit: BoxFit.cover,
                              ),
                            ),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.line(context).withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        expense
                            ? Icons.north_east_rounded
                            : Icons.south_west_rounded,
                        color: AppColors.ink(context),
                        size: 21,
                      ),
                    ),
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
                          data.time ?? '',
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
        child: Text(
          Localizations.localeOf(context).languageCode == 'zh'
              ? '当前条件下没有交易记录'
              : 'No transactions match these filters',
        ),
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
