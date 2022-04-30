import 'package:get/get.dart';
import 'package:sirc/components/main_app_logic.dart';
import 'package:sirc/routes/app_routes.dart';

import 'person_state.dart';

/*
* @description:
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/18
*/
class PersonLogic extends GetxController {
  final MainAppLogic _mainAppLogic = Get.find();

  final PersonState state = PersonState();

  @override
  void onInit() {
    state.userName = _mainAppLogic.userName;
    state.userAvatar = _mainAppLogic.userAvatar;
    _mainAppLogic.listenLocalChange((p0) {
      state.generalInformationList.value = PersonState.generateInfoList();
    });
    super.onInit();
  }

  void onClick(int index, String heroTag) {
    state.currentIndex.value = index;
    Get.toNamed(AppRoutes.HISTORY_DETAILS, arguments: {
      "data": state.moneyOperateList[index],
      "heroTag": heroTag,
    });
  }
}
