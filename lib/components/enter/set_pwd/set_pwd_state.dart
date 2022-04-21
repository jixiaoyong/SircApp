import 'package:get/get_rx/src/rx_types/rx_types.dart';

/*
* @description:
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/21
*/
class SetPwdState {
  var isUserInputValid = false.obs;
  var isWaitSetPwdResult = false.obs;

  var userName = "";
  var userPwd = "".obs;
  var userConfirmPwd = "".obs;

  Rx<String?> userPwdError = Rx(null);
  Rx<String?> userConfirmPwdError = Rx(null);
}
