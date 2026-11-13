import '../core/localization/app_locale.dart';

/*
* @description: 校验用户名和密码等的工具，采用强类型 Languages 门面防拼写错漏
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/20
*/

class UsernamePwdUtils {
  static String? checkUserName(String userNameInput) {
    final userName = userNameInput.trim();
    return switch (userName.length) {
      < 3 => Languages.usernameLengthMin,
      > 10 => Languages.usernameLengthMax,
      _ => null,
    };
  }

  static String? checkPassword(String pwdStr, {String? confirmPwd}) {
    final String pwd = pwdStr.trim();
    final String confirmPwdStr = (confirmPwd ?? pwd).trim();
    return switch (pwd.length) {
      < 6 => Languages.passwordLengthMin,
      > 12 => Languages.passwordLengthMax,
      _ when pwd != confirmPwdStr => Languages.passwordNotSame,
      _ => null,
    };
  }

  static String? checkUserEmail(String value) {
    final String email = value.trim();
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    return switch (email.length) {
      < 5 => Languages.emailLengthMin,
      > 30 => Languages.emailLengthMax,
      _ when !emailRegex.hasMatch(email) => Languages.emailFormatNotCorrect,
      _ => null,
    };
  }
}
