import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/data/common_keys.dart';
import 'package:sirc/mock/mock_utils.dart';
import 'package:sirc/utils/m5d_utils.dart';
import 'package:sirc/utils/username_pwd_utils.dart';

import 'set_pwd_state.dart';

/*
* @description:
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/21
*/
class SetPwdLogic extends GetxController {
  final SetPwdState state = SetPwdState();

  SharedPreferences? _prefs;

  @override
  Future<void> onInit() async {
    _prefs = await SharedPreferences.getInstance();
    super.onInit();
  }

  void setUserName(String userName) {
    state.userName = Get.parameters[CommonKeys.USER_NAME] ?? "";
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
    if (state.userPwdError.value != null ||
        state.userConfirmPwdError.value != null) {
      return false;
    } else if (state.userConfirmPwd.value != state.userPwd.value) {
      return false;
    } else {
      return true;
    }
  }

  void resetPwd() {
    state.isWaitSetPwdResult.value = true;
    // pretend to set password
    Future.delayed(Duration(seconds: MockUtils.random.nextInt(5) + 5), () {
      // reset password success
      _prefs?.setString(CommonKeys.USER_NAME, state.userName);
      _prefs?.setString(
          CommonKeys.USER_PWD, Md5Utils.generateMd5(state.userPwd.value));
      state.isWaitSetPwdResult.value = false;
    });
  }
}
