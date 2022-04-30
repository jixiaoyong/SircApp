import 'package:get/get.dart';
import 'package:sirc/components/main_app_logic.dart';

import 'wallet_state.dart';

/*
* @description:
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/18
*/
class WalletLogic extends GetxController {
  final WalletState state = WalletState();
  final MainAppLogic _mainAppLogic = Get.find();

  @override
  void onInit() {
    state.userAvatar = _mainAppLogic.userAvatar;
    super.onInit();
  }

  void onClickBalanceBtn(int i) {
    state.currentClickBtnIndex.value = i;
  }
}
