import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sirc/data/common_keys.dart';
import 'package:sirc/routes/app_routes.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/common_text_button.dart';
import 'package:sirc/widgets/verify_code_widget.dart';

import 'forget_pwd_logic.dart';

/*
* @description:
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/21
*/
class ForgetPwdPage extends StatefulWidget {
  @override
  State<ForgetPwdPage> createState() => _ForgetPwdPageState();
}

class _ForgetPwdPageState extends State<ForgetPwdPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final logic = Get.put(ForgetPwdLogic());
  final state = Get.find<ForgetPwdLogic>().state;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: const Duration(minutes: 1));
    logic.updateAnimationController(_controller);
    state.isVerifyingCode.listen((isLoginInProgress) async {
      if (isLoginInProgress) {
        Get.dialog(
            AlertDialog(
              title: Text("Loading...".tr),
              content: SizedBox(
                  height: 50.dp,
                  width: 50.dp,
                  child: const Center(child: CircularProgressIndicator())),
            ),
            barrierDismissible: false);
      } else {
        Get.back();
        // go to reset password page
        var resetResult = await Get.toNamed(AppRoutes.SET_PWD,
            parameters: {CommonKeys.USER_NAME: state.userEmail.value});
        if (true == resetResult) {
          Get.back(result: true);
        } else {
          // not change the password, stay in this page
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Forget Password".tr,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Obx(() {
        var isVerifyButtonEnabled = logic.isEmailAndVerifyCodeValid();
        var isSendVerifyCodeBtnDisable = state.lastSendVerifyCodeTime.value > 0;

        return Container(
          padding: EdgeInsets.all(20.dp),
          child: Column(
            children: [
              Text("Enter your email address to reset your password".tr,
                  style: const TextStyle(fontSize: 18, color: Colors.grey)),
              Container(
                margin: EdgeInsets.only(top: 50.dp),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.dp),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, 4),
                          blurRadius: 8)
                    ],
                    color: Colors.white),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Email Address".tr,
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide:
                          const BorderSide(color: Colors.black12, width: 0),
                    ),
                    labelText: "Email Address".tr,
                    errorText: state.userEmailError.value,
                    suffixIcon: state.userEmail.isNotEmpty &&
                            state.userEmailError.value == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: isSendVerifyCodeBtnDisable
                                    ? null
                                    : () {
                                        logic.verifyEmail();
                                      },
                                child: Container(
                                  margin:
                                      EdgeInsets.symmetric(horizontal: 10.dp),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20.dp, vertical: 5.dp),
                                  decoration: BoxDecoration(
                                      color: isSendVerifyCodeBtnDisable
                                          ? Colors.grey
                                          : Colors.blue,
                                      borderRadius:
                                          BorderRadius.circular(20.dp)),
                                  child: Text(
                                    "verify".tr +
                                        (state.lastSendVerifyCodeTime.value > 0
                                            ? ' (${state.lastSendVerifyCodeTime.value}s)'
                                            : ''),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const Icon(
                            Icons.email_outlined,
                            color: Colors.grey,
                          ),
                  ),
                  onChanged: (value) {
                    logic.setUserEmail(value);
                  },
                ),
              ),
              if (state.isWaitingForVerifyCode.value == true)
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 50.dp),
                      child: Text(
                        "Please enter the verify code we sent to your email:"
                            .tr,
                        style: TextStyle(color: Colors.grey, fontSize: 16.sp),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.dp),
                      child: VerifyCodeWidget(
                        onChanged: (value) {
                          logic.setVerifyCode(value);
                        },
                      ),
                    ),
                  ],
                ),
              CommonTextButton(
                  isButtonEnabled: isVerifyButtonEnabled,
                  onTap: () {
                    logic.verifyEmailAndResetPwd();
                  },
                  text: "Submit".tr),
            ],
          ),
        );
      }),
    );
  }
}
