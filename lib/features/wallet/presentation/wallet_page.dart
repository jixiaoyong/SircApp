import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/home/controllers/navigation_controller.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:sirc/routes/app_routes.dart';
import 'package:sirc/utils/color_extension.dart';
import 'package:sirc/utils/number_extension.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/network_web_image.dart';
import 'package:sirc/widgets/title_text.dart';

/// 钱包主视图，展示可用余额、发送/接收/总览分类切换与收支流水
class WalletPage extends ConsumerWidget {
  final VoidCallback? onMenuTap;

  const WalletPage({super.key, this.onMenuTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final state = ref.watch(walletControllerProvider);
    final userAvatar = ref.watch(
      navigationControllerProvider.select((s) => s.userAvatar),
    );

    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.only(right: 10.dp),
                child: GestureDetector(
                  onTap: () {
                    if (onMenuTap != null) {
                      onMenuTap!();
                    } else {
                      ref
                          .read(navigationControllerProvider.notifier)
                          .openDrawer();
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50.dp),
                    child: NetworkWebImage(
                      userAvatar,
                      size: Size(50.dp, 50.dp),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 20.dp),
                child: Text(
                  Languages.availableBalance,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: "#ffaab5ff".hexToColor,
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 30.dp, bottom: 45.dp),
                child: Text(
                  "\$ ${state.availableBalance}",
                  style: TextStyle(
                    fontSize: 35.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.dp),
              child: _WalletActions(
                selectedIndex: state.currentFilterIndex.clamp(0, 2),
                onSelected: (index) => ref
                    .read(walletControllerProvider.notifier)
                    .setFilterIndex(index),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.dp),
              child: TitleText(
                text:
                    (state.currentFilterIndex >= 0 &&
                        state.currentFilterIndex < state.moneyTypes.length)
                    ? state.moneyTypes[state.currentFilterIndex]
                    : Languages.total,
              ),
            ),
            ...state.transactions.map((data) {
              final heroTag = "heroTag_${data.hashCode}";
              return GestureDetector(
                onTap: () {
                  context.push(
                    AppRoutes.HISTORY_DETAILS,
                    extra: {'data': data, 'heroTag': heroTag},
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(10.dp),
                  margin: EdgeInsets.symmetric(
                    vertical: 10.dp,
                    horizontal: 20.dp,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        offset: const Offset(0, 0),
                        blurRadius: 10.dp,
                        spreadRadius: 10.dp,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10.dp),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Hero(
                        tag: heroTag,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5.dp),
                          child: NetworkWebImage(
                            data.userIcon ?? '',
                            size: Size.square(50.dp),
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                      SizedBox(width: 20.dp),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              data.moneyActionName ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: Colors.black,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 8.dp),
                              child: Text(
                                data.time ?? '',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        data.moneyAmount.toFormatedMoneyStr,
                        style: TextStyle(
                          fontSize: 20.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _WalletActions extends StatefulWidget {
  const _WalletActions({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  State<_WalletActions> createState() => _WalletActionsState();
}

class _WalletActionsState extends State<_WalletActions>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<double> _begin;
  late List<double> _end;

  List<double> _target(int index) =>
      List.generate(3, (i) => i == index ? 1 : 0);

  List<double> get _weights => List.generate(
    3,
    (i) => _begin[i] + (_end[i] - _begin[i]) * _controller.value,
  );

  @override
  void initState() {
    super.initState();
    _begin = _end = _target(widget.selectedIndex);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      value: 1,
    );
  }

  @override
  void didUpdateWidget(covariant _WalletActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      // Retarget every width from the same rendered frame. The weights always
      // sum to one, including during interrupted and reversed transitions.
      _begin = _weights;
      _end = _target(widget.selectedIndex);
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = [Languages.send, Languages.receive, Languages.total];
    final colors = [
      [Colors.blue, Colors.blueAccent.shade100],
      [Colors.deepPurple, Colors.deepPurpleAccent.shade100],
      [Colors.orange, Colors.amber.shade400],
    ];
    const icons = [
      Icons.arrow_forward_rounded,
      Icons.arrow_back_rounded,
      Icons.more_horiz_rounded,
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        // Normal widths retain 50px circles and 10px gaps. Below the minimum
        // required width, shrink these together instead of overflowing the row.
        final scale = (constraints.maxWidth / 170.dp).clamp(0.0, 1.0);
        final diameter = 50.dp * scale;
        final gap = 10.dp * scale;
        final extra = (constraints.maxWidth - 3 * diameter - 2 * gap).clamp(
          0.0,
          double.infinity,
        );
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final weights = _weights;
            final widths = List.generate(
              3,
              (i) => diameter + extra * weights[i],
            );
            // Assign any floating-point remainder to the final item.
            widths[2] = (constraints.maxWidth - 2 * gap - widths[0] - widths[1])
                .clamp(0.0, double.infinity);
            return Row(
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) SizedBox(width: gap),
                  SizedBox(
                    width: widths[i],
                    height: diameter,
                    child: _WalletActionButton(
                      icon: icons[i],
                      colors: colors[i],
                      text: labels[i],
                      isSelected: widget.selectedIndex == i,
                      onPressed: () => widget.onSelected(i),
                    ),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _WalletActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final List<Color> colors;
  final String text;
  final bool isSelected;

  const _WalletActionButton({
    required this.icon,
    required this.onPressed,
    required this.colors,
    required this.text,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => ClipRRect(
        borderRadius: BorderRadius.circular(25.dp),
        child: Semantics(
          button: true,
          selected: isSelected,
          label: text,
          onTap: onPressed,
          excludeSemantics: true,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(25.dp),
            clipBehavior: Clip.antiAlias,
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
              ),
              child: InkWell(
                onTap: onPressed,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    if (isSelected && constraints.maxWidth >= 50.dp)
                      Positioned.fill(
                        left: 4.dp,
                        right: 46.dp,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      right: 9.dp,
                      top: 9.dp,
                      width: 32.dp,
                      height: 32.dp,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? Colors.white : Colors.transparent,
                        ),
                        child: Icon(
                          icon,
                          size: 24.dp,
                          color: isSelected ? colors.first : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
