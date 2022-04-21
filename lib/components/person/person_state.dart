import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:sirc/bean/money_operate_bean.dart';
import 'package:sirc/bean/pair.dart';
import 'package:sirc/mock/mock_utils.dart';

/*
* @description:
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/18
*/
class PersonState {
  var userName = "".obs;
  var currentIndex = 0.obs;

  final List<MoneyOperateBean> moneyOperateList = MockUtils.moneyOperateList;

  final Rx<List<Pair<IconData, String>>> generalInformationList =
      Rx(generateInfoList());

  static List<Pair<IconData, String>> generateInfoList() => [
        Pair(Icons.email_outlined, "E-mail".tr),
        Pair(Icons.phone_outlined, "Phone Number".tr),
        Pair(Icons.location_on_outlined, "Local Address".tr),
        Pair(Icons.credit_card_outlined, "Card Credit".tr),
      ];
}
