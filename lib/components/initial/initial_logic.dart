import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/data/common_keys.dart';

import '../main_app_logic.dart';
import 'initial_state.dart';

/*
* @description: Slide Menu
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19
*/
class InitialLogic extends GetxController {
  final InitialState state = InitialState();
  final MainAppLogic _appLogic = Get.put(MainAppLogic(), permanent: true);

  SharedPreferences? _prefs;

  @override
  Future<void> onInit() async {
    // Obtain shared preferences.
    _prefs = await SharedPreferences.getInstance();
    state.isFirstInitial.value =
        _prefs?.getBool(CommonKeys.IS_FIRST_INITIAL) ?? true;

    var userName = _prefs?.getString(CommonKeys.USER_NAME);
    _appLogic.setUserInfo(userName);

    super.onInit();
  }

  void markAsNotFirstInitial() {
    state.isFirstInitial.value = false;
    _prefs?.setBool(CommonKeys.IS_FIRST_INITIAL, false);
  }

  // is user has logged in,not matter whether pwd is correct or not
  bool isUserLoggedIn() {
    var isLoginSuccess = _prefs?.getBool(CommonKeys.IS_LOGIN_SUCCESS);
    return isLoginSuccess == true;
  }
}
