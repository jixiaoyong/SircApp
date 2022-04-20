import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:sirc/bean/money_operate_bean.dart';
import 'package:sirc/bean/pair.dart';

/*
* @description: TODO
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19
*/
class MockUtils {
  static var random = Random(DateTime.now().millisecondsSinceEpoch);

  static final List<Pair<String, double>> dataChange = [
    Pair("Mon".tr, 0.3),
    Pair("Tues".tr, 0.5),
    Pair("Wed".tr, 0.1),
    Pair("Thur".tr, 0.6),
    Pair("Fri".tr, 0.9),
    Pair("Satu".tr, 0.2),
    Pair("Sun".tr, 0.8),
  ];

  static final List<MoneyOperateBean> moneyOperateList =
      List.generate(20, (index) {
    return MoneyOperateBean(
        userIcon:
            'https://blush.design/api/download?shareUri=kKg1Yx6PG&w=800&h=800&fm=png',
        moneyAmount: MockUtils.random.nextDouble() * 100,
        time: "Just now".tr,
        moneyActionName: "Something".tr);
  });

  static final List<Pair<IconData, Color>> socialList = [
    Pair(Icons.facebook_outlined, Colors.blue),
    Pair(Icons.fastfood_sharp, Colors.deepOrange),
    Pair(Icons.favorite_outlined, Colors.lightBlueAccent),
  ];
}
