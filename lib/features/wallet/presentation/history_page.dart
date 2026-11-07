import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/core/types/records.dart';
import 'package:sirc/features/home/controllers/navigation_controller.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:sirc/routes/app_routes.dart';
import 'package:sirc/utils/number_extension.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/line_graph.dart';
import 'package:sirc/widgets/network_web_image.dart';
import 'package:sirc/widgets/title_text.dart';

/// 交易历史视图，包含月度收支走势折线图、月份选择器、关键字检索与明细列表
class HistoryPage extends ConsumerWidget {
  final VoidCallback? onMenuTap;

  const HistoryPage({super.key, this.onMenuTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final state = ref.watch(walletControllerProvider);
    final userAvatar = ref.watch(
      navigationControllerProvider.select((s) => s.userAvatar),
    );

    return SingleChildScrollView(
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.dp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TitleText(text: "History".tr),
                  const Spacer(),
                  Padding(
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
                  )
                ],
              ),
              Row(
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 20.dp),
                          child: Text(
                            "\$ ${state.availableBalance}",
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurpleAccent,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5.dp),
                          child: RichText(
                            text: TextSpan(
                              text: "+20%",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: " Last Month".tr,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.normal,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.dp),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(15.dp)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade400,
                          blurRadius: 5.dp,
                          spreadRadius: 2.dp,
                        )
                      ],
                    ),
                    child: DropdownButton<String>(
                      items: state.monthEnglishNameList.map((e) {
                        return DropdownMenuItem<String>(
                          value: e,
                          child: Text(e),
                        );
                      }).toList(),
                      value: state.monthEnglishNameList.contains(state.selectedMonth)
                          ? state.selectedMonth
                          : (state.monthEnglishNameList.isNotEmpty
                              ? state.monthEnglishNameList.first
                              : null),
                      onChanged: (e) {
                        if (e != null) {
                          ref
                              .read(walletControllerProvider.notifier)
                              .selectMonth(e);
                        }
                      },
                      underline: Container(),
                    ),
                  ),
                ],
              ),
              Padding(
                padding:
                    EdgeInsets.symmetric(vertical: 20.dp, horizontal: 10.dp),
                child: SizedBox(
                  height: 200.dp,
                  width: double.infinity,
                  child: state.chartData.isNotEmpty
                      ? LineGraph(
                          data:
                              state.chartData.map((e) => e.toPair()).toList(),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              Container(
                margin:
                    EdgeInsets.symmetric(horizontal: 10.dp, vertical: 20.dp),
                padding:
                    EdgeInsets.symmetric(horizontal: 10.dp, vertical: 5.dp),
                height: 50.dp,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black12,
                  ),
                  borderRadius: BorderRadius.circular(10.dp),
                ),
                child: TextField(
                  onChanged: (value) {
                    ref
                        .read(walletControllerProvider.notifier)
                        .setSearchQuery(value);
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search".tr,
                    suffixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              ...state.transactions.map((data) {
                final String heroTag = "hero_history_${data.hashCode}";
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
                    margin: EdgeInsets.symmetric(
                      vertical: 10.dp,
                      horizontal: 10.dp,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withValues(alpha: 0.1),
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
                        SizedBox(width: 10.dp),
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
      ),
    );
  }
}
