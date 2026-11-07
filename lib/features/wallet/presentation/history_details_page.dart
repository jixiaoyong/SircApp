import 'package:flutter/material.dart';
import 'package:sirc/bean/money_operate_bean.dart';
import 'package:sirc/data/common_date.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/network_web_image.dart';
import 'package:sirc/widgets/one_title_with_back_button_appbar.dart';

/// 交易详情页面，展示更详尽的单笔交易信息与 Hero 动画
class HistoryDetailsPage extends StatelessWidget {
  final MoneyOperateBean data;
  final String heroTag;

  const HistoryDetailsPage({
    super.key,
    required this.data,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final isMoneyIn = (data.moneyAmount ?? 0) >= 0;
    final moneyArr =
        (data.moneyAmount ?? 0).abs().toStringAsFixed(2).split(".");

    return Scaffold(
      appBar: const OneTitleWithBackButtonAppBar(
        title: "Details",
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Column(
          children: [
            Hero(
              tag: heroTag,
              child: NetworkWebImage(
                data.userIcon ?? '',
                size: Size.square(CommonData.realScreenWidth),
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.dp),
              child: Text(
                data.moneyActionName ?? '',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 20.sp,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 25.dp),
              child: RichText(
                text: TextSpan(
                  text: "${isMoneyIn ? "+" : "-"}\$${moneyArr[0]}",
                  children: [
                    TextSpan(
                      text: ".${moneyArr.length > 1 ? moneyArr[1] : '00'}",
                      style: TextStyle(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.normal,
                      ),
                    )
                  ],
                  style: TextStyle(
                    fontSize: 50.sp,
                    fontWeight: FontWeight.w900,
                    color: isMoneyIn ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.dp),
              child: Text(
                isMoneyIn ? "🤑" : "😭",
                style: TextStyle(fontSize: 60.sp),
              ),
            ),
            SizedBox(height: 40.dp),
          ],
        ),
      ),
    );
  }
}
