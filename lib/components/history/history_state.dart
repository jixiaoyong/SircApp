import 'dart:math';

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:sirc/bean/money_operate_bean.dart';
import 'package:sirc/widgets/line_graph.dart';

/*
* @description: TODO
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/18
*/
class HistoryState {
  static var random = Random(DateTime.now().millisecondsSinceEpoch);

  final List<String> monthEnglishNameList = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  var selectMonth = 'January'.obs;

  final List<Pair<String, double>> dataChange = [
    Pair("Mon", 0.3),
    Pair("Tues", 0.5),
    Pair("Wed", 0.1),
    Pair("Thur", 0.6),
    Pair("Fri", 0.9),
    Pair("Satu", 0.2),
    Pair("Sun", 0.8),
  ].obs;

  final List<MoneyOperateBean> moneyOperateList = List.generate(20, (index) {
    return MoneyOperateBean(
        userIcon:
            'https://blush.design/api/download?shareUri=kKg1Yx6PG&w=800&h=800&fm=png',
        moneyAmount: random.nextDouble() * 100,
        time: "Just now",
        moneyActionName: "Something");
  });
}
