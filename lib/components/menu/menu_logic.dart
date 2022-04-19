import 'package:get/get.dart';

import 'menu_state.dart';

/*
* @description:
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19
*/
class MenuLogic extends GetxController {
  final MenuState state = MenuState();

  @override
  void onInit() {}

  void changeFingerprint({bool? isOpen}) {
    var isFingerprintOpen = isOpen ?? !state.isFingerprintOpen.value;
    state.isFingerprintOpen.value = isFingerprintOpen;
  }
}
