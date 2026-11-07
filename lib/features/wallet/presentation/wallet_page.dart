import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/home/controllers/navigation_controller.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:sirc/features/wallet/presentation/history_details_page.dart';
import 'package:sirc/routes/app_routes.dart';
import 'package:sirc/utils/color_extension.dart';
import 'package:sirc/utils/number_extension.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/expanded_icon_button.dart';
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
                      ref.read(navigationControllerProvider.notifier).openDrawer();
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
                  "Available Balance".tr,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ExpandedIconButton(
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () {
                    ref.read(walletControllerProvider.notifier).setFilterIndex(0);
                  },
                  height: 50.dp,
                  maxWidth: 200.dp,
                  colors: [Colors.blue, Colors.blueAccent.shade100],
                  text: "Send".tr,
                  isExpanded: state.currentFilterIndex == 0,
                ),
                ExpandedIconButton(
                  icon: Icons.arrow_back_rounded,
                  onPressed: () {
                    ref.read(walletControllerProvider.notifier).setFilterIndex(1);
                  },
                  height: 50.dp,
                  maxWidth: 200.dp,
                  colors: [Colors.deepPurple, Colors.deepPurpleAccent.shade100],
                  text: "Receive".tr,
                  isExpanded: state.currentFilterIndex == 1,
                ),
                ExpandedIconButton(
                  icon: Icons.more_horiz_rounded,
                  onPressed: () {
                    ref.read(walletControllerProvider.notifier).setFilterIndex(2);
                  },
                  height: 50.dp,
                  maxWidth: 200.dp,
                  colors: [Colors.orange, Colors.amber.shade400],
                  text: "Total".tr,
                  isExpanded: state.currentFilterIndex == 2,
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.dp),
              child: TitleText(
                text: (state.currentFilterIndex >= 0 &&
                        state.currentFilterIndex < state.moneyTypes.length)
                    ? state.moneyTypes[state.currentFilterIndex]
                    : "Total".tr,
              ),
            ),
            ...state.transactions.map((data) {
              final heroTag = "heroTag_${data.hashCode}";
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.HISTORY_DETAILS,
                    arguments: {
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
