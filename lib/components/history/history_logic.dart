import 'package:get/get.dart';
import 'package:sirc/bean/pair.dart';
import 'package:sirc/components/main_app_logic.dart';
import 'package:sirc/mock/mock_utils.dart';

import 'history_state.dart';

/*
* @description: TODO
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/18
*/
class HistoryLogic extends GetxController {
  final HistoryState state = HistoryState();
  final MainAppLogic _mainAppLogic = Get.find();

  @override
  void onInit() {
    state.userAvatar = _mainAppLogic.userAvatar;

    super.onInit();
  }

  final List<Pair<String, double>> dataChange = MockUtils.dataChange.obs;

  void setSelectMonth(String e) {
    state.selectMonth.value = e;
  }
}
