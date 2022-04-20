import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sirc/routes/app_routes.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/title_text.dart';

import 'sign_up_logic.dart';

/*
* @description: routes for app pages
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/20
*/
class SignUpPage extends StatefulWidget {
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final logic = Get.put(SignUpLogic());
  final state = Get.find<SignUpLogic>().state;

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

    state.isRegisterSuccess.listen((isLoginSuccess) {
      if (isLoginSuccess) {
        Get.until(
          ModalRoute.withName(AppRoutes.SIGN_IN),
        );
        Get.snackbar("Register Succeed", "Please Sign In");
      } else {
        Get.dialog(
          AlertDialog(
            title: Text("Register Failed".tr),
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
    var _screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Sign Up".tr,
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
              height: _screenHeight - kToolbarHeight - 16.dp,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: _screenHeight / 12,
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
                        hintText: "Confirm Password".tr,
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide:
                              const BorderSide(color: Colors.black12, width: 0),
                        ),
                        labelText: "Confirm Password".tr,
                        errorText: state.userConfirmPwdError.value,
                        suffixIcon: const Icon(
                          Icons.lock_outlined,
                          color: Colors.grey,
                        ),
                      ),
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      onChanged: (value) {
                        logic.setUserConfirmPwd(value);
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: !isButtonEnabled
                        ? null
                        : () {
                            logic.register();
                          },
                    child: Container(
                      height: 50.dp,
                      margin: EdgeInsets.only(top: 30.dp, bottom: 50.dp),
                      decoration: !isButtonEnabled
                          ? BoxDecoration(
                              borderRadius: BorderRadius.circular(8.dp),
                              color: Colors.grey[200],
                              border: Border.all(color: Colors.grey, width: 1),
                            )
                          : BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.purple.shade400.withOpacity(0.7),
                                  Colors.deepPurpleAccent.shade400
                                      .withOpacity(0.7)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8.dp)),
                      child: Center(
                        child: Text("Register".tr,
                            style: TextStyle(
                                color: !isButtonEnabled
                                    ? Colors.grey
                                    : Colors.white,
                                fontSize: 16.dp,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),
                  TitleText(text: "Or Sign Up With".tr),
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
                                logic.logUpWith(item);
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
                          text: "I have already an account".tr,
                          style:
                              TextStyle(color: Colors.black, fontSize: 12.dp),
                          children: [
                        TextSpan(
                            text: " Sign In".tr,
                            style: TextStyle(
                                color: Colors.purple,
                                fontSize: 12.dp,
                                fontWeight: FontWeight.w500),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => Get.back())
                      ]))
                ],
              ),
            ),
          );
        }));
  }
}
