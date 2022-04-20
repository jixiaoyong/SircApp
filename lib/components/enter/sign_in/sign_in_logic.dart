import 'dart:ui';

import 'package:flutter/src/widgets/icon_data.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/bean/pair.dart';
import 'package:sirc/data/common_keys.dart';
import 'package:sirc/mock/mock_utils.dart';
import 'package:sirc/utils/m5d_utils.dart';

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
  SharedPreferences? _prefs;

  @override
  Future<void> onInit() async {
    _prefs = await SharedPreferences.getInstance();
    super.onInit();
  }

  void setUserName(String value) {
    state.userName.value = value;
    if (state.userName.value.length < 3) {
      state.userNameError.value =
          "the length of username must be more than 3".tr;
    } else if (state.userName.value.length > 10) {
      state.userNameError.value =
          "the length of username must be less than 10".tr;
    } else {
      state.userNameError.value = null;
    }
    state.isUserInputValid.value = isUserNameAndPwdValid();
  }

  void setUserPwd(String value) {
    state.userPwd.value = value;
    if (value.length < 6) {
      state.userPwdError.value =
          "the length of user password must be more than 6".tr;
    } else if (value.length > 12) {
      state.userPwdError.value =
          "the length of user password must be less than 12".tr;
    } else {
      state.userPwdError.value = null;
    }
    state.isUserInputValid.value = isUserNameAndPwdValid();
  }

  bool isUserNameAndPwdValid() {
    return state.userName.value.length >= 3 &&
        state.userName.value.length <= 10 &&
        state.userPwd.value.length >= 6 &&
        state.userPwd.value.length <= 12;
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
          state.isLoading.value = false;
          state.isLoginSuccess.value = true;
        } else {
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
