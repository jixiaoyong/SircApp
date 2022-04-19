import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:sirc/bean/money_operate_bean.dart';
import 'package:sirc/bean/pair.dart';
import 'package:sirc/mock/mock_utils.dart';

/*
* @description: TODO
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/18
*/
class HistoryState {
  final List<String> monthEnglishNameList = [
    'January'.tr,
    'February'.tr,
    'March'.tr,
    'April'.tr,
    'May'.tr,
    'June'.tr,
    'July'.tr,
    'August'.tr,
    'September'.tr,
    'October'.tr,
    'November'.tr,
    'December'.tr
  ];

  var selectMonth = 'January'.obs;

  final List<Pair<String, double>> dataChange = MockUtils.dataChange.obs;

  final List<MoneyOperateBean> moneyOperateList = List.generate(20, (index) {
    return MoneyOperateBean(
        userIcon:
            'https://blush.design/api/download?shareUri=kKg1Yx6PG&w=800&h=800&fm=png',
        moneyAmount: MockUtils.random.nextDouble() * 100,
        time: "Just now".tr,
        moneyActionName: "Something".tr);
  });
}
