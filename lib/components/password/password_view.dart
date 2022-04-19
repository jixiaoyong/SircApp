import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/one_title_with_back_button_appbar.dart';

import 'password_logic.dart';

/*
* @description:
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19
*/
class PasswordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logic = Get.put(PasswordLogic());

    return Scaffold(
      appBar: OneTitleWithBackButtonAppBar(
        title: "Change Password".tr,
      ),
      body: Obx(() {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.dp),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                decoration: InputDecoration(
                    hintText: "Old Password".tr,
                    border: const OutlineInputBorder(),
                    suffix: GestureDetector(
                        onLongPress: () {
                          logic.isOldPasswordVisible.value = true;
                        },
                        onLongPressEnd: (_) {
                          logic.isOldPasswordVisible.value = false;
                        },
                        child: const Icon(Icons.remove_red_eye_outlined))),
                maxLines: 1,
                keyboardType: TextInputType.visiblePassword,
                obscureText: !logic.isOldPasswordVisible.value,
                onChanged: (value) {
                  logic.oldPassword.value = value;
                },
              ),
              Container(
                height: 20.dp,
              ),
              TextField(
                decoration: InputDecoration(
                    hintText: "New Password".tr,
                    border: const OutlineInputBorder(),
                    errorText: logic.isNewPasswordValid(),
                    suffix: GestureDetector(
                        onLongPress: () {
                          logic.isNewPasswordVisible.value = true;
                        },
                        onLongPressEnd: (_) {
                          logic.isNewPasswordVisible.value = false;
                        },
                        child: const Icon(Icons.remove_red_eye_outlined))),
                maxLines: 1,
                keyboardType: TextInputType.visiblePassword,
                obscureText: !logic.isNewPasswordVisible.value,
                onChanged: (value) {
                  logic.newPassword.value = value;
                },
              ),
              Container(
                height: 20.dp,
              ),
              TextField(
                decoration: InputDecoration(
                    hintText: "Confirm Password".tr,
                    errorText: logic.isNewPasswordValid(),
                    border: const OutlineInputBorder(),
                    suffix: GestureDetector(
                        onLongPress: () {
                          logic.isConfirmPasswordVisible.value = true;
                        },
                        onLongPressEnd: (_) {
                          logic.isConfirmPasswordVisible.value = false;
                        },
                        child: const Icon(Icons.remove_red_eye_outlined))),
                maxLines: 1,
                keyboardType: TextInputType.visiblePassword,
                obscureText: !logic.isConfirmPasswordVisible.value,
                onChanged: (value) {
                  logic.confirmPassword.value = value;
                },
              ),
              Container(
                height: 50.dp,
                width: double.infinity,
                margin: EdgeInsets.only(top: 50.dp),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.dp),
                    border: logic.isNewPasswordValid() != null
                        ? Border.all(color: Colors.grey)
                        : null,
                    gradient: logic.isNewPasswordValid() != null
                        ? null
                        : LinearGradient(
                            colors: [Colors.blue, Colors.purple.shade400],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight)),
                child: GestureDetector(
                    onTap: logic.isNewPasswordValid() != null
                        ? null
                        : () {
                            logic.changePassword();
                          },
                    child: Center(
                        child: Text("Change Password".tr,
                            style: TextStyle(
                                color: logic.isNewPasswordValid() != null
                                    ? Colors.grey
                                    : Colors.white,
                                fontSize: 16.dp)))),
              )
            ],
          ),
        );
      }),
    );
  }
}
