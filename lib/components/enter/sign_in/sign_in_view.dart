import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sirc/routes/app_routes.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/common_text_button.dart';
import 'package:sirc/widgets/title_text.dart';

import 'sign_in_logic.dart';

/*
* @description:
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/20
*/
class SignInPage extends StatefulWidget {
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final logic = Get.put(SignInLogic());
  final state = Get.find<SignInLogic>().state;

  @override
  void initState() {
    state.isLoading.listen((isLoginInProgress) {
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
      }
    });

    state.isLoginSuccess.listen((isLoginSuccess) {
      if (isLoginSuccess) {
        Get.back(result: true);
      } else {
        Get.dialog(
          AlertDialog(
            title: Text("Login Failed".tr),
            content: SizedBox(
              height: 80.dp,
              child: Center(
                  child: Icon(
                Icons.error_outline_outlined,
                color: Colors.red,
                size: 80.dp,
              )),
            ),
          ),
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Sign In".tr,
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
          var isLoginInProgress = state.isLoading.value == true;
          var isButtonEnabled =
              !isLoginInProgress && state.isUserInputValid.value == true;

          return SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.dp),
              padding: EdgeInsets.symmetric(vertical: 20.dp),
              // the body height is the height of screen reduced by
              // the height of the app bar and top margin
              height:
                  MediaQuery.of(context).size.height - kToolbarHeight - 16.dp,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 100.dp,
                  ),
                  Container(
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
                        hintText: "Username".tr,
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide:
                              const BorderSide(color: Colors.black12, width: 0),
                        ),
                        labelText: "Username".tr,
                        errorText: state.userNameError.value,
                        suffixIcon: const Icon(
                          Icons.person_outline,
                          color: Colors.grey,
                        ),
                      ),
                      onChanged: (value) {
                        logic.setUserName(value);
                      },
                    ),
                  ),
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
                        hintText: "Password".tr,
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide:
                              const BorderSide(color: Colors.black12, width: 0),
                        ),
                        labelText: "Password".tr,
                        errorText: state.userPwdError.value,
                        suffixIcon: const Icon(
                          Icons.lock_outlined,
                          color: Colors.grey,
                        ),
                      ),
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      onChanged: (value) {
                        logic.setUserPwd(value);
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          var result = await Get.toNamed(AppRoutes.FORGET_PWD);
                          if (true == result) {
                            Get.snackbar("Set Password Succeed".tr,
                                "Please login with your new password.".tr);
                          }
                        },
                        child: Text("Forget passwords?".tr,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                height: 3,
                                fontSize: 12.dp,
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  CommonTextButton(
                      isButtonEnabled: isButtonEnabled,
                      onTap: () {
                        logic.login();
                      },
                      text: "Login".tr),
                  TitleText(text: "Or Sign In With".tr),
                  SizedBox(
                    height: 50.dp,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            var item = state.socialList[index];
                            return GestureDetector(
                              onTap: () {
                                logic.loginWith(item);
                              },
                              child: Container(
                                  height: 50.dp,
                                  width: 50.dp,
                                  margin:
                                      EdgeInsets.symmetric(horizontal: 10.dp),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.dp),
                                    border: Border.all(
                                        color: item.second, width: 1),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      item.first,
                                      color: item.second,
                                    ),
                                  )),
                            );
                          },
                          itemCount: state.socialList.length,
                          scrollDirection: Axis.horizontal,
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: Container()),
                  RichText(
                      text: TextSpan(
                          text: "I don't have an account".tr,
                          style:
                              TextStyle(color: Colors.black, fontSize: 12.dp),
                          children: [
                        TextSpan(
                            text: " ${"Sign Up".tr}",
                            style: TextStyle(
                                color: Colors.purple,
                                fontSize: 12.dp,
                                fontWeight: FontWeight.w500),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => Get.toNamed(AppRoutes.SIGN_UP))
                      ]))
                ],
              ),
            ),
          );
        }));
  }
}
