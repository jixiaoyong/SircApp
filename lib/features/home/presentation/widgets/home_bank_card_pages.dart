import 'package:material_ui/material_ui.dart';
import 'package:sirc/features/home/controllers/home_controller.dart';
import 'package:sirc/l10n/languages.g.dart' show Languages;
import 'package:sirc/widgets/bank_card_widget.dart' show BankCardWidget;

class HomeBankCardPages extends StatefulWidget {
  const HomeBankCardPages({
    super.key,
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
  State<HomeBankCardPages> createState() => _HomeBankCardPagesState();
}

class _HomeBankCardPagesState extends State<HomeBankCardPages>
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
  void didUpdateWidget(covariant HomeBankCardPages oldWidget) {
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
