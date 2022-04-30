import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/bean/pair.dart';
import 'package:sirc/components/enter/sign_in/sign_in_logic.dart';
import 'package:sirc/data/common_keys.dart';
import 'package:sirc/mock/mock_utils.dart';
import 'package:sirc/utils/m5d_utils.dart';
import 'package:sirc/utils/username_pwd_utils.dart';

import 'sign_up_state.dart';

/*
* @description:
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/20
*/
class SignUpLogic extends GetxController {
  final SignInLogic _signInLogic = Get.find();
  final SignUpState state = SignUpState();

  SharedPreferences? _prefs;

  @override
  Future<void> onInit() async {
    _prefs = await SharedPreferences.getInstance();
    super.onInit();
  }

  void setUserName(String value) {
    state.userName.value = value;
    state.userNameError.value = UsernamePwdUtils.checkUserName(value);
    state.isUserInputValid.value = isUserNameAndPwdValid();
  }

  void setUserEmail(String value) {
    state.userEmail.value = value;
    state.userEmailError.value = UsernamePwdUtils.checkUserEmail(value);
    state.isUserInputValid.value = isUserNameAndPwdValid();
  }

  void setUserPwd(String value) {
    state.userPwd.value = value;
    state.userPwdError.value = UsernamePwdUtils.checkPassword(value,
        confirmPwd: state.userConfirmPwd.value);
    state.userConfirmPwdError.value = UsernamePwdUtils.checkPassword(
        state.userConfirmPwd.value,
        confirmPwd: value);
    state.isUserInputValid.value = isUserNameAndPwdValid();
  }

  void setUserConfirmPwd(String value) {
    state.userConfirmPwd.value = value;
    state.userConfirmPwdError.value =
        UsernamePwdUtils.checkPassword(value, confirmPwd: state.userPwd.value);
    state.userPwdError.value =
        UsernamePwdUtils.checkPassword(state.userPwd.value, confirmPwd: value);
    state.isUserInputValid.value = isUserNameAndPwdValid();
  }

  bool isUserNameAndPwdValid() {
    if (state.userNameError.value != null ||
        state.userPwdError.value != null ||
        state.userConfirmPwdError.value != null ||
        state.userEmailError.value != null) {
      return false;
    } else if (state.userConfirmPwd.value != state.userPwd.value) {
      return false;
    } else {
      return true;
    }
  }

  void logUpWith(Pair<IconData, Color> item) {}

  void register() {
    if (isUserNameAndPwdValid()) {
      state.isLoading.value = true;

      // mock register
      Future.delayed(Duration(seconds: MockUtils.random.nextInt(10) + 3), () {
        // register success
        _signInLogic.setUserName(state.userName.value,false);
        _signInLogic.setUserPwd(state.userPwd.value,false);

        final String userPwdMd5 = Md5Utils.generateMd5(state.userPwd.value);
        _prefs?.setString(CommonKeys.USER_NAME, state.userName.value);
        _prefs?.setString(CommonKeys.USER_PWD, userPwdMd5);
        _prefs?.setString(CommonKeys.USER_EMAIL, state.userEmail.value);

        state.isLoading.value = false;
        state.isRegisterSuccess.value = true;
      });
    }
  }
}
