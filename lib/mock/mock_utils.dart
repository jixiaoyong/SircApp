import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sirc/bean/money_operate_bean.dart';
import 'package:sirc/bean/pair.dart';
import 'package:sirc/core/localization/app_locale.dart';

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

  static const List<String> mockAvatarList = [
    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80',
    'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=150&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80',
  ];

  static final List<MoneyOperateBean> moneyOperateList =
      List.generate(20, (index) {
    return MoneyOperateBean(
        userIcon: mockAvatarList[index % mockAvatarList.length],
        moneyAmount: MockUtils.random.nextDouble() *
            100 *
            (MockUtils.random.nextBool() ? 1 : -1),
        time: "Just now".tr,
        moneyActionName: "Something".tr);
  });

  static final List<Pair<IconData, Color>> socialList = [
    Pair(Icons.facebook_outlined, Colors.blue),
    Pair(Icons.fastfood_sharp, Colors.deepOrange),
    Pair(Icons.favorite_outlined, Colors.lightBlueAccent),
  ];
}
