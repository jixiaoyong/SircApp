import 'package:get/get.dart';

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

  void onClickBalanceBtn(int i) {
    state.currentClickBtnIndex.value = i;
  }
}
