import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  SharedPreferences? _prefs;

  @override
  Future<void> onInit() async {
    _prefs = await SharedPreferences.getInstance();
    super.onInit();
  }

  void changeFingerprint({bool? isOpen}) {
    var isFingerprintOpen = isOpen ?? !state.isFingerprintOpen.value;
    state.isFingerprintOpen.value = isFingerprintOpen;
  }

  void logout() {
    _prefs?.clear();
  }
}
