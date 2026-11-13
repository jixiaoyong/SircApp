import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sirc/features/wallet/domain/models/transaction.dart';
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

  static final List<(String, double)> dataChange = [
    (Languages.mon, 0.3),
    (Languages.tues, 0.5),
    (Languages.wed, 0.1),
    (Languages.thur, 0.6),
    (Languages.fri, 0.9),
    (Languages.satu, 0.2),
    (Languages.sun, 0.8),
  ];

  static const List<String> mockAvatarList = [
    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80',
    'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=150&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80',
  ];

  static final List<Transaction> moneyOperateList = List.generate(20, (index) {
    return Transaction(
      userIcon: mockAvatarList[index % mockAvatarList.length],
      moneyAmount:
          MockUtils.random.nextDouble() *
          100 *
          (MockUtils.random.nextBool() ? 1 : -1),
      time: Languages.justNow,
      moneyActionName: Languages.something,
    );
  });

  static final List<(IconData, Color)> socialList = [
    (Icons.facebook_outlined, Colors.blue),
    (Icons.fastfood_sharp, Colors.deepOrange),
    (Icons.favorite_outlined, Colors.lightBlueAccent),
  ];
}
