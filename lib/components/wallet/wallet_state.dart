
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:sirc/bean/money_operate_bean.dart';
import 'package:sirc/mock/mock_utils.dart';

/*
* @description:
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/18
*/
class WalletState {
  var availableBalance = 35.269;

  var currentClickBtnIndex = 0.obs;

  final List<String> moneyTypes = [
    'Last Send'.tr,
    'Last Receive'.tr,
    'Total'.tr
  ];

  final List<MoneyOperateBean> moneyOperateList = List.generate(20, (index) {
    return MoneyOperateBean(
        userIcon:
            'https://blush.design/api/download?shareUri=kKg1Yx6PG&w=800&h=800&fm=png',
        moneyAmount: MockUtils.random.nextDouble() * 100,
        time: "Just now".tr,
        moneyActionName: "Something".tr);
  });
}
