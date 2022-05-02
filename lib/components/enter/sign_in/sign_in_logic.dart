import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/bean/pair.dart';
import 'package:sirc/components/main_app_logic.dart';
import 'package:sirc/data/common_keys.dart';
import 'package:sirc/mock/mock_utils.dart';
import 'package:sirc/utils/m5d_utils.dart';
import 'package:sirc/utils/username_pwd_utils.dart';

import 'sign_in_state.dart';

/*
* @description:
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/20
*/
class SignInLogic extends GetxController {
  final SignInState state = SignInState();
  final MainAppLogic _appLogic = Get.find();
  final TextEditingController nameTextFieldController = TextEditingController();
  final TextEditingController pwdTextFieldController = TextEditingController();

  SharedPreferences? _prefs;

  @override
  Future<void> onInit() async {
    _prefs = await SharedPreferences.getInstance();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    if (kDebugMode) {
      // mock login data
      setUserName("jixiaoyong", false);
      setUserPwd("123456", false);
      final String userPwdMd5 = Md5Utils.generateMd5(state.userPwd.value);
      _prefs?.setString(CommonKeys.USER_NAME, state.userName.value);
      _prefs?.setString(CommonKeys.USER_PWD, userPwdMd5);
    }
  }

  void setUserName(String value, [bool isUserInput = true]) {
    state.userName.value = value;
    state.userNameError.value = UsernamePwdUtils.checkUserName(value);
    state.isUserInputValid.value = isUserNameAndPwdValid();
    if (!isUserInput) {
      nameTextFieldController.text = value;
    }
  }

  void setUserPwd(String value, [bool isUserInput = true]) {
    state.userPwd.value = value;
    state.userPwdError.value = UsernamePwdUtils.checkPassword(value);
    state.isUserInputValid.value = isUserNameAndPwdValid();
    if (!isUserInput) {
      pwdTextFieldController.text = value;
    }
  }

  bool isUserNameAndPwdValid() {
    return state.userPwdError.value == null &&
        state.userNameError.value == null;
  }

  void login() {
    if (isUserNameAndPwdValid()) {
      state.isLoading.value = true;

      // mock login
      Future.delayed(Duration(seconds: MockUtils.random.nextInt(10) + 3), () {
        final String? localUserName = _prefs?.getString(CommonKeys.USER_NAME);
        final String? localUserPwdMd5 = _prefs?.getString(CommonKeys.USER_PWD);
        final String userPwdMd5 = Md5Utils.generateMd5(state.userPwd.value);
        if (localUserName == state.userName.value &&
            userPwdMd5 == localUserPwdMd5) {
          _appLogic.setUserInfo(state.userName.value, null);
          state.isLoading.value = false;
          state.isLoginSuccess.value = true;
          _prefs?.setBool(CommonKeys.IS_LOGIN_SUCCESS, true);
        } else {
          _appLogic.setUserInfo("", null);
          state.isLoading.value = false;
          state.isLoginSuccess.value = false;
        }
      });
    }
  }

  void loginWith(Pair<IconData, Color> item) {
    // todo login with social account
  }
}
