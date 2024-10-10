import 'package:get/get_utils/src/extensions/internacionalization.dart';

/*
* @description: 校验用户名和密码等的工具
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

  static String? checkUserEmail(String value) {
    String? result;
    final String email = value.trim();
    if (email.length < 5) {
      // for minimum length email example: a@b.cc
      result = "the length of user email must be more than 5".tr;
    } else if (email.length > 30) {
      result = "the length of user email must be less than 30".tr;
    } else if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email)) {
      result = "the email format is not correct".tr;
    } else {
      result = null;
    }
    return result;
  }
}
