import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sirc/mock/mock_utils.dart';
import 'package:sirc/utils/username_pwd_utils.dart';

import 'forget_pwd_state.dart';

/*
* @description:
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/21
*/
class ForgetPwdLogic extends GetxController {
  final ForgetPwdState state = ForgetPwdState();

  void updateAnimationController(AnimationController controller) {
    state.animationController = controller;
    state.animationController.addListener(() {
      state.lastSendVerifyCodeTime.value =
          ((1 - state.animationController.value) *
                  ForgetPwdState.VERIFY_CODE_DURATION_SECOND)
              .toInt();
      if (state.animationController.value == 1) {
        state.animationController.reset();
        state.lastSendVerifyCodeTime.value = 0;
      }
    });
  }

  void setUserEmail(String value) {
    state.userEmail.value = value;
    state.userEmailError.value = UsernamePwdUtils.checkUserEmail(value);
  }

  bool isEmailAndVerifyCodeValid() {
    return state.userEmailError.value == null &&
        state.verifyCode.value.length == ForgetPwdState.VERIFY_CODE_LENGTH;
  }

  void verifyEmail() {
    // todo send verify code to email
    state.animationController.forward();
    state.isWaitingForVerifyCode.value = true;
  }

  void setVerifyCode(String value) {
    state.verifyCode.value = value;
  }

  void verifyEmailAndResetPwd() {
    state.isVerifyingCode.value = true;
    // pretend to verify email and code
    Future.delayed(Duration(seconds: MockUtils.random.nextInt(10) + 5), () {
      state.isVerifyingCode.value = false;
    });
  }
}
