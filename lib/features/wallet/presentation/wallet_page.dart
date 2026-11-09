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
              child: Row(
                children: [
                  Expanded(
                    child: _WalletActionButton(
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () {
                        ref
                            .read(walletControllerProvider.notifier)
                            .setFilterIndex(0);
                      },
                      colors: [Colors.blue, Colors.blueAccent.shade100],
                      text: Languages.send,
                      isSelected: state.currentFilterIndex == 0,
                    ),
                  ),
                  SizedBox(width: 10.dp),
                  Expanded(
                    child: _WalletActionButton(
                      icon: Icons.arrow_back_rounded,
                      onPressed: () {
                        ref
                            .read(walletControllerProvider.notifier)
                            .setFilterIndex(1);
                      },
                      colors: [
                        Colors.deepPurple,
                        Colors.deepPurpleAccent.shade100
                      ],
                      text: Languages.receive,
                      isSelected: state.currentFilterIndex == 1,
                    ),
                  ),
                  SizedBox(width: 10.dp),
                  Expanded(
                    child: _WalletActionButton(
                      icon: Icons.more_horiz_rounded,
                      onPressed: () {
                        ref
                            .read(walletControllerProvider.notifier)
                            .setFilterIndex(2);
                      },
                      colors: [Colors.orange, Colors.amber.shade400],
                      text: Languages.total,
                      isSelected: state.currentFilterIndex == 2,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.dp),
              child: TitleText(
                text: (state.currentFilterIndex >= 0 &&
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
                    extra: {
                      'data': data,
                      'heroTag': heroTag,
                    },
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(10.dp),
                  margin:
                      EdgeInsets.symmetric(vertical: 10.dp, horizontal: 20.dp),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        offset: const Offset(0, 0),
                        blurRadius: 10.dp,
                        spreadRadius: 10.dp,
                      )
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
    return Semantics(
      button: true,
      selected: isSelected,
      label: text,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(25.dp),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          height: 50.dp,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
          ),
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.dp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isSelected) ...[
                    Expanded(
                      child: Text(
                        text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                      ),
                    ),
                    SizedBox(width: 4.dp),
                  ],
                  Container(
                    width: 32.dp,
                    height: 32.dp,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
