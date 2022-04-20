import 'package:get/get_utils/src/extensions/internacionalization.dart';

/*
* @description: TODO
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/20
*/

class UsernamePwdUtils {
  static String? checkUserName(String userNameInput) {
    String? result;
    var userName = userNameInput.trim();
    if (userName.length < 3) {
      result = "the length of username must be more than 3".tr;
    } else if (userName.length > 10) {
      result = "the length of username must be less than 10".tr;
    } else {
      result = null;
    }
    return result;
  }

  static String? checkPassword(String pwdStr, {String? confirmPwd}) {
    final String pwd = pwdStr.trim();
    final String confirmPwdStr = (confirmPwd ?? pwd).trim();
    String? result;
    if (pwd.length < 6) {
      result = "the length of user password must be more than 6".tr;
    } else if (pwd.length > 12) {
      result = "the length of user password must be less than 12".tr;
    } else if (pwd != confirmPwdStr) {
      result = "the password is not same".tr;
    } else {
      result = null;
    }
    return result;
  }
}
