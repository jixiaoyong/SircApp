import 'dart:math';

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:sirc/bean/money_operate_bean.dart';

/*
* @description:
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/18
*/
class WalletState {
  static var random = Random(DateTime.now().millisecondsSinceEpoch);

  var availableBalance = 35.269;

  var currentClickBtnIndex = 0.obs;

  final List<String> moneyTypes = ['Last Send', 'Last Receive', 'Total'];

  final List<MoneyOperateBean> moneyOperateList = List.generate(20, (index) {
    return MoneyOperateBean(
        userIcon:
            'https://blush.design/api/download?shareUri=kKg1Yx6PG&w=800&h=800&fm=png',
        moneyAmount: random.nextDouble() * 100,
        time: "Just now",
        moneyActionName: "Something");
  });
}
