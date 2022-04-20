import 'package:get/get_utils/src/extensions/internacionalization.dart';

/*
* @description: TODO
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/20
*/

class UsernamePwdUtils {
  static String? checkUserName(String userName) {
    String? result;
    if (userName.length < 3) {
      result = "the length of username must be more than 3".tr;
    } else if (userName.length > 10) {
      result = "the length of username must be less than 10".tr;
    } else {
      result = null;
    }
    return result;
  }

  static String? checkPassword(String pwd, {String? confirmPwd}) {
    confirmPwd ??= pwd;
    String? result;
    if (pwd.length < 6) {
      result = "the length of user password must be more than 6".tr;
    } else if (pwd.length > 12) {
      result = "the length of user password must be less than 12".tr;
    } else if (pwd != confirmPwd) {
      result = "the password is not same".tr;
    } else {
      result = null;
    }
    return result;
  }
}
