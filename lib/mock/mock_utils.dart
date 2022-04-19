import 'dart:math';

import 'package:get/get_utils/src/extensions/internacionalization.dart';
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
}
