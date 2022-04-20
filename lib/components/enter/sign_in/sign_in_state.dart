import 'package:flutter/widgets.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:sirc/bean/pair.dart';
import 'package:sirc/mock/mock_utils.dart';

/*
* @description:
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/20
*/

class SignInState {
  var userName = "".obs;
  var userPwd = "".obs;

  Rx<String?> userNameError = Rx(null);
  Rx<String?> userPwdError = Rx(null);

  var isLoading = false.obs;

  var isLoginSuccess = false.obs;

  // is userName and userPwd is valid
  var isUserInputValid = false.obs;

  final List<Pair<IconData, Color>> socialList = MockUtils.socialList;

  SignInState() {
    ///Initialize variables
  }
}
