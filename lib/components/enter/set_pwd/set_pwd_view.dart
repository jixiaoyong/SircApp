import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sirc/data/common_keys.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/common_text_button.dart';

import 'set_pwd_logic.dart';

/*
* @description:
* need pass the userName with key: [CommonKeys.USER_NAME]
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/21
*/
class SetPwdPage extends StatefulWidget {
  @override
  State<SetPwdPage> createState() => _SetPwdPageState();
}

class _SetPwdPageState extends State<SetPwdPage> {
  final logic = Get.put(SetPwdLogic());
  final state = Get.find<SetPwdLogic>().state;

  @override
  void initState() {
    logic.setUserName(Get.parameters[CommonKeys.USER_NAME] ?? "");
    state.isWaitSetPwdResult.listen((isLoginInProgress) {
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
        // pretend if set pwd success, go to login page
        Get.back(result: true);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var marginBetweenFields = 30.dp;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add New Password".tr,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Obx(() {
        return Padding(
          padding: EdgeInsets.all(20.dp),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: marginBetweenFields),
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
                margin: EdgeInsets.only(top: marginBetweenFields),
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
              CommonTextButton(
                  isButtonEnabled: state.isUserInputValid.value,
                  onTap: () {
                    logic.resetPwd();
                  },
                  text: "Submit".tr),
            ],
          ),
        );
      }),
    );
  }
}
