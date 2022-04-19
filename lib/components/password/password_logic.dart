import 'package:get/get.dart';

/*
* @description:
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19
*/
class PasswordLogic extends GetxController {
  var oldPassword = "".obs;
  var newPassword = "".obs;
  var confirmPassword = "".obs;

  var isOldPasswordVisible = false.obs;
  var isNewPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;

  void changePassword() {
    //todo change the password
    Get.back();
  }

  String? isNewPasswordValid() {
    if (oldPassword.value.isEmpty) {
      return "请先输入现有密码";
    }
    if (newPassword.value.isEmpty) {
      return "请输入新密码";
    }
    if (confirmPassword.value.isEmpty) {
      return "请输入确认新密码";
    }
    if (newPassword.value.isNotEmpty && confirmPassword.value.isNotEmpty) {
      if (newPassword.value != confirmPassword.value) {
        return "两次输入的密码不一致".tr;
      }
      if (newPassword.value.length < 6 || confirmPassword.value.length < 6) {
        return "密码长度不能小于6位".tr;
      }
    }
    return null;
  }
}
