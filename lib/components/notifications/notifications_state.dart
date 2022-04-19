import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:sirc/bean/money_operate_bean.dart';
import 'package:sirc/bean/triple.dart';
import 'package:sirc/mock/mock_utils.dart';

/*
* @description:
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19
*/
class NotificationsState {
  var currentCategoryIndex = 0.obs;
  var currentExpandIndex = 0.obs;

  final List<String> categories = [
    "this week".tr,
    "this month".tr,
    "this year".tr
  ];

  final List<Triple<IconData, String, List<MoneyOperateBean>>> data = [
    Triple(Icons.transform, "Transfers".tr, MockUtils.moneyOperateList),
    Triple(Icons.monetization_on_outlined, "Recharge".tr,
        MockUtils.moneyOperateList),
    Triple(Icons.notes_outlined, "Bill".tr, MockUtils.moneyOperateList),
    Triple(Icons.more_horiz_outlined, "Others".tr, MockUtils.moneyOperateList),
  ];
}
