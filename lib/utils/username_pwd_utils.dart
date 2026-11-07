import '../core/localization/app_locale.dart';

/*
* @description: 校验用户名和密码等的工具
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/20
*/

class UsernamePwdUtils {
  static String? checkUserName(String userNameInput) {
    final userName = userNameInput.trim();
    return switch (userName.length) {
      < 3 => "the length of username must be more than 3".tr,
      > 10 => "the length of username must be less than 10".tr,
      _ => null,
    };
  }

  static String? checkPassword(String pwdStr, {String? confirmPwd}) {
    final String pwd = pwdStr.trim();
    final String confirmPwdStr = (confirmPwd ?? pwd).trim();
    return switch (pwd.length) {
      < 6 => "the length of user password must be more than 6".tr,
      > 12 => "the length of user password must be less than 12".tr,
      _ when pwd != confirmPwdStr => "the password is not same".tr,
      _ => null,
    };
  }

  static String? checkUserEmail(String value) {
    final String email = value.trim();
    final emailRegex = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return switch (email.length) {
      < 5 => "the length of user email must be more than 5".tr,
      > 30 => "the length of user email must be less than 30".tr,
      _ when !emailRegex.hasMatch(email) => "the email format is not correct".tr,
      _ => null,
    };
  }
}

