import 'package:flutter/material.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/one_title_with_back_button_appbar.dart';

import '../../../bean/money_operate_bean.dart';
import '../../../widgets/network_web_image.dart';
import '../../../utils/number_extension.dart';

/*
 * @Author: jixiaoyong
 * @Email: jixiaoyong1995@gmail.com
 * @Date: 22/04/30
 * @LastEditors: jixiaoyong
 * @LastEditTime: 22/04/30
 * @FilePath: /SircApp/lib/components/history/details/history_details.dart
 * @Description: a page of history details, show more details of a money operate
 * 
 * Copyright (c) 2022 by jixiaoyong, All Rights Reserved. 
 */
class HistoryDetails extends StatelessWidget {
  final MoneyOperateBean data;
  final String heroTag;
  const HistoryDetails({Key? key, required this.data, required this.heroTag})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMoneyIn = (data.moneyAmount ?? 0) >= 0;
    final moneyArr =
        (data.moneyAmount ?? 0).abs().toStringAsFixed(2).split(".");

    return Scaffold(
      appBar: OneTitleWithBackButtonAppBar(
        title: "Details",
      ),
      body: Column(
        children: [
          Hero(
            tag: heroTag,
            child: NetworkWebImage(
              data.userIcon!,
              size: Size.square(MediaQuery.of(context).size.width),
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.dp),
            child: Text(
              data.moneyActionName!,
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
                      text: ".${moneyArr[1]}",
                      style: TextStyle(
                          fontSize: 30.sp, fontWeight: FontWeight.normal))
                ],
                style: TextStyle(
                    fontSize: 50.sp,
                    fontWeight: FontWeight.w900,
                    color: isMoneyIn ? Colors.green : Colors.red),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.dp),
            child: Text(
              isMoneyIn ? "🤑" : "😭",
              style: TextStyle(fontSize: 60.sp),
            ),
          )
        ],
      ),
    );
  }
}
