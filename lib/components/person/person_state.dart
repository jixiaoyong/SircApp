import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:sirc/bean/money_operate_bean.dart';
import 'package:sirc/widgets/line_graph.dart';

/*
* @description:
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/18
*/
class PersonState {
  static var random = Random(DateTime.now().millisecondsSinceEpoch);

  var currentIndex = 0.obs;

  final List<MoneyOperateBean> moneyOperateList = List.generate(20, (index) {
    return MoneyOperateBean(
        userIcon:
            'https://blush.design/api/download?shareUri=kKg1Yx6PG&w=800&h=800&fm=png',
        moneyAmount: random.nextDouble() * 100,
        time: "Just now",
        moneyActionName: "Something");
  });

  final List<Pair<IconData, String>> generalInformationList = [
    Pair(Icons.email_outlined, "E-mail"),
    Pair(Icons.phone_outlined, "Phone Number"),
    Pair(Icons.location_on_outlined, "Local Address"),
    Pair(Icons.credit_card_outlined, "Card Credit"),
  ];
}
