import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main_app_logic.dart';
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
  final MainAppLogic _appLogic = Get.find();

  SharedPreferences? _prefs;

  @override
  Future<void> onInit() async {
    _prefs = await SharedPreferences.getInstance();
    // listen to the local change, and update the menu state
    _appLogic.listenLocalChange((p0) {
      state.menuItems.value = MenuState.generateMenus();
    });
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
