import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:sirc/bean/triple.dart';
import 'package:sirc/gen_a/A.dart';

/*
* @description: Slide Menu
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19
*/
class InitialState {
  // is first time app open
  Rx<bool?> isFirstInitial = Rx(null);

  // image path; title; subtitle
  final List<Triple<String, String, String>> initialTips = [
    Triple(
        A.assets_imgs_initial_password,
        "Don't Share Password".tr,
        "Use strong combinations of letters,numbers and special characters to make your password."
            .tr),
    Triple(
        A.assets_imgs_initial_pin_error,
        "Forgot PIN".tr,
        "Don't take too much tension about PiN\nJust make ono call to bank and change your pin."
            .tr),
    Triple(
        A.assets_imgs_initial_exchange,
        "Manage Account".tr,
        "Bank account make more secure keeping transaction active and changing password regularly."
            .tr),
  ];
}
