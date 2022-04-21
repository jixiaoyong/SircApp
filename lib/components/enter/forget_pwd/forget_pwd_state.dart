import 'package:flutter/src/animation/animation_controller.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

/*
* @description:
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/21
*/
class ForgetPwdState {
  var userEmail = "".obs;
  var verifyCode = "".obs;

  // is waiting for server to verify email with verify code
  var isVerifyingCode = false.obs;

  // remain time of sending verify code, default is 0s
  var lastSendVerifyCodeTime = 0.obs;

  // just send verify code to email, waiting for user to input the code
  var isWaitingForVerifyCode = false.obs;

  Rx<String?> userEmailError = Rx(null);

  static const VERIFY_CODE_LENGTH = 6;
  static const VERIFY_CODE_DURATION_SECOND = 60;

  late AnimationController animationController;
}
