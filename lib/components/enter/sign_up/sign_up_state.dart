import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sirc/bean/pair.dart';
import 'package:sirc/mock/mock_utils.dart';

/*
* @description:
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/20
*/
class SignUpState {
  final List<Pair<IconData, Color>> socialList = MockUtils.socialList;

  var userName = "".obs;
  var userEmail = "".obs;
  var userPwd = "".obs;
  var userConfirmPwd = "".obs;

  Rx<String?> userNameError = Rx(null);
  Rx<String?> userEmailError = Rx(null);
  Rx<String?> userPwdError = Rx(null);
  Rx<String?> userConfirmPwdError = Rx(null);

  var isRegisterSuccess = false.obs;
  var isLoading = false.obs;

  // is userName userPwd userConfirmPwd valid
  var isUserInputValid = false.obs;

  SignUpState() {
    ///Initialize variables
  }
}
